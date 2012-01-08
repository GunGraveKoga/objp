
#import "PyMain.h"

@implementation PyMain
- (id)initWithPyArgs:(PyObject *)args
{
    self = [super initwithClassName:@"PyMain" pyArgs:args];
    return self;
}

- (id)init
{
    return [self initWithPyArgs:NULL];
}


- (void)hello:(NSString *)name
{
    PyObject *pResult, *pMethodName;
    pMethodName = PyUnicode_FromString("hello_");
    pResult = PyObject_CallMethodObjArgs(py, pMethodName, ObjP_str_o2p(name), NULL);
    Py_DECREF(pMethodName);
    Py_DECREF(pResult);
}

@end
