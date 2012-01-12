import os.path as op
import inspect

from .base import (PYTYPE2SPEC, tmpl_replace, copy_objp_unit, ArgSpec, MethodSpec, ClassSpec,
    get_objc_signature)

TEMPLATE_HEADER = """
#import <Cocoa/Cocoa.h>
#import <Python.h>
%%imports%%

@interface %%classname%%:NSObject %%protocols%%
{
    PyObject *py;
}
- (PyObject *)pyRef;
%%methods%%
@end
"""

TEMPLATE_UNIT = """
#import "%%classname%%.h"
#import "ObjP.h"

@implementation %%classname%%
- (void)dealloc
{
    PyGILState_STATE gilState = PyGILState_Ensure();
    Py_DECREF(py);
    PyGILState_Release(gilState);
    [super dealloc];
}

- (PyObject *)pyRef
{
    return py;
}

%%methods%%
@end
"""

TEMPLATE_INIT_METHOD = """
- %%signature%%
{
    self = [super init];
    PyGILState_STATE gilState = PyGILState_Ensure();
    PyObject *pClass = ObjP_findPythonClass(@"%%classname%%", nil);
    py = PyObject_CallFunctionObjArgs(pClass, %%args%%);
    OBJP_ERRCHECK(py);
    Py_DECREF(pClass);
    PyGILState_Release(gilState);
    return self;
}
"""

TEMPLATE_METHOD = """
- %%signature%%
{
    PyObject *pResult, *pMethodName;
    PyGILState_STATE gilState = PyGILState_Ensure();
    pMethodName = PyUnicode_FromString("%%pyname%%");
    OBJP_ERRCHECK(pMethodName);
    pResult = PyObject_CallMethodObjArgs(py, pMethodName, %%args%%);
    OBJP_ERRCHECK(pResult);
    Py_DECREF(pMethodName);
    %%returncode%%
}
"""

TEMPLATE_RETURN_VOID = """
    Py_DECREF(pResult);
    PyGILState_Release(gilState);
"""

TEMPLATE_RETURN = """
    %%type%% result = %%pyconversion%%;
    Py_DECREF(pResult);
    PyGILState_Release(gilState);
    return result;
"""

def camelcase(s):
    elems = s.split('_')
    elems = [elems[0]] + [e.title() for e in elems[1:]]
    return ''.join(elems)

def internalize_argspec(name, argspec):
    # take argspec from the inspect module and returns MethodSpec
    args = argspec.args[1:] # remove self
    ann = argspec.annotations
    assert all(arg in ann for arg in args)
    assert all(argtype in PYTYPE2SPEC for argtype in ann.values())
    argspecs = []
    for arg in args:
        ts = PYTYPE2SPEC[ann[arg]]
        argspecs.append(ArgSpec(arg, ts))
    if name == '__init__':
        # generate objcname from args and always have an object return type
        returntype = PYTYPE2SPEC[object]
        if argspecs:
            argnames = [camelcase(arg.argname) for arg in argspecs]
            argnames[0] = argnames[0].title()
            objcname = 'initWith' + ':'.join(argnames) + ':'
        else:
            objcname = 'init'
    else:
        if 'return' in ann:
            returntype = PYTYPE2SPEC[ann['return']]
        else:
            returntype = None
        objcname = name.replace('_', ':')
    return MethodSpec(name, objcname, argspecs, returntype)

def get_arg_c_code(argspecs):
    result = []
    for arg in argspecs:
        result.append(arg.typespec.o2p_code % arg.argname)
    result.append('NULL') # We have to add a NULL item in va_args in PyObject_CallMethodObjArgs
    return ', '.join(result)

def get_objc_method_code(clsspec, methodspec):
    signature = get_objc_signature(methodspec)
    tmpl_args = get_arg_c_code(methodspec.argspecs)
    if methodspec.returntype is not None:
        ts = methodspec.returntype
        tmpl_pyconversion = ts.p2o_code % 'pResult'
        returncode = tmpl_replace(TEMPLATE_RETURN, type=ts.objctype, pyconversion=tmpl_pyconversion)
    else:
        returncode = TEMPLATE_RETURN_VOID
    if methodspec.pyname == '__init__':
        code = tmpl_replace(TEMPLATE_INIT_METHOD, signature=signature, classname=clsspec.clsname,
            args=tmpl_args)
    else:
        code = tmpl_replace(TEMPLATE_METHOD, signature=signature, pyname=methodspec.pyname,
            args=tmpl_args, returncode=returncode)
    sig = '- %s;' % signature
    return (code, sig)

def spec_from_python_class(class_):
    methods = inspect.getmembers(class_, inspect.isfunction)
    methodspecs = []
    for name, meth in methods:
        if getattr(meth, 'dontwrap', False):
            continue
        argspec = inspect.getfullargspec(meth)
        try:
            if hasattr(meth, 'objcname'):
                name = meth.objcname
            methodspec = internalize_argspec(name, argspec)
            methodspecs.append(methodspec)
        except AssertionError:
            print("Warning: Couldn't generate spec for %s" % name)
            continue
    if not any(ms.pyname == '__init__' for ms in methodspecs):
        # Always create a default init method.
        methodspecs.insert(0, MethodSpec('__init__', 'init', [], PYTYPE2SPEC[object]))
    return ClassSpec(class_.__name__, methodspecs, True)

def generate_objc_code(class_, destfolder, extra_imports=None, follow_protocols=None):
    clsspec = spec_from_python_class(class_)
    clsname = clsspec.clsname
    method_code = []
    method_sigs = []
    for methodspec in clsspec.methodspecs:
        try:
            code, sig = get_objc_method_code(clsspec, methodspec)
        except AssertionError:
            print("Warning: Couldn't generate code for %s" % methodspec.pyname)
            continue
        method_code.append(code)
        method_sigs.append(sig)
    if extra_imports:
        tmpl_imports = '\n'.join('#import "%s"' % imp for imp in extra_imports)
    else:
        tmpl_imports = ''
    if follow_protocols:
        tmpl_protocols = '<%s>' % ','.join(follow_protocols)
    else:
        tmpl_protocols = ''
    header = tmpl_replace(TEMPLATE_HEADER, classname=clsname, methods='\n'.join(method_sigs),
        imports=tmpl_imports, protocols=tmpl_protocols)
    implementation = tmpl_replace(TEMPLATE_UNIT, classname=clsname, methods=''.join(method_code))
    copy_objp_unit(destfolder)
    with open(op.join(destfolder, '%s.h' % clsname), 'wt') as fp:
        fp.write(header)
    with open(op.join(destfolder, '%s.m' % clsname), 'wt') as fp:
        fp.write(implementation)
