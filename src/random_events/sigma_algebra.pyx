from __future__ import annotations
import itertools
from abc import abstractmethod

from sortedcontainers import SortedSet
from typing_extensions import Self, TYPE_CHECKING, Type, Dict, Any
from random_events.utils import SubclassJSONSerializer

EMPTY_SET_SYMBOL = "∅"


cdef class AbstractSimpleSet:
    """
    Abstract class for simple sets.

    Simple sets are sets that can be represented as a single object.
    """

    def __init__(self):
        self.cpp_object = new CPPAbstractSimpleSet()

    # def __dealloc__(self):
    #     del self.cpp_object

    cdef const CPPAbstractSimpleSetPtr_t as_cpp_simple_set(self):
        """
        Convert this simple set to a C++ simple set.
        :return: The C++ simple set
        """
        raise NotImplementedError

    cdef const SimpleSetSetPtr_t as_cpp_simple_set_set(self):
        """
        Convert this simple set to a C++ set of simple sets.
        :return: The C++ set of simple sets
        """
        raise NotImplementedError

    @staticmethod
    cdef AbstractSimpleSet from_cpp_si(CPPAbstractSimpleSetPtr_t simple_set):
        """
        Convert a C++ simple set to a Python simple set.
        :param simple_set: The C++ simple set
        """
        raise NotImplementedError

    cdef from_cpp_simple_set_set(self, SimpleSetSetPtr_t simple_set_set):
        """
        Convert a C++ simple set to a Python simple set.
        :param simple_set_set: The C++ set of simple set
        """
        raise NotImplementedError

    cpdef AbstractSimpleSet intersection_with(self, AbstractSimpleSet other):
        """
        Form the intersection of this object with another object.

        :param other: The other SimpleSet
        :return: The intersection of this set with the other set
        """
        raise NotImplementedError

    cdef complement(self):
        """
        :return: The complement of this set as disjoint set of simple sets.
        """
        raise NotImplementedError

    # @abstractmethod
    cpdef bint is_empty(self) except *:
        """
        :return: Rather this set is empty or not.
        """
        raise NotImplementedError

    # @abstractmethod
    cpdef bint contains(self, float item) except *:
        """
        Check if this set contains an item.
        :param item: The item to check
        :return: Rather if the item is in the set or not
        """
        raise NotImplementedError

    # @abstractmethod
    def __hash__(self):
        raise NotImplementedError

    cdef str non_empty_to_string(self):
        """
        :return: A string representation of this set if it is not empty.
        """
        raise NotImplementedError

    cpdef difference_with(self, AbstractSimpleSet other):
        """
        Form the difference of this object with another object.

        :param other: The other SimpleSet
        :return: The difference as disjoint set of simple sets.
        """
        return self.from_cpp_simple_set_set(self.cpp_object.difference_with(other.as_cpp_simple_set()))

    cpdef str to_string(self):
        """
        :return: A string representation of this set.
        """
        return self.cpp_object.to_string().decode('utf-8', 'replace')

    def __str__(self):
        return self.to_string()

    # @abstractmethod
    def __lt__(self, other):
        raise NotImplementedError

    # @abstractmethod
    cpdef AbstractCompositeSet as_composite_set(self):
        """
        Convert this simple set to a composite set.
        :return: The composite set
        """
        raise NotImplementedError


