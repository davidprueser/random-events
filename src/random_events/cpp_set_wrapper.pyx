cdef class SetWrapper:

    def __init__(self):
        self.cpp_set = set[shared_ptr[SimpleInterval]]()

    cdef void insert(self, SimpleInterval obj):
        cdef shared_ptr[SimpleInterval] ptr = shared_ptr[SimpleInterval](SimpleInterval(
            obj.lower, obj.upper, obj.left, obj.right))
        self.cpp_set.insert(ptr)

    # def __contains__(self, SimpleInterval obj):
    #     cdef shared_ptr[SimpleInterval] ptr = shared_ptr[SimpleInterval](SimpleInterval(
    #         obj.lower, obj.upper, obj.left, obj.right))
    #     return self.cpp_set.contains(ptr)

    cdef size_t size(self):
        return self.cpp_set.size()
