#import "MyClass.h"

@implementation MyClass
- (NSString *)getAnswer:(NSInteger)arg
{
    return [NSString stringWithFormat:@"The answer is %i.", arg];
}
@end
