from libcpp.memory cimport shared_ptr
from libcpp.string cimport string
from random_events.set_cpp cimport CPPSet, CPPSetPtr_t
from random_events.interval_cpp cimport CPPInterval, CPPIntervalPtr_t
from libcpp.set cimport set as cppset
from libcpp.map cimport map
from random_events.sigma_algebra_cpp cimport CPPAbstractCompositeSet

# ctypedef shared_ptr[CPPSet] SetPtr_t
ctypedef shared_ptr[string] NamePtr_t
ctypedef shared_ptr[AbstractVariable] AbstractVariablePtr_t
ctypedef shared_ptr[CPPAbstractCompositeSet] AbstractCompositeSetPtr_t
ctypedef map[AbstractVariablePtr_t, AbstractCompositeSetPtr_t] VariableMap
ctypedef shared_ptr[VariableMap] VariableMapPtr_t
ctypedef cppset[AbstractVariablePtr_t] VariableSet
ctypedef shared_ptr[VariableSet] VariableSetPtr_t


cdef extern from "variable_cpp.h":
    cdef cppclass AbstractVariable:
        string name

        AbstractVariable()
        AbstractVariable(const string &name)


    cdef cppclass Continuous(AbstractVariable):
        CPPIntervalPtr_t domain

        Continuous(const NamePtr_t &name)
        Continuous(const char* name)


    cdef cppclass Symbolic(AbstractVariable):
        CPPSetPtr_t domain

        Symbolic(const NamePtr_t &name, const CPPSetPtr_t& domain)
        Symbolic(const char* name, const CPPSetPtr_t& domain)


    cdef cppclass Integer(AbstractVariable):
        CPPIntervalPtr_t domain

        Integer(const NamePtr_t &name)
        Integer(const char* name)


