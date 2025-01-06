# distutils: language = c++

from __future__ import annotations
import itertools
import numpy as np
from sortedcontainers import SortedDict, SortedKeysView, SortedValuesView, SortedSet
from typing_extensions import List, TYPE_CHECKING, Tuple, Union, Any, Self, Dict
import plotly.graph_objects as go
from random_events.sigma_algebra import SimpleSetContainer, AbstractSimpleSetJSON, AbstractCompositeSetJSON
from random_events.variable import VariableJSON


cdef class SimpleEvent(AbstractSimpleSet):
    """
    A simple event is a set of assignments of variables to values.

    A simple event is logically equivalent to a conjunction of assignments.
    """

    def __init__(self, *args, **kwargs):
        cdef Variable variable
        cdef AbstractCompositeSet assignment
        cdef shared_ptr[cpp_map[AbstractVariablePtr_t, CPPAbstractCompositeSetPtr_t]] result = (
            make_shared[cpp_map[AbstractVariablePtr_t, CPPAbstractCompositeSetPtr_t]]())
        # cdef VariableMapPtr_t var_map
        cdef AbstractVariablePtr_t cpp_variable_ptr
        cdef CPPAbstractCompositeSetPtr_t cpp_assignment_ptr

        self.sorted = SortedDict(*args, **kwargs)
        for variable, assignment in self.sorted.items():
            print("variable", variable)
            print("assignment", assignment)
            cpp_variable_ptr = shared_ptr[AbstractVariable](variable.cpp_object)
            cpp_assignment_ptr = shared_ptr[CPPAbstractCompositeSet](assignment.cpp_object)
            result.get()[0].insert(pair[AbstractVariablePtr_t, CPPAbstractCompositeSetPtr_t](cpp_variable_ptr, cpp_assignment_ptr))
        #var_map = make_shared[VariableMap](result)

        self.cpp_simple_event_object = new CPPSimpleEvent(result)
        self.cpp_object = self.cpp_simple_event_object

    def __repr__(self):
        return self.non_empty_to_string()

    def __eq__(self, other):
        return self.sorted == other.sorted

    cdef AbstractSimpleSet from_cpp_simple_set(self, CPPAbstractSimpleSetPtr_t simple_set):
        cdef CPPSimpleEvent * cpp_event = <CPPSimpleEvent *> simple_set.get()
        cdef cpp_map[AbstractVariablePtr_t, CPPAbstractCompositeSetPtr_t] variable_map = cpp_event.variable_map.get()[0]
        cdef pair[AbstractVariablePtr_t, CPPAbstractCompositeSetPtr_t] pair
        cdef Variable variable
        cdef AbstractCompositeSet composite_set
        cdef dict py_variable_map = {}
        for key, value in self.sorted.items():
            variable = type(key)(name=key.name, domain=key.domain)
            print("new variable", variable)
            composite_set = type(value)(*value.simple_sets)
            print("new composite set", composite_set)
            for pair in variable_map:
                if pair.first.get().get_type() != variable.cpp_object.get_type():
                    continue
                a = variable.from_cpp_variable(pair.first)
                print("---------------------")
                print("from cpp variable", a)
                b = composite_set.from_cpp_composite_set(pair.second)
                print("from cpp assignment", b)
                py_variable_map.update({a: b})

        print("result" ,py_variable_map)
        return SimpleEvent(py_variable_map)

    @property
    def variables(self) -> SortedKeysView[Variable]:
        return self.sorted.keys()

    cpdef Variable variable_of(self, str name):
        """
        Get the variable with the given name.
        :param name: The variable's name
        :return: The variable itself
        """
        cdef list variable = [variable for variable in self.variables if variable.name == name]
        if len(variable) == 0:
            raise KeyError(f"Variable {name} not found in event {self}")
        return variable[0]

    def __getitem__(self, item: Union[str, Variable]):
        if isinstance(item, str):
            item = self.variable_of(item)
        return self.sorted.__getitem__(item)

    def __setitem__(self, key: Union[str, Variable], value: AbstractCompositeSet):
        if isinstance(key, str):
            key = self.variable_of(key)
            self.sorted.__setitem__(key, value)
        else:
            raise TypeError(f"Value must be a SimpleSet or CompositeSet, got {type(value)} instead.")

    def __copy__(self):
        return self.__class__({variable: value for variable, value in self.sorted.items()})


    cpdef AbstractCompositeSet as_composite_set(self):
        return Event(self)

    @property
    def assignments(self) -> SortedValuesView:
        return self.sorted.values()

    cpdef bint contains(self, item) except *:
        print(self.assignments)
        print(item)
        for assignment, value in zip(self.assignments, item):
            print(assignment)
            print(type(assignment))
            print(value)
            print(type(value))
            if not assignment.contains(value):
                return False
        return True

    def __hash__(self):
        return hash(tuple(self.sorted.items()))

    def __lt__(self, other: Self):
        if len(self.variables) < len(other.variables):
            return True
        for variable in self.variables:
            if self[variable] == other[variable]:
                continue
            else:
                return self[variable] < other[variable]

    cpdef SimpleEvent marginal(self, variables):
        """
        Create the marginal event, that only contains the variables given..

        :param variables: The variables to contain in the marginal event
        :return: The marginal event
        """
        cdef SimpleEvent result = self.__class__()
        for variable in variables:
            result[variable] = self[variable]
        return result

    cpdef str non_empty_to_string(self):
        result = []
        for variable, assignment in self.sorted.items():
            result.append(f"{variable.name} = {assignment}")
        return "{" + ", ".join(result) + "}"

        # return "{" + ", ".join(f"{variable.name} = {assignment}" for variable, assignment in self.sorted.items()) + "}"

    def plot(self) -> Union[List[go.Scatter], List[go.Mesh3d]]:
        """
        Plot the event.
        """
        assert all(isinstance(variable, Continuous) for variable in self.sorted.keys()), \
            "Plotting is only supported for events that consist of only continuous variables."
        if len(self.sorted.keys()) == 1:
            return self.plot_1d()
        if len(self.sorted.keys()) == 2:
            return self.plot_2d()
        elif len(self.sorted.keys()) == 3:
            return self.plot_3d()
        else:
            raise NotImplementedError("Plotting is only supported for two and three dimensional events")

    def plot_1d(self) -> List[go.Scatter]:
        """
        Plot the event in 1D.
        """
        xs = []
        ys = []

        interval: Interval = list(self.sorted.values())[0]
        for simple_interval in interval.simple_sets:
            simple_interval: SimpleInterval
            xs.extend([simple_interval.lower, simple_interval.upper, None])
            ys.extend([0, 0, None])

        return [go.Scatter(x=xs, y=ys, mode="lines", name="Event", fill="toself")]

    def plot_2d(self) -> List[go.Scatter]:
        """
        Plot the event in 2D.
        """

        # form cartesian product of all intervals
        intervals = [value.simple_sets for value in self.sorted.values()]
        interval_combinations = list(itertools.product(*intervals))

        xs = []
        ys = []

        # for every atomic interval
        for interval_combination in interval_combinations:

            # plot a rectangle
            points = np.asarray(list(itertools.product(*[[axis.lower, axis.upper] for axis in interval_combination])))
            y_points = points[:, 1]
            y_points[len(y_points) // 2:] = y_points[len(y_points) // 2:][::-1]
            xs.extend(points[:, 0].tolist() + [points[0, 0], None])
            ys.extend(y_points.tolist()+ [y_points[0], None])

        return [go.Scatter(x=xs, y=ys, mode="lines", name="Event", fill="toself")]

    def plot_3d(self) -> List[go.Mesh3d]:
        """
        Plot the event in 3D.
        """

        # form cartesian product of all intervals
        intervals = [value.simple_sets for _, value in sorted(self.sorted.items())]
        simple_events = list(itertools.product(*intervals))
        traces = []

        # shortcut for the dimensions
        x, y, z = 0, 1, 2

        # for every atomic interval
        for simple_event in simple_events:

            # Create a 3D mesh trace for the rectangle
            traces.append(go.Mesh3d(
                # 8 vertices of a cube
                x=[simple_event[x].lower, simple_event[x].lower, simple_event[x].upper, simple_event[x].upper,
                   simple_event[x].lower, simple_event[x].lower, simple_event[x].upper, simple_event[x].upper],
                y=[simple_event[y].lower, simple_event[y].upper, simple_event[y].upper, simple_event[y].lower,
                   simple_event[y].lower, simple_event[y].upper, simple_event[y].upper, simple_event[y].lower],
                z=[simple_event[z].lower, simple_event[z].lower, simple_event[z].lower, simple_event[z].lower,
                   simple_event[z].upper, simple_event[z].upper, simple_event[z].upper, simple_event[z].upper],
                # i, j and k give the vertices of triangles
                i=[7, 0, 0, 0, 4, 4, 6, 6, 4, 0, 3, 2],
                j=[3, 4, 1, 2, 5, 6, 5, 2, 0, 1, 6, 3],
                k=[0, 7, 2, 3, 6, 7, 1, 1, 5, 5, 7, 6],
                flatshading=True
            ))
        return traces

    def plotly_layout(self) -> Dict:
        """
        Create a layout for the plotly plot.
        """
        if len(self.variables) == 1:
            result = {"xaxis_title": self.variables[0].name}
        elif len(self.variables) == 2:
            result = {"xaxis_title": self.variables[0].name,
                      "yaxis_title": self.variables[1].name}
        elif len(self.variables) == 3:
            result = dict(scene=dict(
                xaxis_title=self.variables[0].name,
                yaxis_title=self.variables[1].name,
                zaxis_title=self.variables[2].name)
            )
        else:
            raise NotImplementedError("Plotting is only supported for two and three dimensional events")

        return result

    cpdef void fill_missing_variables(self, variables):
        """
        Fill this with the variables that are not in self but in `variables`.
        The variables are mapped to their domain.

        :param variables: The variables to fill the event with
        """
        for variable in variables:
            if variable not in self:
                self[variable] = variable.domain

    cpdef to_json(self):
        return self.json_serializer.to_json()


class SimpleEventJSON(AbstractSimpleSetJSON):
    """
    JSON serializer for SimpleEvent.
    """

    def __init__(self, simple_event: SimpleEvent):
        super().__init__(simple_event)
        self.simple_event = simple_event

    def to_json(self) -> Dict[str, Any]:
        return {**super().to_json(),
                "assignments": [(variable.to_json(), assignment.to_json()) for variable, assignment in self.simple_event.sorted.items()]}

    @staticmethod
    def _from_json(data: Dict[str, Any]):
        return SimpleEvent({VariableJSON.from_json(variable): AbstractCompositeSetJSON.from_json(assignment) for variable, assignment in
             data["assignments"]})


cdef class Event(AbstractCompositeSet):
    """
    An event is a disjoint set of simple events.

    Every simple event added to this event that is missing variables that any other event in this event has, will be
    extended with the missing variable. The missing variables are mapped to their domain.

    """

    def __init__(self, *simple_sets):
        super().__init__(*simple_sets)
        self.fill_missing_variables()
        self.cpp_object = new CPPEvent()

        cdef SimpleEvent simple_set
        for simple_set in self.simple_sets:
            self.cpp_object.simple_sets.get().insert(shared_ptr[CPPAbstractSimpleSet](simple_set.cpp_simple_event_object))

    @property
    def all_variables(self) -> VariableSet:
        result = SortedSet()
        return result.union(*[SortedSet(simple_set.variables) for simple_set in self.simple_sets])

    cdef void fill_missing_variables(self):
        """
        Fill all simple sets with the missing variables.
        """
        cdef all_variables = self.all_variables
        for simple_set in self.simple_sets:
            simple_set.fill_missing_variables(all_variables)

    cpdef AbstractCompositeSet simplify(self):
        cdef tuple[Event, bint] simplified, changed = self.simplify_once()
        while changed:
            simplified, changed = simplified.simplify_once()
        return simplified

    def simplify_once(self) -> Tuple[Self, bool]:
        """
        Simplify the event once. This simplification is not guaranteed to as simple as possible.

        :return: The simplified event and a boolean indicating whether the event has changed or not.
        """

        # cpp_event = <CPPEvent> self.cpp_object
        # # cdef tuple[EventPtr_t, bint] event, bin = cpp_event.simplify_once()
        # x = tuple([(event.get(), bin) for event, bin in cpp_event.simplify_once()])
        # # return (event.get()[0], bin)
        # return None

        for event_a, event_b in itertools.combinations(self.simple_sets, 2):
            different_variables = SortedSet()

            # get all events where these two events differ
            for variable in event_a.variables:
                if event_a[variable] != event_b[variable]:
                    different_variables.add(variable)

                # if the pair of simple events mismatches in more than one dimension it cannot be simplified
                if len(different_variables) > 1:
                    break

            # if the pair of simple events mismatches in more than one dimension skip it
            if len(different_variables) > 1:
                continue

            # get the dimension where the two events differ
            different_variable = different_variables[0]

            # initialize the simplified event
            simplified_event = SimpleEvent()

            # for every variable
            for variable in event_a.variables:

                # if the variable is the one where the two events differ
                if variable == different_variable:
                    # set it to the union of the two events
                    simplified_event[variable] = event_a[variable].union_with(event_b[variable])

                # if the variable has the same assignment
                else:
                    # copy to the simplified event
                    simplified_event[variable] = event_a[variable]

            # create a new event with the simplified event and all other events
            result = Event(
                *([simplified_event] + [event for event in self.simple_sets if event != event_a and event != event_b]))
            return result, True

        # if nothing happened, return the original event and False
        return self, False

    cpdef AbstractCompositeSet new_empty_set(self):
        return Event()

    def complement_if_empty(self) -> Self:
        raise NotImplementedError("Complement of an empty Event is not yet supported.")

    def marginal(self, variables: VariableSet) -> Event:
        """
        Create the marginal event, that only contains the variables given..

        :param variables: The variables to contain in the marginal event
        :return: The marginal event
        """
        result = self.__class__()
        for simple_set in self.simple_sets:
            result.add_simple_set(simple_set.marginal(variables))
        return result.make_disjoint()

    def plot(self, color="#636EFA") -> Union[List[go.Scatter], List[go.Mesh3d]]:
        """
        Plot the complex event.

        :param color: The color to use for this event
        """
        traces = []
        show_legend = True
        for index, event in enumerate(self.simple_sets):
            event_traces = event.plot()
            for event_trace in event_traces:
                if len(event.keys()) == 2:
                    event_trace.update(name="Event", legendgroup=id(self), showlegend=show_legend,
                                       line=dict(color=color))
                if len(event.keys()) == 3:
                    event_trace.update(name="Event", legendgroup=id(self), showlegend=show_legend, color=color)
                show_legend = False
                traces.append(event_trace)
        return traces

    def plotly_layout(self) -> Dict:
        """
        Create a layout for the plotly plot.
        """
        return self.simple_sets[0].plotly_layout()

    def add_simple_set(self, simple_set: AbstractSimpleSet):
        """
        Add a simple set to this event.

        :param simple_set: The simple set to add
        """
        super().add_simple_set(simple_set)
        self.fill_missing_variables()


# Type definitions
if TYPE_CHECKING:
    SimpleEventContainer = SortedSet[SimpleEvent]
    EventContainer = SortedSet[Event]
    VariableSet = SortedSet[Variable]
else:
    SimpleEventContainer = SortedSet
    EventContainer = SortedSet
    VariableSet = SortedSet
