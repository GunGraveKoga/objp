#import <Cocoa/Cocoa.h>
#import "ObjP.h"
#import "PyMain.h"
#import "MyCallback.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Py_Initialize();
    NSString *path = [NSProcessInfo.processInfo.arguments[0] stringByDeletingLastPathComponent];
    NSUInteger bytes = [path lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    PyObject *pypath = PyUnicode_DecodeUTF8([path fileSystemRepresentation], bytes, NULL);
    PyObject *pysyspath = PySys_GetObject("path");
    PyList_Append(pysyspath, pypath);
    FILE* fp = fopen("main.py", "r");
    PyRun_SimpleFile(fp, "main.py");
    fclose(fp);
    MyCallback *callback = [[MyCallback alloc] init];
    PyObject *pCallback = ObjP_classInstanceWithRef(@"MyCallback", @"MyCallbackProxy", callback);
    PyMain *foo = [[PyMain alloc] initWithCallback:pCallback];
    Py_DECREF(pCallback);
    [foo hello:@"Virgil"];
    [foo release];
    Py_Finalize();
    [pool release];
    return 0;   
}