
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


- (void)execute
{
    PyObject *pResult, *pMethodName;
    pMethodName = PyUnicode_FromString("execute");
    pResult = PyObject_CallMethodObjArgs(py, pMethodName, NULL);
    Py_DECREF(pMethodName);
    Py_DECREF(pResult);
}

@end
