import sys

class Main:
    def foo(self):
        class FooException(Exception): pass
        raise FooException("Exception from foo")
    
    def bar(self):
        class BarException(Exception): pass
        def excepthook(etype, e, tb):
            print("Excepthook called!")
        sys.excepthook = excepthook
        raise BarException("Exception from bar")
    
    def baz(self):
        class BazException(Exception): pass
        def excepthook(etype, e, tb):
            raise Exception("Exception during excepthook!")
        sys.excepthook = excepthook
        raise BazException("Exception from baz")
