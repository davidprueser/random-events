import unittest
import time

from sortedcontainers import SortedSet


class CythonTestCase(unittest.TestCase):

    # def test_intervals_cython(self):
    #     from random_events.interval import SimpleInterval, Bound
    #
    #     t1 = time.time()
    #     for i in range(10000000):
    #         y = SimpleInterval(0, 1, Bound.OPEN, Bound.CLOSED)
    #     print(f"cython {time.time() - t1}")
    #
    # def test_intervals_python(self):
    #     from random_events.interval_old import SimpleInterval, Bound
    #
    #     t1 = time.time()
    #     for i in range(10000000):
    #         y = SimpleInterval(0, 1, Bound.OPEN, Bound.CLOSED)
    #     print(f"python {time.time() - t1}")

    def test_complement_cython(self):
        from random_events.interval import SimpleInterval, Interval, Bound

        t1 = time.time()
        i = Interval(SimpleInterval(0, 1))
        complement = i.make_disjoint()
        for i in range(500000):
            i = Interval(SimpleInterval(0, 1))
            complement = i.make_disjoint()

        print(i)
        print(complement)
        print(f"cython {time.time() - t1}")

    def test_complement_python(self):
        from random_events.interval_old import SimpleInterval, Interval, Bound

        t1 = time.time()
        i = Interval(SimpleInterval(0, 1))
        complement = i.make_disjoint()
        for i in range(500000):
            i = Interval(SimpleInterval(0, 1))
            complement = i.make_disjoint()

        print(i)
        print(complement)
        print(f"cython {time.time() - t1}")


if __name__ == '__main__':
    unittest.main()
