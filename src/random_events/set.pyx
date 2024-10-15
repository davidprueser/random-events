from __future__ import annotations
import enum
import functools

import cython
from sortedcontainers import SortedSet
from typing_extensions import Self, TYPE_CHECKING, Dict, Any

from random_events.sigma_algebra cimport AbstractSimpleSet, AbstractCompositeSet
from random_events.sigma_algebra import AbstractSimpleSetJSON, AbstractCompositeSetJSON


cdef class SetElement(AbstractSimpleSet):
    """
    Base class for enums that are used as elements in a set.
    """

    def __init__(self, element, *all_elements):
        if all_elements is not None:
            self.all_elements = SortedSet(all_elements)

        self.element = element
        self.json_serializer = SetElementJSON(self)

    def __hash__(self):
        return hash((self.element, tuple(self.all_elements)))

    def __lt__(self, SetElement other):
        return self.element < other.element

    def __eq__(self, SetElement other):
        return self.element == other.element

    def __repr__(self):
        return AbstractSimpleSet.to_string(self)

    #two decorators not supported in cython yet
    @property
    def EMPTY_SET(self):
        return SetElement(-1, None)

    cpdef AbstractSimpleSet intersection_with(self, AbstractSimpleSet other):
        if self.element == other.element:
            return self
        else:
            return self.EMPTY_SET

    cpdef complement(self):
        cdef result = SortedSet()
        for element in self.all_elements[0]:
                if element != self.element and element != self.EMPTY_SET.element:
                    result.add(element)
        return result

    cpdef bint is_empty(self) except *:
        return self == self.EMPTY_SET

    cpdef bint contains(self, item) except *:
        return self == item

    cpdef str non_empty_to_string(self):
        return str(self.element)

    cpdef AbstractCompositeSet as_composite_set(self):
        return Set(self)

    def to_json(self):
        return self.json_serializer.to_json()


class SetElementJSON(AbstractSimpleSetJSON):
    def __init__(self, set_element: SetElement):
        self.set_element = set_element

    def to_json(self) -> Dict[str, Any]:
        return {**super().to_json(), "value": self.set_element.element}

    @staticmethod
    def _from_json(data: Dict[str, Any]) -> SetElement:
        return SetElement(data["value"])


cdef class Set(AbstractCompositeSet):
    def __init__(self, *simple_sets):
        super().__init__(*simple_sets)
        self.json_serializer = SetJSON(self)

    cpdef Set complement_if_empty(self):
        raise NotImplementedError("I don't know how to do this yet.")

    cpdef Set simplify(self):
        return self

    cpdef Set new_empty_set(self):
        return Set()

    cpdef Set make_disjoint(self):
        return self

    # cpdef AbstractCompositeSet complement(self):
    #     cdef Set complement = Set(*[simple_set.complement() for simple_set in self.simple_sets])
    #     print(complement)
    #     # cdef Set x = Set(*[simple_set.element for simple_set in self.simple_sets])
    #     return None

    def to_json(self):
        return self.json_serializer.to_json()

class SetJSON(AbstractCompositeSetJSON):
    def __init__(self, composite_set: Set):
        super().__init__(composite_set)

    def to_json(self) -> Dict[str, Any]:
        return super().to_json()

    @staticmethod
    def _from_json(data: Dict[str, Any]):
        return Set(*[AbstractSimpleSetJSON.from_json(simple_set) for simple_set in data['simple_sets']])


# Type definitions
if TYPE_CHECKING:
    SetElementContainer = SortedSet[SetElement]
else:
    SetElementContainer = SortedSet
