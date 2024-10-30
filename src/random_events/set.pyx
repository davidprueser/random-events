from __future__ import annotations
import enum
import functools
from pickle import EMPTY_SET

import cython
from sortedcontainers import SortedSet
from typing_extensions import Self, TYPE_CHECKING, Dict, Any, Type

from random_events.sigma_algebra import AbstractSimpleSetJSON, AbstractCompositeSetJSON, EMPTY_SET_SYMBOL
from random_events.utils import get_full_class_name


cdef class SetElement(AbstractSimpleSet):
    """
    Base class for enums that are used as elements in a set.
    """

    def __init__(self, element, all_elements):
        if element == EMPTY_SET_SYMBOL or element == -1:
            self.element = EMPTY_SET_SYMBOL
            self.all_elements = set()
        elif element not in all_elements:
            raise ValueError(f"Element {element} not in all elements {all_elements}")
        else:
            self.all_elements = SortedSet(all_elements)
            self.element = element
            self.index = self.all_elements.index(self.element)
            self.length = len(self.all_elements)
            self.cpp_set_element_object = new CPPSetElement(self.index, self.length)
            self.cpp_object = self.cpp_set_element_object

        self.json_serializer = SetElementJSON(self)


    def __hash__(self):
        return hash((self.element, tuple(self.all_elements)))

    def __lt__(self, SetElement other):
        return self.element < other.element

    def __eq__(self, SetElement other):
        if self.element == other.element:
            return True
        return False

    def __repr__(self):
        return self.non_empty_to_string()

    cdef AbstractSimpleSet from_cpp_simple_set(self, CPPAbstractSimpleSetPtr_t simple_set):
        cpp_set_element = <CPPSetElement *> simple_set.get()
        if cpp_set_element.element_index == -1:
            return SetElement(EMPTY_SET_SYMBOL, set())
        return SetElement(self.all_elements[cpp_set_element.element_index], self.all_elements)

    cpdef complement(self):
        return self.from_cpp_simple_set_set(self.cpp_object.complement())

    cpdef bint contains(self, item) except *:
        return self == item

    cpdef bint is_empty(self):
        return self.element == EMPTY_SET_SYMBOL or self.element == -1

    cpdef str non_empty_to_string(self):
        return str(self.element)

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


EMPTY_SET = SetElement(-1, set())


cdef class Set(AbstractCompositeSet):
    def __init__(self, *simple_sets):
        super().__init__(*simple_sets)
        self.json_serializer = SetJSON(self)
        self.cpp_object = new CPPSet()

        cdef SetElement simple_set
        if self.simple_sets is not None:
            for simple_set in self.simple_sets:
                self.cpp_object.simple_sets.get().insert(shared_ptr[CPPAbstractSimpleSet](simple_set.cpp_set_element_object))

    cdef AbstractSimpleSet from_cpp_simple_set(self, CPPAbstractSimpleSetPtr_t simple_set):
        cdef CPPSetElement * cpp_set = <CPPSetElement *> simple_set.get()
        return SetElement(self.simple_sets[0].all_elements[cpp_set.element_index], self.simple_sets[0].all_elements)

    cdef AbstractCompositeSet from_cpp_composite_set(self, CPPAbstractCompositeSetPtr_t composite_set):
        cdef CPPSet * cpp_set = <CPPSet *> composite_set.get()
        simple_sets = self.from_cpp_composite_set_set(cpp_set.simple_sets)
        return Set(*simple_sets)

    cpdef Set complement_if_empty(self):
        raise NotImplementedError("I don't know how to do this yet.")

    cpdef Set simplify(self):
        return self

    cpdef Set new_empty_set(self):
        return Set()

    cpdef Set make_disjoint(self):
        return self

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
