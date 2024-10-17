from typing_extensions import Self, Type, Dict, Any, Union

from .interval cimport Interval
from .interval import reals
from .set cimport SetElement, Set
from .sigma_algebra import AbstractCompositeSetJSON
from .utils import SubclassJSONSerializer


cdef class Variable:

    def __init__(self, str name, AbstractCompositeSet domain):
        self.name = name
        self.domain = domain
        self.json_serializer = VariableJSON(self)

    def __lt__(self, other: Self) -> bool:
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

    cpdef to_json(self):
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


class Continuous(Variable):
    """
    Class for continuous random variables.

    The domain of a continuous variable is the real line.
    """
    domain: Interval

    def __init__(self, name: str, domain=None):
        super().__init__(name, reals())

    def to_json(self) -> Dict[str, Any]:
        return self.json_serializer.to_json()


class Symbolic(Variable):
    """
    Class for unordered, finite, discrete random variables.

    The domain of a symbolic variable is a set of values from an enumeration.
    """
    domain: Set

    def __init__(self, name: str, domain: Union[Type[SetElement], SetElement]):
        """
        Construct a symbolic variable.
        :param name: The name.
        :param domain: The enum class that lists all elements of the domain.
        """
        if isinstance(domain, type) and issubclass(domain, SetElement):
            super().__init__(name, Set(*[value for value in domain if value != domain.EMPTY_SET]))
        else:
            super().__init__(name, domain)

    def domain_type(self) -> Type[SetElement]:
        return self.domain.simple_sets[0].all_elements

    def to_json(self) -> Dict[str, Any]:
        return self.json_serializer.to_json()


class Integer(Variable):
    """
    Class for ordered, discrete random variables.

    The domain of an integer variable is the number line.
    """
    domain: Interval

    def __init__(self, name: str, domain=None):
        super().__init__(name, reals())

    def to_json(self) -> Dict[str, Any]:
        return self.json_serializer.to_json()
