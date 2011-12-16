#import "ObjP.h"

@implementation OPProxy
- (id)initwithClassName:(NSString *)name
{
    PyObject *pClass;
    self = [super init];
    pClass = ObjP_findPythonClass(name);
    py = PyObject_CallObject(pClass, NULL);
    Py_DECREF(pClass);
    return self;
}

- (void)dealloc
{
    Py_DECREF(py);
    [super dealloc];
}
@end

PyObject* ObjP_findPythonClass(NSString *name)
{
    PyObject *pMainModule, *pClass;
    pMainModule = PyImport_AddModule("__main__");
    pClass = PyObject_GetAttrString(pMainModule, [name UTF8String]);
    if (pClass == NULL) {
        PyErr_Print();
        PyErr_Clear();
    }
    return pClass;
}

NSString* ObjP_str2nsstring(PyObject *pStr)
{
    PyObject *pBytes = PyUnicode_AsUTF8String(pStr);
    char *utf8Bytes = PyBytes_AS_STRING(pBytes);
    NSString *result = [NSString stringWithUTF8String:utf8Bytes];
    Py_DECREF(pBytes);
    return result;
}
