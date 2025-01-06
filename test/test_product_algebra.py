import unittest

import plotly.graph_objects as go

try:
    from random_events.interval import *
    from random_events.sigma_algebra import AbstractSimpleSet, AbstractSimpleSetJSON, AbstractCompositeSetJSON
    from random_events.variable import Continuous, Symbolic
    from random_events.set import SetElement, Set
    from random_events.product_algebra import SimpleEvent, Event
except ModuleNotFoundError:
    import pyximport
    pyximport.install()
finally:
    from random_events.interval import *
    from random_events.sigma_algebra import AbstractSimpleSet, AbstractSimpleSetJSON, AbstractCompositeSetJSON
    from random_events.variable import Continuous, Symbolic
    from random_events.set import SetElement, Set
    from random_events.product_algebra import SimpleEvent, Event

int_set = {1, 2, 4}

class EventTestCase(unittest.TestCase):
    x = Continuous("x")
    y = Continuous("y")
    z = Continuous("z")
    # a = Symbolic("a", int_set)
    # b = Symbolic("b", int_set)
    a = Symbolic("a", int_set)
    b = Symbolic("b", int_set)

    def test_constructor(self):
        sa = SetElement(1, int_set)
        sb = SetElement(2, int_set)
        # print({self.a: Set(sa), self.x: SimpleInterval(0, 1), self.y: SimpleInterval(0, 1)})
        event = SimpleEvent({self.a: Set(sa), self.x: Interval(SimpleInterval(0, 1)), self.y: Interval(SimpleInterval(0, 1))})

        self.assertEqual(event[self.x], Interval(SimpleInterval(0, 1)))
        self.assertEqual(event[self.y], Interval(SimpleInterval(0, 1)))
        self.assertEqual(event[self.a], Set(sa))

        self.assertFalse(event.is_empty())
        # self.assertTrue(event.contains((Set(sa), SimpleInterval(0, 1))))

    def test_intersection_with(self):
        sa = SetElement(1, int_set)
        sb = SetElement(2, int_set)
        sc = SetElement(4, int_set)
        event_1 = SimpleEvent(
            {self.a: Set(sa, sb), self.x: Interval(SimpleInterval(0, 1)), self.y: Interval(SimpleInterval(0, 1))})
        event_2 = SimpleEvent({self.a: Set(sa), self.x: Interval(SimpleInterval(0.5, 1))})
        event_3 = SimpleEvent({self.a: Set(sb)})
        intersection = event_1.intersection_with(event_2)

        intersection_ = SimpleEvent(
            {self.a: Set(sa), self.x: Interval(SimpleInterval(0.5, 1)), self.y: Interval(SimpleInterval(0, 1))})

        self.assertEqual(intersection, intersection_)
        self.assertNotEqual(intersection, event_1)

        second_intersection = event_1.intersection_with(event_3)
        self.assertTrue(second_intersection.is_empty())

    def test_complement(self):
        sa = SetElement(1, int_set)
        sb = SetElement(2, int_set)
        sc = SetElement(4, int_set)
        event = SimpleEvent({self.a: Set(sa, sb), self.x: Interval(SimpleInterval(0, 1)), self.y: self.y.domain})
        complement = event.complement()
        self.assertEqual(len(complement), 2)
        complement_1 = SimpleEvent({self.a: Set(sc), self.x: self.x.domain, self.y: self.y.domain})
        complement_2 = SimpleEvent({self.a: event[self.a], self.x: event[self.x].complement(), self.y: self.y.domain})
        self.assertEqual(complement, SortedSet([complement_1, complement_2]))

    def test_simplify(self):
        sa = SetElement(1, int_set)
        sb = SetElement(2, int_set)
        sc = SetElement(4, int_set)
        event_1 = SimpleEvent(
            {self.a: Set(sa, sb), self.x: Interval(SimpleInterval(0, 1)), self.y: Interval(SimpleInterval(0, 1))})
        event_2 = SimpleEvent(
            {self.a: Set(sc), self.x: Interval(SimpleInterval(0, 1)), self.y: Interval(SimpleInterval(0, 1))})
        event = Event(event_1, event_2)
        simplified = event.simplify()
        self.assertEqual(len(simplified.simple_sets), 1)

        result = Event(SimpleEvent(
            {self.a: self.a.domain, self.x: Interval(SimpleInterval(0, 1)), self.y: Interval(SimpleInterval(0, 1))}))
        self.assertEqual(simplified, result)

    def test_to_json(self):
        sa = SetElement(1, int_set)
        sb = SetElement(2, int_set)
        sc = SetElement(4, int_set)
        event = SimpleEvent({self.a: Set(sa, sb), self.x: Interval(SimpleInterval(0, 1)),
                             self.y: Interval(SimpleInterval(0, 1))})
        event_ = AbstractSimpleSetJSON.from_json(event.to_json())
        self.assertEqual(event_, event)

    def test_plot_2d(self):
        event_1 = SimpleEvent({self.x: Interval(SimpleInterval(0, 1)), self.y: Interval(SimpleInterval(0, 1))})
        event_2 = SimpleEvent({self.x: Interval(SimpleInterval(1, 2)), self.y: Interval(SimpleInterval(1, 2))})
        event = Event(event_1, event_2)
        fig = go.Figure(event.plot(), event.plotly_layout())
        self.assertIsNotNone(fig)  # fig.show()

    def test_plot_3d(self):
        event_1 = SimpleEvent(
            {self.x: SimpleInterval(0, 1), self.y: SimpleInterval(0, 1), self.z: SimpleInterval(0, 1)})
        event_2 = SimpleEvent(
            {self.x: SimpleInterval(1, 2), self.y: SimpleInterval(1, 2), self.z: SimpleInterval(1, 2)})
        event = Event(event_1, event_2)
        fig = go.Figure(event.plot(), event.plotly_layout())
        self.assertIsNotNone(fig)  # fig.show()

    def test_union(self):
        sa = SetElement(1, int_set)
        sb = SetElement(2, int_set)
        sc = SetElement(4, int_set)
        event = Event(SimpleEvent({self.a: sa, self.x: open(-float("inf"), 2)}))
        second_event = SimpleEvent({self.a: Set(sa, sb), self.x: open(1, 4)}).as_composite_set()
        union = event | second_event
        result = Event(SimpleEvent({self.a: sa, self.x: open(-float("inf"), 4)}),
                        SimpleEvent({self.a: sb, self.x: open(1, 4)}))
        self.assertEqual(union, result)

    def test_marginal_event(self):
        event_1 = SimpleEvent({self.x: closed(0, 1), self.y: Interval(SimpleInterval(0, 1))})
        event_2 = SimpleEvent({self.x: closed(1, 2), self.y: Interval(SimpleInterval(3, 4))})
        event_3 = SimpleEvent({self.x: closed(5, 6), self.y: Interval(SimpleInterval(5, 6))})
        event = Event(event_1, event_2, event_3)
        marginal = event.marginal(SortedSet([self.x]))
        self.assertEqual(marginal, SimpleEvent({self.x: closed(0, 2) | closed(5, 6)}).as_composite_set())
        fig = go.Figure(marginal.plot())
        # fig.show()


if __name__ == '__main__':
    unittest.main()