cdef class AbstractCompositeSet:
    """
    Abstract class for composite sets.

    AbstractCompositeSet is a set that is composed of a disjoint union of simple sets.
    """

    def __cinit__(self):
        self.cpp_object = new CPPAbstractCompositeSet()

    def __init__(self, *simple_sets_py):
        cdef AbstractSimpleSet simple_set
        for simple_set in simple_sets_py:
            self.cpp_object.simple_sets.get().insert(simple_set.as_cpp_simple_set())

    def __dealloc__(self):
        del self.cpp_object

    cdef const CPPAbstractCompositeSetPtr_t as_cpp_composite_set(self):
        """
        Convert this composite set to a C++ composite set.
        :return: The C++ composite set
        """
        raise NotImplementedError

    cdef AbstractCompositeSet from_cpp_composite_set(self, CPPAbstractCompositeSetPtr_t composite_set):
        """
        Convert a C++ composite set to a Python composite set.
        :param composite_set: The C++ composite set
        """
        raise NotImplementedError

    cdef from_cpp_composite_set_set(self, SimpleSetSetPtr_t composite_set_set):
        """
        Convert a C++ composite set to a Python composite set.
        :param composite_set_set: The C++ set of composite set
        """
        raise NotImplementedError

    # @abstractmethod
    cpdef AbstractCompositeSet simplify(self):
        """
        Simplify this set into an equivalent, more compact version.

        :return: The simplified set
        """
        raise NotImplementedError

    # @abstractmethod
    cpdef AbstractCompositeSet new_empty_set(self):
        """
        Create a new empty set.

        This method has to be implemented by the subclass and should take over all the relevant attributes to the new
        set.

        :return: A new empty set.
        """
        raise NotImplementedError

    cpdef AbstractCompositeSet union_with(self, AbstractCompositeSet other):
        """
        Form the union of this object with another object.

        :param other: The other set
        :return: The union of this set with the other set
        """
        return self.from_cpp_composite_set(self.cpp_object.union_with(other.as_cpp_composite_set()))

    def __or__(self, AbstractCompositeSet other):
        return self.union_with(other)

    cpdef AbstractCompositeSet intersection_with_simple_set(self, AbstractSimpleSet other):
        """
        Form the intersection of this object with a simple set.

        :param other: The simple set
        :return: The intersection of this set with the simple set
        """
        return self.from_cpp_composite_set(self.cpp_object.intersection_with(other.as_cpp_simple_set()))
    #
    cpdef AbstractCompositeSet intersection_with_simple_sets(self, set_of_simple_sets):
        """
        Form the intersection of this object with a set of simple sets.

        :param set_of_simple_sets: The set of simple sets
        :return: The intersection of this set with the set of simple sets
        """
        cdef SimpleSetSetPtr_t cpp_set_of_simple_sets = <SimpleSetSetPtr_t> [simple_set.as_cpp_simple_set()
                                                                             for simple_set in set_of_simple_sets]

        return self.from_cpp_composite_set(self.cpp_object.intersection_with(cpp_set_of_simple_sets))

    cpdef AbstractCompositeSet intersection_with(self, AbstractCompositeSet other):
        """
        Form the intersection of this object with another object.
        :param other: The other set
        :return: The intersection of this set with the other set
        """
        # return self.intersection_with_simple_sets(other.simple_sets)
        return self.from_cpp_composite_set(self.cpp_object.intersection_with(other.cpp_object.simple_sets))

    def __and__(self, other):
        return self.intersection_with(other)

    cpdef AbstractCompositeSet difference_with_simple_set(self, AbstractSimpleSet other):
        """
        Form the difference with another composite set.
        :param other: The other set
        :return: The difference of this set with the other set
        """
        return self.from_cpp_composite_set(self.cpp_object.difference_with(other.as_cpp_simple_set()))
    #
    cpdef AbstractCompositeSet difference_with_simple_sets(self, other):
        cdef SimpleSetSetPtr_t cpp_set_of_simple_sets = <SimpleSetSetPtr_t> [simple_set.as_cpp_simple_set()
                                                                             for simple_set in other]
        cdef AbstractCompositeSet result = self.new_empty_set()
        result.cpp_object.simple_sets = cpp_set_of_simple_sets
        return self.from_cpp_composite_set(self.cpp_object.difference_with(result.as_cpp_composite_set()))

    cpdef AbstractCompositeSet difference_with(self, AbstractCompositeSet other):
        """
        Form the difference with another composite set.
        :param other: The other set
        :return: The difference of this set with the other set
        """
        return self.from_cpp_composite_set(self.cpp_object.difference_with(other.as_cpp_composite_set()))

    def __sub__(self, AbstractCompositeSet other):
        return self.difference_with(other)

    cpdef AbstractCompositeSet complement(self):
        """
        :return: The complement of this set
        """
        return self.from_cpp_composite_set(self.cpp_object.complement())

