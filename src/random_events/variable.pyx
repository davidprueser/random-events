# cython: c_string_type=unicode, c_string_encoding=UTF8

from typing_extensions import Self, Type, Dict, Any, Union
from .interval import reals
from .set import SetElement, Set, EMPTY_SET
from .sigma_algebra import AbstractCompositeSetJSON, EMPTY_SET_SYMBOL
from .utils import SubclassJSONSerializer


cdef class Variable:

    def __init__(self, str name, AbstractCompositeSet domain):
        self.name = name
        self.domain = domain
        self.json_serializer = VariableJSON(self)

    def __lt__(self, Variable other) -> bool:
        """
        Returns True if self < other, False otherwise.
        """
        return self.name < other.name

    def __gt__(self, Variable other) -> bool:
        """
        Returns True if self > other, False otherwise.
        """
        return self.name > other.name

    def __hash__(self) -> int:
        return self.name.__hash__()

    def __eq__(self, Variable other):
        return self.name == other.name

    def __str__(self):
        return f"{self.__class__.__name__}({self.name}, {self.domain})"

    def __repr__(self):
        return f"{self.__class__.__name__}({self.name})"

    def to_json(self):
        return self.json_serializer.to_json()


class VariableJSON(SubclassJSONSerializer):
    def __init__(self, Variable var):
        self.var = var

    def to_json(self) -> Dict[str, Any]:
        return {
            **super().to_json(),
            "name": self.var.name,
            "domain": self.var.domain.to_json()
        }

    @staticmethod
    def _from_json(data: Dict[str, Any]):
        return Variable(data["name"], AbstractCompositeSetJSON.from_json(data["domain"]))


cdef class Continuous(Variable):
    """
    Class for continuous random variables.

    The domain of a continuous variable is the real line.
    """

    def __init__(self, str name, domain=None):
        super().__init__(name, reals())
        cdef const char* cpp_name = name
        self.cpp_continuous_object = new CPPContinuous(cpp_name)
        self.cpp_object = self.cpp_continuous_object


cdef class Symbolic(Variable):
    """
    Class for unordered, finite, discrete random variables.

    The domain of a symbolic variable is a set of values from an enumeration.
    """

    def __init__(self, str name, domain: Union[set, Set]):
        """
        Construct a symbolic variable.
        :param name: The name.
        :param domain: The class that lists all elements of the domain.
        """
        if isinstance(domain, set):
            self.domain = Set(*[SetElement(value, domain) for value in domain if value != EMPTY_SET_SYMBOL])
        else:
            self.domain = domain
        super().__init__(name, self.domain)

        cdef const char* cpp_name = name
        self.cpp_symbolic_object = new CPPSymbolic(cpp_name, shared_ptr[CPPSet](<CPPSet*> self.domain.cpp_object))
        self.cpp_object = self.cpp_symbolic_object

    def domain_type(self) -> Type[SetElement]:
        return self.domain.simple_sets[0].all_elements


cdef class Integer(Variable):
    """
    Class for ordered, discrete random variables.

    The domain of an integer variable is the number line.
    """

    def __init__(self, str name, domain=None):
        super().__init__(name, reals())
        cdef const char* cpp_name = name
        self.cpp_integer_object = new CPPInteger(cpp_name)
        self.cpp_object = self.cpp_integer_object
