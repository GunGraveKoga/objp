#import <Cocoa/Cocoa.h>
#import <Python.h>
#import "Foo.h"
#import "Bar.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Py_Initialize();
    FILE* fp = fopen("main.py", "r");
    PyRun_SimpleFile(fp, "main.py");
    fclose(fp);
    Foo *foo = [[Foo alloc] init];
    [foo helloFromFoo];
    [foo release];
    Bar *bar = [[Bar alloc] init];
    [bar helloFromBar];
    [bar helloFromFoo];
    [bar release];
    Py_Finalize();
    [pool release];
    return 0;   
}