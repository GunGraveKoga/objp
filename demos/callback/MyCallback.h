#import <Cocoa/Cocoa.h>

@interface MyCallback : NSObject {}
- (void)thisIsCalledBackFromPython:(NSString *)arg;
@end