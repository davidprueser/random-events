from __future__ import annotations
import enum
import functools

import cython
from sortedcontainers import SortedSet
from typing_extensions import Self, TYPE_CHECKING, Dict, Any, Type

from random_events.sigma_algebra import AbstractSimpleSetJSON, AbstractCompositeSetJSON, EMPTY_SET_SYMBOL
from random_events.utils import get_full_class_name

cdef class SetElement(AbstractSimpleSet):
    """
    Base class for enums that are used as elements in a set.
    """

    def __init__(self, element: str, all_elements: set[str]):
        if element == "-1":
            self.element = EMPTY_SET_SYMBOL
            self.all_elements = {}
        elif all_elements is not None:
            self.element = element
            self.all_elements = SortedSet(all_elements)

        cpp_set = CPPAllSetElementsPtr_t()
        for set_element in self.all_elements:
            cpp_set.get().insert(set_element)

        self.cpp_set_element_object = new CPPSetElement(self.element, cpp_set[0])
        # self.cpp_set_element_object.element = self.element
        #
        # for set_element in self.all_elements:
        #     self.cpp_set_element_object.all_elements.get().insert(set_element.as_cpp_simple_set())

        # self.cpp_set_element_object = new CPPSetElement(self.element, <CPPAllSetElements_t> all_elements)
        # self.cpp_object = self.cpp_set_element_object
        self.json_serializer = SetElementJSON(self)

    def __hash__(self):
        return hash((self.element, tuple(self.all_elements)))

    def __lt__(self, other: SetElement):
        return self.element < other.element

    def __eq__(self, SetElement other):
        if self.element == other.element:
            return True
        return False

    def __repr__(self):
        return AbstractSimpleSet.to_string(self)

    cdef AbstractSimpleSet from_cpp_si(self, CPPAbstractSimpleSetPtr_t simple_set):
        # Cast the CPPAbstractSimpleSet pointer to CPPSimpleInterval pointer
        cdef CPPSetElement * new_simple_set = <CPPSetElement *> simple_set.get()

        # Make sure that cpp_interval is not NULL (i.e., ensure the cast was valid)
        if new_simple_set is not NULL:
            # Create and return a new SimpleInterval Python object
            return SetElement(new_simple_set.element, new_simple_set.all_elements.get()[0])
        else:
            raise ValueError("Invalid CPPSimpleInterval pointer.")

    #two decorators not supported in cython yet
    @property
    def EMPTY_SET(self):
        return SetElement(EMPTY_SET_SYMBOL, set())

    cpdef AbstractSimpleSet intersection_with(self, AbstractSimpleSet other):
        if self == other:
            return self
        else:
            return self.EMPTY_SET

    cpdef complement(self):
        cdef result = SortedSet()
        for element in self.all_elements:
                if element != self.element and element != '-1':
                    result.add(element)
        return result

    cpdef bint is_empty(self) except *:
        return self.element == EMPTY_SET_SYMBOL

    cpdef bint contains(self, item) except *:
        return self == item

    cpdef str non_empty_to_string(self):
        return self.element

    cpdef AbstractCompositeSet as_composite_set(self):
        return Set(self)

    cpdef to_json(self):
        return self.json_serializer.to_json()


class SetElementJSON(AbstractSimpleSetJSON):
    def __init__(self, set_element: SetElement):
        self.set_element = set_element

    def to_json(self) -> Dict[str, Any]:
        return {**super().to_json(), "value": self.set_element.element, "set": set(self.set_element.all_elements)}

    @staticmethod
    def _from_json(data: Dict[str, Any]) -> SetElement:
        return SetElement(data["value"], data["set"])


cdef class Set(AbstractCompositeSet):
    def __init__(self, *simple_sets):
        super().__init__(simple_sets)
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

    cpdef to_json(self):
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
