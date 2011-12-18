#import <Cocoa/Cocoa.h>
#import <Python.h>

@interface OPProxy : NSObject
{
    PyObject *py;
}
- (id)initwithClassName:(NSString *)name;
@end

// New reference
PyObject* ObjP_findPythonClass(NSString *name);
NSString* ObjP_str_p2o(PyObject *pStr);
PyObject* ObjP_str_o2p(NSString *str);
NSInteger ObjP_int_p2o(PyObject *pInt);
PyObject* ObjP_int_o2p(NSInteger i);