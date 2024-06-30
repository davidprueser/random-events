from libcpp cimport bool

cdef extern from "simple_interval.hpp":

    cdef cppclass CPPSimpleInterval:
        float lower
        float upper
        CPPBound left
        CPPBound right

        CPPSimpleInterval(float lower=0, float upper=0, CPPBound left=CPPBound.OPEN, CPPBound right=CPPBound.OPEN)
        bool operator<(const CPPSimpleInterval& other) const
        bool operator==(const CPPSimpleInterval& other) const
        bool is_empty() const
        bool is_singleton() const
        bool contains(float value) const
        float center() const

    enum CPPBound:
        OPEN = 0
        CLOSED = 1
