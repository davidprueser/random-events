from libcpp cimport bool

cdef extern from "simple_interval.hpp":
    cdef cppclass CPPSimpleInterval:
        float lower
        float upper
        int left
        int right

        CPPSimpleInterval(float lower=0, float upper=0, int left=0, int right=0)
        bool operator<(const CPPSimpleInterval& other) const
        bool operator==(const CPPSimpleInterval& other) const
