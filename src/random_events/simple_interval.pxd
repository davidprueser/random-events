from libcpp cimport bool

cdef extern from "simple_interval.h":
    cdef cppclass CPPAbstractSimpleSet:
        pass


    cdef cppclass CPPSimpleInterval(CPPAbstractSimpleSet):
        float lower
        float upper
        int left
        int right

        CPPSimpleInterval()
        CPPSimpleInterval(float lower, float upper, int left , int right)
        bool operator<(const CPPSimpleInterval& other) const
        bool operator==(const CPPSimpleInterval& other) const
