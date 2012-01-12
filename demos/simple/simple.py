from objp.util import dontwrap

class Simple:
    def hello_(self, name: str):
        print("Hello %s!" % name)
        print("Now, let's try a hello from ObjC...")
        from ObjCHello import ObjCHello
        proxy = ObjCHello()
        proxy.helloToName_(name)
        print("Oh, and also: the answer to life is %d" % proxy.answerToLife())
        print("Additionally, a dict of all answers supported by our awesome app: %r" % proxy.answersDict())
    
    def addNumbersA_andB_(self, a: int, b: int) -> int:
        return a + b
    
    def doubleNumbers_(self, numbers: list) -> list:
        return [i*2 for i in numbers]
    
    @dontwrap
    def foobar(self):
        print("This method shouldn't be wrapped by objp because we tell it so.")
