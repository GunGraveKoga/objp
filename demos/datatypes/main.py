from objp.util import nspoint, nssize, nsrect

class Main:
    def string_(self, arg: str) -> str:
        print('string', repr(arg))
        return arg
    
    def int_(self, arg: int) -> int:
        print('int', repr(arg))
        return arg
    
    def float_(self, arg: float) -> float:
        print('float', repr(arg))
        return arg
    
    def bool_(self, arg: bool) -> bool:
        print('bool', repr(arg))
        return arg
    
    def list_(self, arg: list) -> list:
        print('list', repr(arg))
        return arg
    
    def dict_(self, arg: dict) -> dict:
        print('dict', repr(arg))
        return arg
    
    def point_(self, arg: nspoint) -> nspoint:
        print('point', repr(arg))
        return arg
        
    def size_(self, arg: nssize) -> nssize:
        print('size', repr(arg))
        return arg
    
    def rect_(self, arg: nsrect) -> nsrect:
        print('rect', repr(arg))
        return arg
    
