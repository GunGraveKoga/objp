#import <Cocoa/Cocoa.h>
#import <Python.h>
#import "PyMain.h"
#import "MyClass.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Py_Initialize();
    FILE* fp = fopen("main.py", "r");
    PyRun_SimpleFile(fp, "main.py");
    fclose(fp);
    MyClass *callback = [[MyClass alloc] init];
    PyObject *pCallback = ObjP_classInstanceWithRef(@"MyProtocol", @"MyProtocol", callback);
    PyObject *pArgs = PyTuple_Pack(1, pCallback);
    PyMain *foo = [[PyMain alloc] initWithPyArgs:pArgs];
    Py_DECREF(pArgs);
    [foo execute];
    [foo release];
    Py_Finalize();
    [pool release];
    return 0;   
}