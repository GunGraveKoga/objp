
#define PY_SSIZE_T_CLEAN
#import <Python.h>
#import "structmember.h"
#import "ObjP.h"

#import <Cocoa/Cocoa.h>

@interface MyCallback : NSObject {}
- (void)thisIsCalledBackFromPython:(NSString *)arg;
@end

typedef struct {
    PyObject_HEAD
    MyCallback *objc_ref;
} MyCallback_Struct;

static PyTypeObject MyCallback_Type; /* Forward declaration */

/* Methods */

static void
MyCallback_dealloc(MyCallback_Struct *self)
{
    [self->objc_ref release];
    Py_TYPE(self)->tp_free((PyObject *)self);
}


static int
MyCallback_init(MyCallback_Struct *self, PyObject *args, PyObject *kwds)
{
    PyObject *pRefCapsule = NULL;
    if (!PyArg_ParseTuple(args, "|O", &pRefCapsule)) {
        return -1;
    }
    
    if (pRefCapsule == NULL) {
        self->objc_ref = [[MyCallback alloc] init];
    }
    else {
        self->objc_ref = PyCapsule_GetPointer(pRefCapsule, NULL);
    }
    
    return 0;
}



static PyObject *
MyCallback_thisIsCalledBackFromPython_(MyCallback_Struct *self, PyObject *args)
{
    PyObject *parg;
    if (!PyArg_ParseTuple(args, "O", &parg)) {
        return NULL;
    }
    NSString * arg = ObjP_str_p2o(parg);
    
    [self->objc_ref thisIsCalledBackFromPython:arg];
    Py_RETURN_NONE;
}


static PyMethodDef MyCallback_methods[] = {
 
{"thisIsCalledBackFromPython_", (PyCFunction)MyCallback_thisIsCalledBackFromPython_, METH_VARARGS, ""},

{NULL}  /* Sentinel */
};

static PyTypeObject MyCallback_Type = {
    PyVarObject_HEAD_INIT(NULL, 0)
    "MyCallbackProxy.MyCallback", /*tp_name*/
    sizeof(MyCallback_Struct), /*tp_basicsize*/
    0, /*tp_itemsize*/
    (destructor)MyCallback_dealloc, /*tp_dealloc*/
    0, /*tp_print*/
    0, /*tp_getattr*/
    0, /*tp_setattr*/
    0, /*tp_reserved*/
    0, /*tp_repr*/
    0, /*tp_as_number*/
    0, /*tp_as_sequence*/
    0, /*tp_as_mapping*/
    0, /*tp_hash */
    0, /*tp_call*/
    0, /*tp_str*/
    0, /*tp_getattro*/
    0, /*tp_setattro*/
    0, /*tp_as_buffer*/
    Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE, /*tp_flags*/
    "MyCallback object", /* tp_doc */
    0, /* tp_traverse */
    0, /* tp_clear */
    0, /* tp_richcompare */
    0, /* tp_weaklistoffset */
    0, /* tp_iter */
    0, /* tp_iternext */
    MyCallback_methods,/* tp_methods */
    0, /* tp_members */
    0, /* tp_getset */
    0, /* tp_base */
    0, /* tp_dict */
    0, /* tp_descr_get */
    0, /* tp_descr_set */
    0, /* tp_dictoffset */
    (initproc)MyCallback_init,      /* tp_init */
    0, /* tp_alloc */
    0, /* tp_new */
    0, /* tp_free */
    0, /* tp_is_gcc */
    0, /* tp_bases */
    0, /* tp_mro */
    0, /* tp_cache */
    0, /* tp_subclasses */
    0  /* tp_weaklist */
};

static PyMethodDef module_methods[] = {
    {NULL}  /* Sentinel */
};

static struct PyModuleDef MyCallbackProxyDef = {
    PyModuleDef_HEAD_INIT,
    "MyCallbackProxy",
    NULL,
    -1,
    module_methods,
    NULL,
    NULL,
    NULL,
    NULL
};

PyObject *
PyInit_MyCallbackProxy(void)
{
    PyObject *m;
    
    MyCallback_Type.tp_new = PyType_GenericNew;
    if (PyType_Ready(&MyCallback_Type) < 0) {
        return NULL;
    }
    
    m = PyModule_Create(&MyCallbackProxyDef);
    if (m == NULL) {
        return NULL;
    }
    
    Py_INCREF(&MyCallback_Type);
    PyModule_AddObject(m, "MyCallback", (PyObject *)&MyCallback_Type);
    return m;
}

