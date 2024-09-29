# distutils: sources = sigma_algebra_cpp.cpp

from libcpp.memory cimport shared_ptr
from libcpp cimport bool
from libcpp.set cimport set
from libcpp.string cimport string
from libcpp.utility cimport pair

cdef extern from "sigma_algebra_cpp.h":

    ctypedef shared_ptr[CPPAbstractSimpleSet] CPPAbstractSimpleSetPtr_t;
    ctypedef shared_ptr[CPPAbstractCompositeSet] CPPAbstractCompositeSetPtr_t;

    ctypedef set[CPPAbstractSimpleSetPtr_t] SimpleSetSet_t;
    ctypedef shared_ptr[SimpleSetSet_t] SimpleSetSetPtr_t;

    cdef union ElementaryVariant:
        float *f
        int *i
        string *s


    cdef cppclass CPPAbstractSimpleSet:
        bool operator==(const CPPAbstractSimpleSet &other)
        bool operator<(const CPPAbstractSimpleSet &other)
        bool operator<=(const CPPAbstractSimpleSet &other)
        bool operator!=(const CPPAbstractSimpleSet &other)
        bool operator>(const CPPAbstractSimpleSet &other)
        bool operator>=(const CPPAbstractSimpleSet &other)


        CPPAbstractSimpleSetPtr_t intersection_with(const CPPAbstractSimpleSetPtr_t &other)
        SimpleSetSetPtr_t complement()
        bool contains(ElementaryVariant *element)
        bool is_empty()
        SimpleSetSetPtr_t difference_with(const CPPAbstractSimpleSetPtr_t &other)
        string to_string()


    cdef cppclass CPPAbstractCompositeSet:
        SimpleSetSetPtr_t simple_sets

        CPPAbstractCompositeSetPtr_t simplify()
        bool is_empty()
        bool is_disjoint()
        CPPAbstractCompositeSetPtr_t union_with(const CPPAbstractSimpleSetPtr_t &other) const
        CPPAbstractCompositeSetPtr_t union_with(const CPPAbstractCompositeSetPtr_t &other)
        CPPAbstractCompositeSetPtr_t intersection_with(const CPPAbstractSimpleSetPtr_t &simple_set)
        CPPAbstractCompositeSetPtr_t intersection_with(const SimpleSetSetPtr_t &other)
        CPPAbstractCompositeSetPtr_t intersection_with(const CPPAbstractCompositeSetPtr_t &other)
        CPPAbstractCompositeSetPtr_t make_disjoint()
        pair[CPPAbstractCompositeSetPtr_t, CPPAbstractCompositeSetPtr_t] split_into_disjoint_and_non_disjoint()
        CPPAbstractCompositeSetPtr_t difference_with(const CPPAbstractSimpleSetPtr_t &other)
        CPPAbstractCompositeSetPtr_t difference_with(const CPPAbstractCompositeSetPtr_t &other)
        bool contains(CPPAbstractCompositeSetPtr_t &other)
        string to_string()
        CPPAbstractCompositeSetPtr_t complement()



