import random
import unittest
import time

from sortedcontainers import SortedSet


class CythonTestCase(unittest.TestCase):

    def test_intervals_cython(self):
        from random_events.interval import SimpleInterval, Bound, Interval

        t1 = time.time()
        for i in range(100):
            b = []
            for a in range(50):
                b.append(SimpleInterval(random.randint(0, 100), random.randint(0, 100), Bound.OPEN, Bound.CLOSED))
            z = Interval(*b)
            z.make_disjoint()
        print(f"cython {time.time() - t1}")

    def test_intervals_python(self):
        from random_events.interval_old import SimpleInterval, Bound, Interval

        t1 = time.time()
        for i in range(100):
            b = []
            for a in range(50):
                b.append(SimpleInterval(random.randint(0, 100), random.randint(0, 100), Bound.OPEN, Bound.CLOSED))
            z = Interval(*b)
            z.make_disjoint()
        print(f"python {time.time() - t1}")



if __name__ == '__main__':
    unittest.main()
