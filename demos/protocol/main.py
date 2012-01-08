class PyMain:
    def __init__(self, callback):
        self.callback = callback
    
    def execute(self):
        print("Hello from Python. Let's do a callback on our class conforming to our protocol.")
        print(self.callback.getAnswer_(42))
