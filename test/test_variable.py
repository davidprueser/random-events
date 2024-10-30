import unittest

from random_events.variable import *
from random_events.interval import *
from random_events.set import *


int_set = {1, 2, 4}


class ContinuousTestCase(unittest.TestCase):
    x = Continuous("x")

    # domain type wrong due to SetElement creation
    def test_creation(self):
        self.assertEqual(self.x.name, "x")
        self.assertEqual(self.x.domain, reals())

    def test_to_json(self):
        x_ = VariableJSON.from_json(self.x.to_json())
        self.assertEqual(self.x, x_)


class IntegerTestCase(unittest.TestCase):

    def test_creation(self):
        x = Integer("x")
        self.assertEqual(x.name, "x")
        self.assertEqual(x.domain, reals())


class SymbolicTestCase(unittest.TestCase):

    def test_creation(self):
        a = SetElement(1, int_set)
        b = SetElement(2, int_set)
        c = SetElement(4, int_set)
        x = Symbolic("x", Set(a, b, c))
        self.assertEqual(x.name, "x")
        self.assertEqual(x.domain, Set(a, b, c))

    def test_to_json(self):
        a = SetElement(1, int_set)
        b = SetElement(2, int_set)
        c = SetElement(4, int_set)
        x = Symbolic("x", Set(a, b, c))
        x_ = VariableJSON.from_json(x.to_json())
        self.assertEqual(x, x_)


if __name__ == '__main__':
    unittest.main()
