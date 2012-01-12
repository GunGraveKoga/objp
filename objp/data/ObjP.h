#import <Cocoa/Cocoa.h>
#import <Python.h>

#define OBJP_ERRCHECK(x) if (x == NULL) {ObjP_raisePyExceptionInCocoa();}

PyObject* ObjP_findPythonClass(NSString *name, NSString *inModule);
PyObject* ObjP_classInstanceWithRef(NSString *className, NSString *inModule, id ref);
void ObjP_raisePyExceptionInCocoa(void);
NSString* ObjP_str_p2o(PyObject *pStr);
PyObject* ObjP_str_o2p(NSString *str);
NSInteger ObjP_int_p2o(PyObject *pInt);
PyObject* ObjP_int_o2p(NSInteger i);
BOOL ObjP_bool_p2o(PyObject *pBool);
PyObject* ObjP_bool_o2p(BOOL b);
NSObject* ObjP_obj_p2o(PyObject *pObj);
PyObject* ObjP_obj_o2p(NSObject *obj);
NSArray* ObjP_list_p2o(PyObject *pList);
PyObject* ObjP_list_o2p(NSArray *list);
NSDictionary* ObjP_dict_p2o(PyObject *pDict);
PyObject* ObjP_dict_o2p(NSDictionary *dict);
