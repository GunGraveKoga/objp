
#import "ObjP.h"

@interface PyMain:OPProxy {}
- (id)initWithPyArgs:(PyObject *)args;
- (void)hello:(NSString *)name;
@end
