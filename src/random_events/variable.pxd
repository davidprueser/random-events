from random_events.sigma_algebra cimport AbstractCompositeSet
from random_events.sigma_algebra_cpp cimport CPPAbstractCompositeSet
from random_events.set import Set
from libcpp.memory cimport shared_ptr, make_shared
from random_events.set_cpp cimport CPPSet
from libcpp.string cimport string
from random_events.variable_cpp cimport AbstractVariable, Continuous as CPPContinuous, Symbolic as CPPSymbolic, Integer as CPPInteger


cdef class Variable:
    cdef AbstractVariable *cpp_object

    cdef public string name
    cdef public AbstractCompositeSet domain
    cdef public json_serializer

cdef class Continuous(Variable):
    cdef CPPContinuous *cpp_continuous_object


cdef class Symbolic(Variable):
    cdef CPPSymbolic *cpp_symbolic_object


cdef class Integer(Variable):
    cdef CPPInteger *cpp_integer_object