#     @abstractmethod
    cpdef AbstractCompositeSet complement_if_empty(self):
        """
        :return: The complement of this if it is empty.
        """
        raise NotImplementedError

    def __invert__(self):
        return self.complement()

    cpdef bint is_empty(self):
        """
        Check if this set is empty.
        """
        return self.cpp_object.simple_sets.get().size() == 0

    cpdef bint contains(self, float item):
        """
        Check if this set contains an item.
        :param item: The item to check
        :return: Rather if the item is in the set or not
        """
        for simple_set in self.cpp_object.simple_sets.get()[0]:
            if AbstractSimpleSet.from_cpp_si(simple_set).contains(item):
                return True
        return False

    def __contains__(self, item):
        return self.contains(item)

    cpdef str to_string(self):
        """
        :return: A string representation of this set.
        """
        return self.cpp_object.to_string().decode('utf-8', 'replace')

    def __str__(self):
        return self.to_string()

    def __repr__(self):
        return self.to_string()

    cpdef bint is_disjoint(self):
        """
        :return: Rather if the simple sets are disjoint or not.
        """
        return self.cpp_object.is_disjoint()

    cdef split_into_disjoint_and_non_disjoint(self):
        """
        Split this composite set into disjoint and non-disjoint parts.

        This method is required for making the composite set disjoint.
        The partitioning is done by removing every other simple set from every simple set.
        The purified simple sets are then disjoint by definition and the pairwise intersections are (potentially) not
        disjoint yet.

        This method requires:
            - the intersection of two simple sets as a simple set
            - the difference_of_a_with_every_b of a simple set (A) and another simple set (B) that is completely contained in A (B ⊆ A).
            The result of that difference_of_a_with_every_b has to be a composite set with only one simple set in it.

        :return: A tuple of the disjoint and non-disjoint set.
        """
        cdef tuple[CPPAbstractCompositeSetPtr_t, CPPAbstractCompositeSetPtr_t] result = self.cpp_object.split_into_disjoint_and_non_disjoint()
        return self.from_cpp_composite_set(result[0]), self.from_cpp_composite_set(result[1])

    cpdef AbstractCompositeSet make_disjoint(self):
        """
        Create an equal composite set that contains a disjoint union of simple sets.

        :return: The disjoint set.
        """
        return self.from_cpp_composite_set(self.cpp_object.make_disjoint())

    def __eq__(self, AbstractCompositeSet other):
        return self.cpp_object == other.cpp_object

    def __hash__(self):
        return hash(tuple(self.from_cpp_composite_set_set(self.cpp_object.simple_sets)))

    def __iter__(self):
        return iter(self.from_cpp_composite_set_set(self.cpp_object.simple_sets))

    def __lt__(self, AbstractCompositeSet other):
        """
        Compare this set with another set.

        The sets are compared by comparing the simple sets in order.
        If the pair of simple sets are equal, the next pair is compared.
        If all pairs are equal, the set with the least amount of simple sets is considered smaller.

        ..note:: This does not define a total order in the mathematical sense. In the mathematical sense, this defines
            a partial order.

        :param other: The other set
        :return: Rather this set is smaller than the other set
        """
        return self.cpp_object < other.cpp_object


class AbstractCompositeSetPy(SubclassJSONSerializer, AbstractCompositeSet):
    """
    Python class for Abstract Composite Sets. Needed for JSON serialization.
    """

    def to_json(self) -> Dict[str, Any]:
        return {**super().to_json(), "simple_sets": [simple_set.to_json() for simple_set in self.simple_sets]}

    @classmethod
    def _from_json(cls, data: Dict[str, Any]) -> Self:
        return cls(*[AbstractSimpleSet.from_json(simple_set) for simple_set in data["simple_sets"]])



# Type definitions
# if TYPE_CHECKING:
#     SimpleSetContainer = SortedSet[AbstractSimpleSet]
# else:
#     SimpleSetContainer = SortedSet
