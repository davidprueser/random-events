import unittest

from sortedcontainers import SortedSet

from random_events.set import SetElement, Set
from random_events.sigma_algebra import AbstractSimpleSetJSON, EMPTY_SET_SYMBOL

# class TestEnum(SetElement):
#     EMPTY_SET = -1
#     A = 1
#     B = 2
#     C = 4

int_set: set[str] = {'-1', 'a', 'b', 'c'}


class SetElementTestCase(unittest.TestCase):

    def test_intersection_with(self):
        a = SetElement('a', int_set)
        b = SetElement('b', int_set)
        empty_set = SetElement('-1', set())

        intersection_a_b = a.intersection_with(b)
        self.assertEqual(intersection_a_b, a.EMPTY_SET)
        self.assertEqual(a.intersection_with(a), a)
        self.assertEqual(empty_set.intersection_with(a), empty_set)

    def test_complement(self):
        a = SetElement('a', int_set)
        b = SetElement('b', int_set)
        c = SetElement('c', int_set)
        complement = a.complement()
        self.assertEqual(complement, SortedSet((b.element, c.element)))

    def test_is_empty(self):
        empty = SetElement('-1', int_set)
        b = SetElement('b', int_set)
        self.assertTrue(empty.is_empty())
        self.assertFalse(b.is_empty())

    def test_contains(self):
        a = SetElement('a', int_set)
        b = SetElement('b', int_set)
        c = SetElement('c', int_set)
        self.assertTrue(a.contains(a))
        self.assertFalse(a.contains(b))
        self.assertFalse(a.contains(c))

    def test_to_json(self):
        a = SetElement('a', int_set)
        b = AbstractSimpleSetJSON.from_json(a.to_json())
        self.assertEqual(a, b)


class SetTestCase(unittest.TestCase):

    def test_simplify(self):
        a = SetElement('a', int_set)
        print(a)
        b = SetElement('b', int_set)
        c = SetElement('c', int_set)
        s = Set(a, b, c, c)
        self.assertEqual(4, len(s.simple_sets))
        ss = Set(a, b, c)
        self.assertEqual(ss, s.simplify())

    # inheritance from AbstractCompositeSet doesn't work with this type of SetElement declaration
    def test_difference(self):
        a = SetElement('a', int_set)
        b = SetElement('b', int_set)
        s = Set(a, b)
        s_ = Set(a)
        self.assertEqual(s.difference_with(s_), Set(b))

    def test_complement(self):
        a = SetElement('a', int_set)
        b = SetElement('b', int_set)
        c = SetElement('c', int_set)
        s = Set(a, b)
        self.assertEqual(s.complement(), Set(c))

    def test_to_json(self):
        a = SetElement('a', int_set)
        b = SetElement('b', int_set)
        s = Set(a, b)
        s_ = AbstractSimpleSetJSON.from_json(s.to_json())
        self.assertEqual(s, s_)

    # def test_to_json_with_dynamic_enum(self):
    #     enum_ = SetElement("Foo", "A B C")
    #     s = Set(enum_.A, enum_.B)
    #     s_ = s.to_json()
    #     del enum_
    #     s_ = AbstractSimpleSet.from_json(s_)
    #     self.assertEqual(s, s_)



if __name__ == '__main__':
    unittest.main()
