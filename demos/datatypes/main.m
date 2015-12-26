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
    NSLog(@"%@", [foo string:@"foo"]);
    NSLog(@"%li", [foo int:42]);
    NSLog(@"%f", [foo float:42.42]);
    NSLog(@"%i", [foo bool:YES]);
    // Make sure that we can convert all supported data types from a list.
    NSLog(@"%@", [foo list:[NSArray arrayWithObjects:@"foo", [NSNumber numberWithInt:42],
        [NSNumber numberWithFloat:42.42], [NSNumber numberWithBool:YES], [NSArray array],
        [NSDictionary dictionary], nil]]);
    NSLog(@"%@", [foo dict:[NSDictionary dictionaryWithObject:@"foo" forKey:@"bar"]]);
    NSPoint p = NSMakePoint(1, 2);
    NSPoint rp = [foo point:p];
    NSLog(@"%f %f", rp.x, rp.y);
    NSSize s = NSMakeSize(3, 4);
    NSSize rs = [foo size:s];
    NSLog(@"%f %f", rs.width, rs.height);
    NSRect r;
    r.origin = p;
    r.size = s;
    NSLog(@"%@", NSStringFromRect([foo rect:r]));
    Py_Finalize();
    [pool release];
    return 0;   
}