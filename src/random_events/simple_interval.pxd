# distutils: sources = simple_interval.cpp

from libcpp.set cimport set
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


    cdef cppclass CPPAbstractCompositeSet:
        set[CPPAbstractSimpleSet] *simple_sets;

        CPPAbstractCompositeSet()


        # CPPAbstractCompositeSetPtr_t make_new_empty() const
        # CPPAbstractCompositeSet split_into_disjoint_and_non_disjoint()
        # CPPAbstractCompositeSet
        # CPPAbstractCompositeSet
        # CPPAbstractCompositeSet
        # CPPAbstractCompositeSet