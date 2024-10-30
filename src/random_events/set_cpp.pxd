from random_events.sigma_algebra_cpp cimport (CPPAbstractSimpleSet, CPPAbstractSimpleSetPtr_t, SimpleSetSetPtr_t,
CPPAbstractCompositeSet, CPPAbstractCompositeSetPtr_t, ElementaryVariant)
from libcpp.memory cimport shared_ptr
from libcpp.string cimport string
from libcpp.set cimport set
from libcpp cimport bool

cdef extern from "set_cpp.h":

    ctypedef set[int] CPPAllSetElements_t
    ctypedef shared_ptr[CPPAllSetElements_t] CPPAllSetElementsPtr_t
    ctypedef shared_ptr[CPPSetElement] CPPSetElementPtr_t

    ctypedef shared_ptr[CPPSet] CPPSetPtr_t

    cdef cppclass CPPSetElement(CPPAbstractSimpleSet):
        int element_index;
        int all_elements_length;

        CPPSetElement()

        CPPSetElement(int element_index, int all_elements_index);


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
        CPPSet()
        CPPSet(const SimpleSetSetPtr_t &simple_sets_)
        CPPSet(SimpleSetSetPtr_t &simple_sets_)
        CPPSet(CPPSetElement &set_element)

        CPPAbstractCompositeSetPtr_t simplify()

        CPPAbstractCompositeSetPtr_t make_new_empty() const

        string *non_empty_to_string()

        string *to_string()
