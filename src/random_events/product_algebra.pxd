from typing_extensions import TYPE_CHECKING, Any, Tuple
from sortedcontainers import SortedDict, SortedValuesView

from random_events.variable cimport Variable
from random_events.sigma_algebra cimport AbstractSimpleSet, AbstractCompositeSet
from random_events.sigma_algebra_cpp cimport CPPAbstractSimpleSet, CPPAbstractCompositeSet, CPPAbstractSimpleSetPtr_t, CPPAbstractCompositeSetPtr_t
from random_events.interval cimport Interval, SimpleInterval
from random_events.product_algebra_cpp cimport SimpleEvent as CPPSimpleEvent, Event as CPPEvent, EventPtr_t
from libcpp.memory cimport shared_ptr
from random_events.variable_cpp cimport AbstractVariable, VariableMapPtr_t, VariableSetPtr_t, AbstractVariablePtr_t, VariableSet as CPPVariableSet, VariableMap
from libcpp.set cimport set as cpp_set
from libcpp.pair cimport pair

# Type definitions
if TYPE_CHECKING:
    VariableMapSuperClassType = SortedDict[Variable, Any]
else:
    VariableMapSuperClassType = SortedDict


cdef class SimpleEvent(AbstractSimpleSet):
    cdef CPPSimpleEvent *cpp_simple_event_object

    cdef public elements
    cdef public sorted


    cpdef Variable variable_of(self, str name)

    cpdef AbstractCompositeSet as_composite_set(self)

    # cpdef AbstractSimpleSet intersection_with(self, AbstractSimpleSet other)
    #
    # cpdef complement(self)

    cpdef SimpleEvent marginal(self, variable)

    cpdef str non_empty_to_string(self)


cdef class Event(AbstractCompositeSet):

    cdef void fill_missing_variables(self)

    cpdef AbstractCompositeSet simplify(self)

    # cpdef tuple[Event, bint] simplify_once(self)


