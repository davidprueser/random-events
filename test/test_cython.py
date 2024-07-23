import unittest
import time

from sortedcontainers import SortedSet


class CythonTestCase(unittest.TestCase):
    #
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
        com = None
        inter = Interval(SimpleInterval(0, 0, Bound.CLOSED, Bound.CLOSED))
        for i in range(500000):
            si = SimpleInterval(0, 1, Bound.OPEN, Bound.CLOSED)
            com = si.complement_cpp()
        self.assertTrue(inter.is_singleton())

        print(com)
        # print(complement)
        totcy = time.time() - t1
        print(f"cython {totcy}")
        print("---------------------------------")

    def test_complement_python(self):
        from random_events.interval_old import SimpleInterval, Interval, Bound


        t1 = time.time()
        com = None
        inter = Interval(SimpleInterval(0, 0, Bound.CLOSED, Bound.CLOSED))
        for i in range(500000):
            si = SimpleInterval(0, 1, Bound.OPEN, Bound.CLOSED)
            com = si.complement()
        self.assertTrue(inter.is_singleton())

        print(com)
        # print(complement)
        totcy = time.time() - t1
        print(f"cython {totcy}")
        print("---------------------------------")


if __name__ == '__main__':
    unittest.main()
