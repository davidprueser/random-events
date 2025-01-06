from libcpp.memory cimport shared_ptr
from libcpp.string cimport string
from random_events.set_cpp cimport CPPSet, CPPSetPtr_t
from random_events.interval_cpp cimport CPPInterval, CPPIntervalPtr_t
from libcpp.set cimport set as cppset
from libcpp.map cimport map
from random_events.sigma_algebra_cpp cimport CPPAbstractCompositeSet, CPPAbstractCompositeSetPtr_t
from libcpp.typeinfo cimport type_info

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
        NamePtr_t name
        # CPPAbstractCompositeSetPtr_t domain
        int type

        AbstractVariable()
        AbstractVariable(const string &name)

        const type_info& get_type()
        CPPAbstractCompositeSetPtr_t get_domain()


    cdef cppclass Continuous(AbstractVariable):
        CPPIntervalPtr_t domain
        int type

        Continuous(const NamePtr_t &name)
        Continuous(const char* name)

        CPPIntervalPtr_t get_domain()


    cdef cppclass Symbolic(AbstractVariable):
        CPPSetPtr_t domain
        int type

        Symbolic(const NamePtr_t &name, const CPPSetPtr_t& domain)
        Symbolic(const char* name, const CPPSetPtr_t& domain)

        CPPSetPtr_t get_domain()


    cdef cppclass Integer(AbstractVariable):
        CPPIntervalPtr_t domain
        int type

        Integer(const NamePtr_t &name)
        Integer(const char* name)

        CPPIntervalPtr_t get_domain()

