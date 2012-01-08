
#define PY_SSIZE_T_CLEAN
#import <Python.h>
#import "structmember.h"
#import "ObjP.h"

#import <Cocoa/Cocoa.h>

@protocol MyProtocol <NSObject>
- (NSString *)getAnswer:(NSInteger)arg;
@end

typedef struct {
    PyObject_HEAD
    id <MyProtocol>objc_ref;
} MyProtocol_Struct;

static PyTypeObject MyProtocol_Type; /* Forward declaration */

/* Methods */

static void
MyProtocol_dealloc(MyProtocol_Struct *self)
{
    [self->objc_ref release];
    Py_TYPE(self)->tp_free((PyObject *)self);
}


static int
MyProtocol_init(MyProtocol_Struct *self, PyObject *args, PyObject *kwds)
{
    PyObject *pRefCapsule = NULL;
    if (!PyArg_ParseTuple(args, "|O", &pRefCapsule)) {
        return -1;
    }
    
    if (pRefCapsule == NULL) {
        self->objc_ref = NULL; // Never supposed to happen
    }
    else {
        self->objc_ref = PyCapsule_GetPointer(pRefCapsule, NULL);
        [self->objc_ref retain];
    }
    
    return 0;
}



static PyObject *
MyProtocol_getAnswer_(MyProtocol_Struct *self, PyObject *args)
{
    PyObject *parg;
    if (!PyArg_ParseTuple(args, "O", &parg)) {
        return NULL;
    }
    NSInteger arg = ObjP_int_p2o(parg);
    
    NSString * retval = [self->objc_ref getAnswer:arg];
    PyObject *pResult = ObjP_str_o2p(retval); return pResult;
}


static PyMethodDef MyProtocol_methods[] = {
 
{"getAnswer_", (PyCFunction)MyProtocol_getAnswer_, METH_VARARGS, ""},

{NULL}  /* Sentinel */
};

static PyTypeObject MyProtocol_Type = {
    PyVarObject_HEAD_INIT(NULL, 0)
    "MyProtocol.MyProtocol", /*tp_name*/
    sizeof(MyProtocol_Struct), /*tp_basicsize*/
    0, /*tp_itemsize*/
    (destructor)MyProtocol_dealloc, /*tp_dealloc*/
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
    "MyProtocol object", /* tp_doc */
    0, /* tp_traverse */
    0, /* tp_clear */
    0, /* tp_richcompare */
    0, /* tp_weaklistoffset */
    0, /* tp_iter */
    0, /* tp_iternext */
    MyProtocol_methods,/* tp_methods */
    0, /* tp_members */
    0, /* tp_getset */
    0, /* tp_base */
    0, /* tp_dict */
    0, /* tp_descr_get */
    0, /* tp_descr_set */
    0, /* tp_dictoffset */
    (initproc)MyProtocol_init,      /* tp_init */
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

static struct PyModuleDef MyProtocolDef = {
    PyModuleDef_HEAD_INIT,
    "MyProtocol",
    NULL,
    -1,
    module_methods,
    NULL,
    NULL,
    NULL,
    NULL
};

PyObject *
PyInit_MyProtocol(void)
{
    PyObject *m;
    
    MyProtocol_Type.tp_new = PyType_GenericNew;
    if (PyType_Ready(&MyProtocol_Type) < 0) {
        return NULL;
    }
    
    m = PyModule_Create(&MyProtocolDef);
    if (m == NULL) {
        return NULL;
    }
    
    Py_INCREF(&MyProtocol_Type);
    PyModule_AddObject(m, "MyProtocol", (PyObject *)&MyProtocol_Type);
    return m;
}

