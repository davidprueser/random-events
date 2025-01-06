from libcpp.memory cimport shared_ptr

from random_events.sigma_algebra_cpp cimport (CPPAbstractCompositeSet, CPPAbstractSimpleSet, SimpleSetSetPtr_t,
ElementaryVariant, CPPAbstractSimpleSetPtr_t, CPPAbstractCompositeSetPtr_t)
from libcpp.set cimport set as cpp_set
from libcpp.string cimport string
from random_events.interval cimport Interval
from random_events.set_cpp cimport CPPSet
from random_events.variable_cpp cimport AbstractVariable
from libcpp.map cimport map as cpp_map



cdef extern from "product_algebra_cpp.h":

    ctypedef shared_ptr[AbstractVariable] AbstractVariablePtr_t
    ctypedef cpp_map[AbstractVariablePtr_t, CPPAbstractCompositeSetPtr_t] VariableMap
    ctypedef shared_ptr[VariableMap] VariableMapPtr_t
    ctypedef shared_ptr[SimpleEvent] SimpleEventPtr_t
    ctypedef shared_ptr[Event] EventPtr_t
    ctypedef cpp_set[AbstractVariablePtr_t] VariableSet
    ctypedef shared_ptr[VariableSet] VariableSetPtr_t

    cdef cppclass SimpleEvent(CPPAbstractSimpleSet):
        VariableMapPtr_t variable_map

        SimpleEvent()
        SimpleEvent(VariableMapPtr_t &variable_map)
        SimpleEvent(const VariableSetPtr_t &variables)

        CPPAbstractSimpleSetPtr_t intersection_with(const CPPAbstractSimpleSetPtr_t &other)

        SimpleSetSetPtr_t complement()

        bint contains(const ElementaryVariant *element)

        bint is_empty()

    cdef cppclass Event(CPPAbstractCompositeSet):
        VariableSetPtr_t all_variables

        Event()
        Event(const Event &event)
        Event(const SimpleSetSetPtr_t &simple_events)
        Event(const SimpleEventPtr_t &simple_event)
        Event(const VariableSetPtr_t &variables)

        tuple[EventPtr_t, bint] simplify_once()
        CPPAbstractCompositeSetPtr_t make_new_empty()



