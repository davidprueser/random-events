# distutils: sources = interval_cpp.cpp
from libcpp.string cimport string
from libcpp.set cimport set
from libcpp cimport bool
from libcpp.memory cimport shared_ptr


cdef extern from "interval_cpp.h":
    cdef enum BorderType:
        OPEN
        CLOSED

    ctypedef shared_ptr[CPPSimpleInterval] CPPSimpleIntervalPtr_t
    ctypedef shared_ptr[CPPInterval] CPPIntervalPtr_t
    ctypedef set[CPPSimpleIntervalPtr_t] SimpleIntervalSet_t
    ctypedef shared_ptr[SimpleIntervalSet_t] SimpleIntervalSetPtr_t

    cdef cppclass CPPSimpleInterval:
        float lower
        float upper
        BorderType left
        BorderType right

        CPPSimpleInterval()
        CPPSimpleInterval(float lower, float upper, BorderType left, BorderType right)
        bool operator==(const CPPSimpleInterval &other) const
        bool operator<(const CPPSimpleInterval &other) const
        bool operator<=(const CPPSimpleInterval &other) const
        bool operator!=(const CPPSimpleInterval &other) const


        bool is_empty()
        bool is_singleton()
        CPPSimpleIntervalPtr_t intersection_with(const CPPSimpleIntervalPtr_t &other)
        SimpleIntervalSetPtr_t complement()
        string non_empty_to_string()
        bool contains(float x)


    cdef cppclass CPPInterval:
        SimpleIntervalSetPtr_t simple_sets;

        CPPInterval()
        CPPInterval(const SimpleIntervalSetPtr_t &simple_sets_)
        CPPInterval(SimpleIntervalSetPtr_t &simple_sets_)
        CPPInterval(CPPSimpleInterval &simple_interval)

        bool operator==(const CPPInterval &other) const
        bool operator!=(const CPPInterval &other) const

        CPPIntervalPtr_t simplify()
