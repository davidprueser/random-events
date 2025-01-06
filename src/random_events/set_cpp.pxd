from random_events.sigma_algebra_cpp cimport (CPPAbstractSimpleSet, CPPAbstractSimpleSetPtr_t, SimpleSetSetPtr_t,
CPPAbstractCompositeSet, CPPAbstractCompositeSetPtr_t, ElementaryVariant)
from libcpp.memory cimport shared_ptr
from libcpp.string cimport string
from libcpp.set cimport set
from libcpp cimport bool

cdef extern from "set_cpp.h":

    ctypedef shared_ptr[int] CPPAllSetElementsPtr_t
    ctypedef shared_ptr[CPPSetElement] CPPSetElementPtr_t

    ctypedef shared_ptr[CPPSet] CPPSetPtr_t

    cdef cppclass CPPSetElement(CPPAbstractSimpleSet):
        int element_index;
        CPPAllSetElementsPtr_t all_elements_length;

        CPPSetElement()
        CPPSetElement(int element_index, const CPPAllSetElementsPtr_t &all_elements_length);

        CPPAbstractSimpleSetPtr_t intersection_with(const CPPAbstractSimpleSetPtr_t &other);

        SimpleSetSetPtr_t complement();

        string *non_empty_to_string();

        bool contains(const ElementaryVariant *element);

        bool is_empty();

        bool operator==(const CPPAbstractSimpleSet &other);
        bool operator==(const CPPSetElement &other);
        bool operator<(const CPPAbstractSimpleSet &other);
        bool operator<(const CPPSetElement &other);
        bool operator<=(const CPPAbstractSimpleSet &other);
        bool operator<=(const CPPSetElement &other);


    cdef cppclass CPPSet(CPPAbstractCompositeSet):
        CPPAllSetElementsPtr_t all_elements;

        CPPSet()
        CPPSet(const CPPAllSetElementsPtr_t &all_elements_)
        CPPSet(const SimpleSetSetPtr_t &simple_sets_, const CPPAllSetElementsPtr_t &all_elements_)
        CPPSet(const CPPSetElementPtr_t &set_element, const CPPAllSetElementsPtr_t &all_elements_)

        CPPAbstractCompositeSetPtr_t simplify()

        CPPAbstractCompositeSetPtr_t make_new_empty() const

        string *non_empty_to_string()

        string *to_string()
