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