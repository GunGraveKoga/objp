#import "ObjP.h"

PyObject* ObjP_findPythonClass(NSString *className, NSString *inModule)
{
    PyObject *pModule, *pClass;
    if (inModule == nil) {
        pModule = PyImport_AddModule("__main__");
    }
    else {
        pModule = PyImport_ImportModule([inModule UTF8String]);
    }
    OBJP_ERRCHECK(pModule);
    pClass = PyObject_GetAttrString(pModule, [className UTF8String]);
    OBJP_ERRCHECK(pClass);
    if (inModule != nil) {
        Py_DECREF(pModule);
    }
    return pClass;
}

PyObject* ObjP_classInstanceWithRef(NSString *className, NSString *inModule, id ref)
{
    PyObject *pClass, *pRefCapsule, *pResult;
    pClass = ObjP_findPythonClass(className, inModule);
    pRefCapsule = PyCapsule_New(ref, NULL, NULL);
    OBJP_ERRCHECK(pRefCapsule);
    pResult = PyObject_CallFunctionObjArgs(pClass, pRefCapsule, NULL);
    OBJP_ERRCHECK(pResult);
    Py_DECREF(pClass);
    Py_DECREF(pRefCapsule);
    return pResult;
}

void ObjP_raisePyExceptionInCocoa(void)
{
    PyObject* pExcType;
    PyObject* pExcValue;
    PyObject* pExcTraceback;
    PyErr_Fetch(&pExcType, &pExcValue, &pExcTraceback);
    if (pExcType == NULL) {
        return;
    }
    PyErr_NormalizeException(&pExcType, &pExcValue, &pExcTraceback);

    PyObject *pErrType = PyObject_Str(pExcType);
    PyObject *pErrMsg = PyObject_Str(pExcValue);
    NSString *errType = ObjP_str_p2o(pErrType);
    NSString *errMsg = ObjP_str_p2o(pErrMsg);
    NSString *reason = [NSString stringWithFormat:@"%@: %@", errType, errMsg];
    NSException *exc = [NSException exceptionWithName:@"PythonException" reason:reason userInfo:nil];
    Py_DECREF(pErrType);
    Py_DECREF(pErrMsg);
    // PyErr_Fetch cleared the exception so we have to restore it if we want to print it
    PyErr_Restore(pExcType, pExcValue, pExcTraceback);
    PyErr_Print(); // Cleared again
    Py_DECREF(pExcType);
    Py_XDECREF(pExcValue);
    Py_XDECREF(pExcTraceback);
    @throw exc;
}

NSString* ObjP_str_p2o(PyObject *pStr)
{
    PyObject *pBytes = PyUnicode_AsUTF8String(pStr);
    OBJP_ERRCHECK(pBytes);
    char *utf8Bytes = PyBytes_AS_STRING(pBytes);
    NSString *result = [NSString stringWithUTF8String:utf8Bytes];
    Py_DECREF(pBytes);
    return result;
}

PyObject* ObjP_str_o2p(NSString *str)
{
    PyObject *pResult = PyUnicode_FromString([str UTF8String]);
    OBJP_ERRCHECK(pResult);
    return pResult;
}

NSInteger ObjP_int_p2o(PyObject *pInt)
{
    return PyLong_AsLong(pInt);
}

PyObject* ObjP_int_o2p(NSInteger i)
{
    PyObject *pResult = PyLong_FromLong(i);
    OBJP_ERRCHECK(pResult);
    return pResult;
}

BOOL ObjP_bool_p2o(PyObject *pBool)
{
    return PyObject_IsTrue(pBool);
}

PyObject* ObjP_bool_o2p(BOOL b)
{
    if (b) {
        Py_RETURN_TRUE;
    }
    else {
        Py_RETURN_FALSE;
    }
}

NSObject* ObjP_obj_p2o(PyObject *pObj)
{
    if (pObj == Py_None) {
        return nil;
    }
    else if (PyUnicode_Check(pObj)) {
        return ObjP_str_p2o(pObj);
    }
    else if (PyLong_Check(pObj)) {
        return [NSNumber numberWithInt:ObjP_int_p2o(pObj)];
    }
    else if (PyBool_Check(pObj)) {
        return [NSNumber numberWithBool:ObjP_bool_p2o(pObj)];
    }
    else if (PySequence_Check(pObj)) {
        return ObjP_list_p2o(pObj);
    }
    else if (PyDict_Check(pObj)) {
        return ObjP_dict_p2o(pObj);
    }
    else {
        NSLog(@"Warning, ObjP_obj_p2o failed.");
        return nil;
    }
}

PyObject* ObjP_obj_o2p(NSObject *obj)
{
    if (obj == nil) {
        Py_RETURN_NONE;
    }
    else if ([obj isKindOfClass:[NSString class]]) {
        return ObjP_str_o2p((NSString *)obj);
    }
    else if ([obj isKindOfClass:[NSNumber class]]) {
        return ObjP_int_o2p([(NSNumber *)obj intValue]);
    }
    else if ([obj isKindOfClass:[NSArray class]]) {
        return ObjP_list_o2p((NSArray *)obj);
    }
    else if ([obj isKindOfClass:[NSDictionary class]]) {
        return ObjP_dict_o2p((NSDictionary *)obj);
    }
    else {
        return NULL;
    }
}

NSArray* ObjP_list_p2o(PyObject *pList)
{
    PyObject *iterator = PyObject_GetIter(pList);
    OBJP_ERRCHECK(iterator);
    PyObject *item;
    NSMutableArray *result = [NSMutableArray array];
    while ( (item = PyIter_Next(iterator)) ) {
        OBJP_ERRCHECK(item);
        [result addObject:ObjP_obj_p2o(item)];
        Py_DECREF(item);
    }
    Py_DECREF(iterator);
    return result;
}

PyObject* ObjP_list_o2p(NSArray *list)
{
    PyObject *pResult = PyList_New([list count]);
    OBJP_ERRCHECK(pResult);
    NSInteger i;
    for (i=0; i<[list count]; i++) {
        NSObject *obj = [list objectAtIndex:i];
        PyObject *pItem = ObjP_obj_o2p(obj);
        PyList_SET_ITEM(pResult, i, pItem);
    }
    return pResult;
}

NSDictionary* ObjP_dict_p2o(PyObject *pDict)
{
    PyObject *pKey, *pValue;
    Py_ssize_t pos = 0;
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    while (PyDict_Next(pDict, &pos, &pKey, &pValue)) {
        OBJP_ERRCHECK(pKey);
        OBJP_ERRCHECK(pValue);
        NSString *key = ObjP_str_p2o(pKey);
        NSObject *value = ObjP_obj_p2o(pValue);
        [result setObject:value forKey:key];
    }
    return result;
}

PyObject* ObjP_dict_o2p(NSDictionary *dict)
{
    PyObject *pResult = PyDict_New();
    OBJP_ERRCHECK(pResult);
    for (NSString *key in dict) {
        NSObject *value = [dict objectForKey:key];
        PyObject *pValue = ObjP_obj_o2p(value);
        PyDict_SetItemString(pResult, [key UTF8String], pValue);
        Py_DECREF(pValue);
    }
    return pResult;
}
