from typing_extensions import TYPE_CHECKING, Any, Tuple
from sortedcontainers import SortedDict, SortedValuesView

from random_events.variable cimport Variable
from random_events.sigma_algebra cimport AbstractSimpleSet, AbstractCompositeSet
from random_events.sigma_algebra_cpp cimport CPPAbstractSimpleSet, CPPAbstractCompositeSet, CPPAbstractSimpleSetPtr_t, CPPAbstractCompositeSetPtr_t
from random_events.interval cimport Interval, SimpleInterval
from random_events.product_algebra_cpp cimport (SimpleEvent as CPPSimpleEvent, Event as CPPEvent, EventPtr_t, AbstractVariablePtr_t,
VariableMapPtr_t, VariableMap)
from libcpp.memory cimport shared_ptr, make_shared
from random_events.variable_cpp cimport AbstractVariable
from libcpp.set cimport set as cpp_set
from libcpp.pair cimport pair
from libcpp.map cimport map as cpp_map
from libcpp.typeinfo cimport type_info
from random_events.sigma_algebra cimport AbstractCompositeSet, AbstractSimpleSet
from random_events.variable cimport Variable, Continuous, Symbolic, Integer

# Type definitions
if TYPE_CHECKING:
    VariableMapSuperClassType = SortedDict[Variable, Any]
else:
    VariableMapSuperClassType = SortedDict


cdef class SimpleEvent(AbstractSimpleSet):
    cdef public sorted
    cdef CPPSimpleEvent *cpp_simple_event_object

    cdef AbstractSimpleSet from_cpp_simple_set(self, CPPAbstractSimpleSetPtr_t simple_set)

    cpdef Variable variable_of(self, str name)

    cpdef AbstractCompositeSet as_composite_set(self)

    cpdef bint contains(self, item) except *

    cpdef SimpleEvent marginal(self, variable)

    cpdef str non_empty_to_string(self)

    cpdef void fill_missing_variables(self, variables)


cdef class Event(AbstractCompositeSet):

    cdef void fill_missing_variables(self)

    cpdef AbstractCompositeSet simplify(self)

    # cpdef tuple[Event, bint] simplify_once(self)


