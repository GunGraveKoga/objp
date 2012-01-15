#import <Cocoa/Cocoa.h>
#import <Python.h>
#import "Main.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    Py_Initialize();
    FILE* fp = fopen("main.py", "r");
    PyRun_SimpleFile(fp, "main.py");
    fclose(fp);
    Main *foo = [[Main alloc] init];
    @try {
        [foo foo];
    } @catch (NSException *e) {
        NSLog(@"foo exception caught.");
    }
    @try {
        [foo bar];
    } @catch (NSException *e) {
        NSLog(@"bar exception caught.");
    }
    @try {
        [foo baz];
    } @catch (NSException *e) {
        NSLog(@"baz exception caught.");
    }
    [foo release];
    Py_Finalize();
    [pool release];
    return 0;   
}