import unittest

from sortedcontainers import SortedSet

from random_events.set import SetElement, Set
from random_events.sigma_algebra import AbstractSimpleSetJSON


# class TestEnum(SetElement):
#     EMPTY_SET = -1
#     A = 1
#     B = 2
#     C = 4

int_set = -1, 1, 2, 4


class SetElementTestCase(unittest.TestCase):

    def test_intersection_with(self):
        a = SetElement(1, int_set)
        b = SetElement(2, int_set)
        empty_set = SetElement(-1, int_set)

        intersection_a_b = a.intersection_with(b)
        self.assertEqual(intersection_a_b, a.EMPTY_SET)
        self.assertEqual(a.intersection_with(a), a)
        self.assertEqual(empty_set.intersection_with(a), empty_set)

    def test_complement(self):
        a = SetElement(1, int_set)
        b = SetElement(2, int_set)
        c = SetElement(4, int_set)
        complement = a.complement()
        self.assertEqual(complement, SortedSet((b.element, c.element)))

    def test_is_empty(self):
        a = SetElement(-1, int_set)
        b = SetElement(2, int_set)
        self.assertTrue(a.is_empty())
        self.assertFalse(b.is_empty())

    def test_contains(self):
        a = SetElement(1, int_set)
        b = SetElement(2, int_set)
        c = SetElement(4, int_set)
        self.assertTrue(a.contains(a))
        self.assertFalse(a.contains(b))
        self.assertFalse(a.contains(c))

    def test_to_json(self):
        a = SetElement(1, int_set)
        b = AbstractSimpleSetJSON.from_json(a.to_json())
        self.assertEqual(a, b)


class SetTestCase(unittest.TestCase):

    def test_simplify(self):
        a = SetElement(1, int_set)
        b = SetElement(2, int_set)
        c = SetElement(4, int_set)
        s = Set(a, b, c, c)
        self.assertEqual(len(s.simple_sets), 3)
        self.assertEqual(s.simplify(), s)

    # inheritance from AbstractCompositeSet doesn't work with this type of SetElement declaration
    # def test_difference(self):
    #     a = SetElement(1, int_set)
    #     b = SetElement(2, int_set)
    #     s = Set(a, b)
    #     s_ = Set(a)
    #     self.assertEqual(s.difference_with(s_), Set(b))

    # def test_complement(self):
    #     a = SetElement(1, int_set)
    #     b = SetElement(2, int_set)
    #     c = SetElement(4, int_set)
    #     s = Set(a, b)
    #     self.assertEqual(s.complement(), Set(c))

    def test_to_json(self):
        a = SetElement(1, int_set)
        b = SetElement(2, int_set)
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
