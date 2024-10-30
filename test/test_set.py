import unittest

from sortedcontainers import SortedSet

from random_events.set import SetElement, Set, EMPTY_SET
from random_events.sigma_algebra import AbstractSimpleSetJSON, EMPTY_SET_SYMBOL

# class TestEnum(SetElement):
#     EMPTY_SET = -1
#     A = 1
#     B = 2
#     C = 4

str_set = {'a', 'c', 'b'}
int_set = {1, 3, 2}


class SetElementTestCase(unittest.TestCase):

    def test_intersection_with(self):
        a = SetElement('a', str_set)
        b = SetElement('b', str_set)

        intersection_a_b = a.intersection_with(b)
        self.assertEqual(intersection_a_b, EMPTY_SET)
        self.assertEqual(a.intersection_with(a), a)

    def test_complement(self):
        a = SetElement('a', str_set)
        b = SetElement('b', str_set)
        c = SetElement('c', str_set)
        a1 = SetElement(1, int_set)
        complement_a = a.complement()
        complement_b = b.complement()
        complement_c = c.complement()
        complement_a1 = a1.complement()
        self.assertEqual(complement_a, {b, c})
        self.assertEqual(complement_b, {a, c})
        self.assertEqual(complement_c, {a, b})
        print(complement_c)
        print(complement_a1)
        # why doesnt this work?
        self.assertEqual(complement_a1, SortedSet([2, 3]))

    def test_contains(self):
        a = SetElement('a', str_set)
        b = SetElement('b', str_set)
        c = SetElement('c', str_set)
        self.assertTrue(a.contains(a))
        self.assertFalse(a.contains(b))
        self.assertFalse(a.contains(c))

    def test_to_json(self):
        a = SetElement('a', str_set)
        b = AbstractSimpleSetJSON.from_json(a.to_json())
        self.assertEqual(a, b)


class SetTestCase(unittest.TestCase):

    def test_simplify(self):
        a = SetElement('a', str_set)
        print(a)
        b = SetElement('b', str_set)
        c = SetElement('c', str_set)
        s = Set(a, b, c, c)
        self.assertEqual(3, len(s.simple_sets))
        ss = Set(a, b, c)
        self.assertEqual(ss, s.simplify())

    def test_difference(self):
        a = SetElement('a', str_set)
        b = SetElement('b', str_set)
        s = Set(a, b)
        s_ = Set(a)
        self.assertEqual(s.difference_with(s_), Set(b))

    def test_complement(self):
        a = SetElement('a', str_set)
        b = SetElement('b', str_set)
        c = SetElement('c', str_set)
        s = Set(a, b)
        self.assertEqual(s.complement(), Set(c))

    def test_to_json(self):
        a = SetElement('a', str_set)
        b = SetElement('b', str_set)
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
