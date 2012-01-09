#import <Cocoa/Cocoa.h>
#import "ObjP.h"
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
    PyMain *foo = [[PyMain alloc] initWithCallback:pCallback];
    Py_DECREF(pCallback);
    [foo execute];
    [foo release];
    Py_Finalize();
    [pool release];
    return 0;   
}