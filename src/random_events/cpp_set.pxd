cimport cython
cdef extern from "<set>" namespace "std":
    cdef cppclass set[T]:
        set()
        bool insert(const T)
        bool contains(const T)
        size_t size()