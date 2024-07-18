from __future__ import annotations
import itertools
from sortedcontainers import SortedSet
from typing_extensions import Self, TYPE_CHECKING, Type, Dict, Any
from random_events.utils import SubclassJSONSerializer

EMPTY_SET_SYMBOL = "∅"


cdef class AbstractSimpleSet:
    """
    Abstract class for simple sets.

    Simple sets are sets that can be represented as a single object.
    """

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

        # if the intersection is empty
        intersection = self.intersection_with(other)
        if intersection.is_empty():
            # then the difference is the set itself
            return SortedSet([self])

        # form the complement of the intersection
        complement_of_intersection = intersection.complement()

        # for every element in the complement of the intersection
        result = SortedSet()
        for element in complement_of_intersection:

            # if it intersects with this set
            intersection = element.intersection_with(self)
            if not intersection.is_empty():
                # add the intersection to the result
                result.add(intersection)

        return result

    cpdef str to_string(self):
        """
        :return: A string representation of this set.
        """
        if self.is_empty():
            return EMPTY_SET_SYMBOL
        return self.non_empty_to_string()

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

    # def __cinit__(self):
    #     self.acs_ = new CPPAbstractCompositeSet()
    #
    # def __init__(self, *simple_sets_py : SimpleInterval):
    #     # self.simple_sets_py = simple_sets_py
    #     # self.acs_.simple_sets_cpp = simple_sets_py
    #     for simple_set in simple_sets_py:
    #         self.acs_.simple_sets.insert(<CPPSimpleInterval> simple_set.si_)

    # def __dealloc__(self):
    #     del self.acs_

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

    # cpdef AbstractCompositeSet union_with(self, AbstractCompositeSet other):
    #     """
    #     Form the union of this object with another object.
    #
    #     :param other: The other set
    #     :return: The union of this set with the other set
    #     """
    #     result = self.new_empty_set()
    #     result.simple_sets.insert(self.simple_sets.begin(), self.simple_sets.end())
    #     result.simple_sets.insert(other.simple_sets.begin(), other.simple_sets.end())
    #     return result.make_disjoint()
    #
    # def __or__(self, other: Self):
    #     return self.union_with(other)
    #
    # cdef AbstractCompositeSet intersection_with_simple_set(self, AbstractSimpleSet other):
    #     """
    #     Form the intersection of this object with a simple set.
    #
    #     :param other: The simple set
    #     :return: The intersection of this set with the simple set
    #     """
    #     result = self.new_empty_set()
    #     [result.add_simple_set(simple_set.intersection_with(other)) for simple_set in self.acs_.simple_sets]
    #     return result
    #
    # cdef AbstractCompositeSet intersection_with_simple_sets(self, other):
    #     """
    #     Form the intersection of this object with a set of simple sets.
    #
    #     :param other: The set of simple sets
    #     :return: The intersection of this set with the set of simple sets
    #     """
    #     result = self.new_empty_set()
    #     [result.simple_sets.insert(self.intersection_with_simple_set(other_simple_set).simple_sets) for other_simple_set
    #      in other]
    #     return result
    #
    # cpdef AbstractCompositeSet intersection_with(self, AbstractCompositeSet other):
    #     """
    #     Form the intersection of this object with another object.
    #     :param other: The other set
    #     :return: The intersection of this set with the other set
    #     """
    #     return self.intersection_with_simple_sets(other.simple_sets)

    # def __and__(self, other):
    #     return self.intersection_with(other)

    # cdef AbstractCompositeSet difference_with_simple_set(self, AbstractSimpleSet other):
    #     """
    #     Form the difference with another composite set.
    #     :param other: The other set
    #     :return: The difference of this set with the other set
    #     """
    #     result = self.new_empty_set()
    #     [result.simple_sets.insert(simple_set.difference_with(other)) for simple_set in self.acs_.simple_sets]
    #     return result.make_disjoint()
    #
    # cdef AbstractCompositeSet difference_with_simple_sets(self, other):
    #
    #     cdef AbstractCompositeSet result, current_difference, difference_with_other_simple_set, difference
    #     cdef bint first_iteration = True
    #
    #     # initialize the result
    #     result = self.new_empty_set()
    #
    #     # for every simple set in this set
    #     for own_simple_set in self.acs_.simple_sets:
    #
    #         # initialize the current difference
    #         current_difference = self.new_empty_set()
    #
    #         # for every simple set in the other set
    #         for other_simple_set in other:
    #             # form the element wise difference
    #             difference_with_other_simple_set = own_simple_set.difference_with(other_simple_set)
    #
    #             # if this is the first iteration
    #             if first_iteration:
    #                 # just copy the element wise difference
    #                 current_difference.simple_sets.insert(difference_with_other_simple_set)
    #                 first_iteration = False
    #                 continue
    #
    #             # form the intersection of the current difference with the element wise difference
    #             difference = self.new_empty_set()
    #             difference.simple_sets.insert(difference_with_other_simple_set)
    #             current_difference = current_difference.intersection_with(difference)
    #
    #         # add the current difference to the result
    #         result.simple_sets.insert(current_difference.simple_sets)
    #
    #     return result.make_disjoint()

    # cpdef AbstractCompositeSet difference_with(self, AbstractCompositeSet other):
    #     """
    #     Form the difference with another composite set.
    #     :param other: The other set
    #     :return: The difference of this set with the other set
    #     """
    #     return self.difference_with_simple_sets(other.simple_sets)

    # def __sub__(self, other):
    #     return self.difference_with(other)

    # cdef AbstractCompositeSet complement(self):
    #     """
    #     :return: The complement of this set
    #     """
    #
    #     if self.is_empty():
    #         return self.complement_if_empty()
    #
    #     result = self.new_empty_set()
    #     result.simple_sets = self.simple_sets[0].complement_cpp()
    #     for simple_set in self.simple_sets[1:]:
    #         result = result.intersection_with_simple_sets(simple_set.complement_cpp())
    #     return result.make_disjoint()

