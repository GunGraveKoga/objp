#import "MyCallback.h"

@implementation MyCallback
- (void)thisIsCalledBackFromPython:(NSString *)arg
{
    NSLog(@"Callback with arg %@ successful!", arg);
}
@end
