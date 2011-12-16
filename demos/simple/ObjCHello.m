#import "ObjCHello.h"

@implementation ObjCHello
- (void)helloToName:(NSString *)name
{
    NSLog(@"Hello %@ from ObjC!", name);
}
@end