#     @abstractmethod
    cpdef AbstractCompositeSet complement_if_empty(self):
        """
        :return: The complement of this if it is empty.
        """
        raise NotImplementedError

    # def __invert__(self):
    #     return self.complement()

    # cpdef bint is_empty(self):
    #     """
    #     Check if this set is empty.
    #     """
    #     return self.acs_.simple_sets.size() == 0

    # cpdef bint contains(self, float item):
    #     """
    #     Check if this set contains an item.
    #     :param item: The item to check
    #     :return: Rather if the item is in the set or not
    #     """
    #     for simple_set in self.acs_.simple_sets:
    #         if simple_set.contains(item):
    #             return True
    #     return False

    # def __contains__(self, item):
    #     return self.contains(item)

    # cpdef str to_string(self):
    #     """
    #     :return: A string representation of this set.
    #     """
    #     if self.is_empty():
    #         return EMPTY_SET_SYMBOL
    #     return "{" + " u ".join([simple_set.to_string() for simple_set in self.acs_.simple_sets]) + "}"

    # def __str__(self):
    #     return self.to_string()
    #
    # def __repr__(self):
    #     return self.to_string()

    # cpdef bint is_disjoint(self):
    #     """
    #     :return: Rather if the simple sets are disjoint or not.
    #     """
    #     for a, b in itertools.combinations(self.acs_.simple_sets, 2):
    #         if not a.intersection_with(b).is_empty():
    #             return False
    #     return True

    # cdef split_into_disjoint_and_non_disjoint(self):
    #     """
    #     Split this composite set into disjoint and non-disjoint parts.
    #
    #     This method is required for making the composite set disjoint.
    #     The partitioning is done by removing every other simple set from every simple set.
    #     The purified simple sets are then disjoint by definition and the pairwise intersections are (potentially) not
    #     disjoint yet.
    #
    #     This method requires:
    #         - the intersection of two simple sets as a simple set
    #         - the difference_of_a_with_every_b of a simple set (A) and another simple set (B) that is completely contained in A (B ⊆ A).
    #         The result of that difference_of_a_with_every_b has to be a composite set with only one simple set in it.
    #
    #     :return: A tuple of the disjoint and non-disjoint set.
    #     """
    #     return self.acs_.split_into_disjoint_and_non_disjoint()

        # initialize result for disjoint and non-disjoint sets
        # cdef AbstractCompositeSet disjoint = self.new_empty_set()
        # cdef AbstractCompositeSet non_disjoint = self.new_empty_set()
        # cdef AbstractSimpleSet simple_set_a, simple_set_b, intersection_a_b
        # cdef AbstractCompositeSet difference_of_a_with_every_b, difference_with_intersection
        #
        # # for every simple set (a)
        # for simple_set_a in self.simple_sets:
        #     # initialize the difference of a with every b
        #     difference_of_a_with_every_b = self.new_empty_set()
        #     difference_of_a_with_every_b.add_simple_set(simple_set_a)
        #
        #     # for every other simple set (b)
        #     for simple_set_b in self.simple_sets:
        #         # skip symmetric iterations
        #         if simple_set_a == simple_set_b:
        #             continue
        #
        #         # get the intersection of a and b
        #         intersection_a_b = simple_set_a.intersection_with(simple_set_b)
        #
        #         # if the intersection is not empty add it to the non-disjoint set
        #         non_disjoint.add_simple_set(intersection_a_b)
        #
        #         # get the difference of the simple set with the intersection.
        #         difference_with_intersection = difference_of_a_with_every_b.difference_with_simple_set(intersection_a_b)
        #
        #         # if the difference of a with every b is empty
        #         if len(difference_with_intersection.simple_sets) == 0:
        #             # skip the rest of the loop and mark the set for discarding
        #             difference_of_a_with_every_b = None
        #             continue
        #
        #         # add the disjoint remainder
        #         difference_of_a_with_every_b = difference_with_intersection
        #
        #     # if the difference_of_a_with_every_b has become None, continue and step into the next iteration, otherwise
        #     # append the simple_set_a without every other simple set to the disjoint set
        #     if difference_of_a_with_every_b is None:
        #         continue
        #
        #
        #     disjoint.simple_sets.update(difference_of_a_with_every_b.simple_sets)
        #
        # return disjoint, non_disjoint

    # cpdef AbstractCompositeSet make_disjoint(self):
    #     """
    #     Create an equal composite set that contains a disjoint union of simple sets.
    #
    #     :return: The disjoint set.
    #     """
    #
    #     cdef AbstractCompositeSet disjoint, intersection, current_disjoint
    #
    #     disjoint, intersection = self.split_into_disjoint_and_non_disjoint()
    #
    #     # while the intersection is not empty
    #     while not intersection.is_empty():
    #         # split the intersection into disjoint and non-disjoint parts
    #         current_disjoint, intersection = intersection.split_into_disjoint_and_non_disjoint()
    #
    #         # add the disjoint intersection to the disjoint set
    #         disjoint.simple_sets.update(current_disjoint.simple_sets)
    #
    #     return disjoint.simplify()

    # cdef void add_simple_set(self, SimpleInterval simple_set):
    #     """
    #     Add a simple set to this composite set if it is not empty.
    #
    #     :param simple_set: The simple set to add
    #     """
    #     if simple_set.is_empty():
    #         return
    #     self.acs_.simple_sets.insert(simple_set.si_)

    # def __eq__(self, other: Self):
    #     return self.acs_.simple_sets._list == other.acs_.simple_sets._list
    #
    # def __hash__(self):
    #     return hash(tuple(self.acs_.simple_sets))
    #
    # def __iter__(self):
    #     return iter(self.acs_.simple_sets)

    # def __lt__(self, other: Self):
    #     """
    #     Compare this set with another set.
    #
    #     The sets are compared by comparing the simple sets in order.
    #     If the pair of simple sets are equal, the next pair is compared.
    #     If all pairs are equal, the set with the least amount of simple sets is considered smaller.
    #
    #     ..note:: This does not define a total order in the mathematical sense. In the mathematical sense, this defines
    #         a partial order.
    #
    #     :param other: The other set
    #     :return: Rather this set is smaller than the other set
    #     """
    #     for a, b in zip(self.simple_sets, other.simple_sets):
    #         if a == b:
    #             continue
    #         else:
    #             return a < b
    #     return len(self.simple_sets) < len(other.simple_sets)


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
if TYPE_CHECKING:
    SimpleSetContainer = SortedSet[AbstractSimpleSet]
else:
    SimpleSetContainer = SortedSet
