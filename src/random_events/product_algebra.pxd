from typing_extensions import TYPE_CHECKING, Any
from sortedcontainers import SortedDict
from random_events.variable cimport Variable
from random_events.sigma_algebra cimport AbstractSimpleSet, AbstractCompositeSet
from random_events.interval cimport Interval, SimpleInterval

# Type definitions
if TYPE_CHECKING:
    VariableMapSuperClassType = SortedDict[Variable, Any]
else:
    VariableMapSuperClassType = SortedDict


cdef class VariableMap(Variable):
    cdef public sorted
    cpdef Variable variable_of(self, str name)



