#import <Cocoa/Cocoa.h>
#import <Python.h>
#import "Simple.h"

void hello_from_python()
{
    Py_Initialize();
    NSString *path = [NSProcessInfo.processInfo.arguments[0] stringByDeletingLastPathComponent];
    NSUInteger bytes = [path lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    PyObject *pypath = PyUnicode_DecodeUTF8([path fileSystemRepresentation], bytes, NULL);
    PyObject *pysyspath = PySys_GetObject("path");
    PyList_Append(pysyspath, pypath);
    FILE* fp = fopen("simple.py", "r");
    PyRun_SimpleFile(fp, "simple.py");
    fclose(fp);
    Simple *foo = [[Simple alloc] init];
    [foo hello:@"Virgil"];
    NSLog(@"added numbers: %ld", [foo addNumbersA:42 andB:45]);
	NSArray *numbers = [NSArray arrayWithObjects:[NSNumber numberWithInt:12], [NSNumber numberWithInt:42], nil];
	NSLog(@"And here's a list of number doubled by Python: %@", [[foo doubleNumbers:numbers] description]);
    [foo release];
    Py_Finalize();
}

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    hello_from_python();
    [pool release];
    return 0;   
}