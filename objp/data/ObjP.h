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
NSString* ObjP_str2nsstring(PyObject *pStr);