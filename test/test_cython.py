import unittest
import time


class CythonTestCase(unittest.TestCase):

    def test_intervals_cython(self):
        from random_events.interval import SimpleInterval, Bound

        t1 = time.time()
        for i in range(10000000):
            y = SimpleInterval(0, 1, Bound.OPEN, Bound.OPEN)
        print(f"cython {time.time() - t1}")

    def test_intervals_python(self):
        from random_events.interval_old import SimpleInterval, Bound

        t1 = time.time()
        for i in range(10000000):
            y = SimpleInterval(0, 1, Bound.OPEN, Bound.OPEN)
        print(f"python {time.time() - t1}")


if __name__ == '__main__':
    unittest.main()
