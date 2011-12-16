class Simple:
    def hello_(self, name: str):
        print("Hello %s!" % name)
        print("Now, let's try a hello from ObjC...")
        from ObjCHelloProxy import ObjCHelloProxy
        proxy = ObjCHelloProxy()
        proxy.helloToName_(name)
    
    def addNumbersA_andB_(self, a: int, b: int) -> int:
        return a + b
    
