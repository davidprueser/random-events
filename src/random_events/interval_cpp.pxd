# distutils: sources = interval_cpp.cpp
from libcpp.string cimport string
from libcpp.set cimport set
from libcpp cimport bool
from libcpp.memory cimport shared_ptr
from sigma_algebra_cpp cimport (CPPAbstractSimpleSet, CPPAbstractCompositeSet, CPPAbstractSimpleSetPtr_t,
CPPAbstractCompositeSetPtr_t, SimpleSetSet_t, SimpleSetSetPtr_t, ElementaryVariant)


cdef extern from "interval_cpp.h":
    cdef enum BorderType:
        OPEN
        CLOSED

    ctypedef shared_ptr[CPPSimpleInterval] CPPSimpleIntervalPtr_t
    ctypedef shared_ptr[CPPInterval] CPPIntervalPtr_t

    cdef cppclass CPPSimpleInterval(CPPAbstractSimpleSet):
        float lower
        float upper
        BorderType left
        BorderType right

        CPPSimpleInterval()
        CPPSimpleInterval(float lower, float upper, BorderType left, BorderType right)
        bool operator==(const CPPAbstractSimpleSet &other)
        bool operator==(const CPPSimpleInterval &other) const
        bool operator<(const CPPAbstractSimpleSet &other)
        bool operator<(const CPPSimpleInterval &other) const
        bool operator<=(const CPPAbstractSimpleSet &other)
        bool operator<=(const CPPSimpleInterval &other) const


        bool is_empty()
        bool is_singleton()
        inline CPPAbstractSimpleSetPtr_t intersection_with(const CPPAbstractSimpleSetPtr_t &other)
        SimpleSetSetPtr_t complement()
        string *non_empty_to_string()
        bool contains(const ElementaryVariant *element) const
        bool contains(float x) const


    cdef cppclass CPPInterval(CPPAbstractCompositeSet):
        CPPInterval()
        CPPInterval(const SimpleSetSetPtr_t &simple_sets_)
        CPPInterval(SimpleSetSetPtr_t &simple_sets_)
        CPPInterval(CPPSimpleInterval &simple_interval)

        bool operator==(const CPPInterval &other) const
        bool operator!=(const CPPInterval &other) const

        CPPIntervalPtr_t simplify()
        bool is_singleton() const
        bool contains(float element) const
