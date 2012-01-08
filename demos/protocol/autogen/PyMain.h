
#import "ObjP.h"

@interface PyMain:OPProxy {}
- (id)initWithPyArgs:(PyObject *)args;
- (void)execute;
@end
