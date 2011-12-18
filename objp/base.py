import os.path as op
from collections import namedtuple

TypeSpec = namedtuple('TypeSpec', 'objctype o2p_code p2o_code')

TYPE_SPECS = {
    str: TypeSpec('NSString *', 'ObjP_str_o2p(%s)', 'ObjP_str_p2o(%s)'),
    int: TypeSpec('NSInteger', 'ObjP_int_o2p(%s)', 'ObjP_int_p2o(%s)'),
}

TYPE_SPECS_REVERSED = {ts.objctype: ts for ts in TYPE_SPECS.values()}

DATA_PATH = op.join(op.dirname(__file__), 'data')

def tmpl_replace(tmpl, **replacments):
    # Because we generate code and that code is likely to conatin "{}" braces, it's better if we
    # use more explicit placeholders than the typecal format() method. These placeholders are
    # %%name%%.
    result = tmpl
    for placeholder, replacement in replacments.items():
        result = result.replace('%%{}%%'.format(placeholder), replacement)
    return result
