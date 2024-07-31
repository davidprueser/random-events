#include <iostream>
#include <limits>
#include "interval_cpp.h"

/**
 * Logically intersect borders.
 * @param border_1 One of the borders to intersect.
 * @param border_2 The other border to intersect.
 * @return The intersection of the borders.
 */
inline BorderType intersect_borders(const BorderType border_1, const BorderType border_2) {
    return (border_1 == BorderType::OPEN || border_2 == BorderType::OPEN) ? BorderType::OPEN : BorderType::CLOSED;
}

/**
 * Logically t_complement a border.
 * @param border The borders to t_complement.
 * @return The t_complement a border.
 */
inline BorderType invert_border(const BorderType border) {
    return border == BorderType::OPEN ? BorderType::CLOSED : BorderType::OPEN;
}



bool CPPSimpleInterval::operator==(const CPPAbstractSimpleSet &other) override{
    auto derived_other = (CPPSimpleInterval *) &other;
        return *this == *derived_other;
}

bool CPPSimpleInterval::operator==(const CPPSimpleInterval &other) const{
    return lower == other.lower and upper == other.upper and left == other.left and right == other.right;
}

bool CPPSimpleInterval::operator<(const CPPAbstractSimpleSet &other) override{
    const auto derived_other = (CPPSimpleInterval *) &other;
    return *this < *derived_other;
}

bool CPPSimpleInterval::operator<(const CPPSimpleInterval &other) const{
    if (lower == other.lower) {
        return upper < other.upper;
    }
    return lower < other.lower;
}

bool CPPSimpleInterval::operator<=(const CPPAbstractSimpleSet &other) override{
    const auto derived_other = (CPPSimpleInterval *) &other;
    return *this <= *derived_other;
}

bool CPPSimpleInterval::operator<=(const CPPSimpleInterval &other) const{
    if (lower == other.lower) {
        return upper <= other.upper;
    }
    return lower <= other.lower;
}

bool CPPSimpleInterval::operator!=(const CPPSimpleInterval &other) const{
    return !operator==(other);
}

bool CPPSimpleInterval::is_empty() override{
    return lower > upper or (lower == upper and (left == BorderType::OPEN or right == BorderType::OPEN));
}

bool CPPSimpleInterval::is_singleton() {
    return lower == upper and left == BorderType::CLOSED and right == BorderType::CLOSED;
}

CPPAbstractSimpleSetPtr_t CPPSimpleInterval::intersection_with(const CPPAbstractSimpleSetPtr_t &other) override{
    const auto derived_other = (CPPSimpleInterval *) other.get();

    // get the new lower and upper bounds
    const float new_lower = std::max(lower, derived_other->lower);
    const float new_upper = std::min(upper, derived_other->upper);

    // return the empty interval if the new lower bound is greater than the new upper bound
    if (new_lower > new_upper) {
        return make_shared();
    }

    // initialize the new borders
    BorderType new_left;
    BorderType new_right;

    // if the lower bounds are equal, intersect the borders
    if (lower == derived_other->lower) {
        new_left = intersect_borders(left, derived_other->left);
    } else {
        // else take the border of the interval with the lower bound
        new_left = lower == new_lower ? left : derived_other->left;
    }

    // if the upper bounds are equal, intersect the borders
    if (upper == derived_other->upper) {
        new_right = intersect_borders(right, derived_other->right);
    } else {
        // else take the border of the interval with the upper bound
        new_right = upper == new_upper ? right : derived_other->right;
    }

    return make_shared(new_lower, new_upper, new_left, new_right);
};

SimpleSetSetPtr_t CPPSimpleInterval::complement() override{
    auto resulting_intervals = make_shared_simple_interval_set();

    // if the interval is the real line, return an empty set
    if (lower == -std::numeric_limits<float>::infinity() and
        upper == std::numeric_limits<float>::infinity()) {
        return resulting_intervals;
    }

    // if the interval is empty, return the real line
    if (is_empty()) {
        resulting_intervals->insert(
                CPPSimpleInterval::make_shared(-std::numeric_limits<float>::infinity(),
                                                         std::numeric_limits<float>::infinity(),
                                                         BorderType::OPEN, BorderType::OPEN));
        return resulting_intervals;
    }

    // if the interval has nothing left
    if (upper < std::numeric_limits<float>::infinity()) {
        resulting_intervals->insert(
                CPPSimpleInterval::make_shared(upper, std::numeric_limits<float>::infinity(),
                                                         invert_border(right), BorderType::OPEN));
    }

    if (lower > -std::numeric_limits<float>::infinity()) {
        resulting_intervals->insert(
                CPPSimpleInterval::make_shared(-std::numeric_limits<float>::infinity(), lower,
                                                         BorderType::OPEN, invert_border(left)));
    }

    return resulting_intervals;
};


std::string *CPPSimpleInterval::non_empty_to_string() override{
    const char left_representation = left == BorderType::OPEN ? '(' : '[';
    const char right_representation = right == BorderType::OPEN ? ')' : ']';
    return std::string(1, left_representation) + std::to_string(lower) + ", " + std::to_string(upper) + std::string(1, right_representation);
};

bool CPPSimpleInterval::contains(const ElementaryVariant *element) override{
    return false;
};

bool CPPSimpleInterval::contains(float element) const {
    if (left == BorderType::OPEN and element <= lower) {
        return false;
    }

    if (right == BorderType::OPEN and element >= upper) {
        return false;
    }

    if (left == BorderType::CLOSED and element < lower) {
        return false;
    }

    if (right == BorderType::CLOSED and element > upper) {
        return false;
    }

    return true;
};


bool CPPInterval::operator==(const CPPInterval &other) const{
    if (simple_sets->size() != other.simple_sets->size()) {
            return false;
        }
    auto it_lhs = simple_sets->begin();
    auto end_lhs = simple_sets->end();
    auto it_rhs = other.simple_sets->begin();

    while (it_lhs != end_lhs) {
        if (**it_lhs != **it_rhs) {
            return false;
        }
        ++it_lhs;
        ++it_rhs;
    }
    return true;
 }

CPPAbstractCompositeSetPtr_t CPPInterval::simplify() override{
    auto result = make_shared_simple_interval_set();
    bool first_iteration = true;

    for (const auto &current_simple_set: *simple_sets) {
        auto current_simple_interval = std::static_pointer_cast<CPPSimpleInterval>(current_simple_set);

        // if this is the first iteration, just copy the interval
        if (first_iteration) {
            result->insert(current_simple_interval);
            first_iteration = false;
            continue;
        }

        auto last_simple_interval = std::dynamic_pointer_cast<CPPSimpleInterval>(*result->rbegin());

        if (last_simple_interval->upper == current_simple_interval->lower &&
            !(last_simple_interval->right == BorderType::OPEN and
              current_simple_interval->left == BorderType::OPEN)) {
            last_simple_interval->upper = current_simple_interval->upper;
            last_simple_interval->right = current_simple_interval->right;
        } else {
            result->insert(current_simple_interval);
        }
    }

    return CPPInterval::make_shared(result);
};

CPPAbstractCompositeSetPtr_t CPPInterval::make_new_empty const override{
    return CPPInterval::make_shared();
};

bool CPPInterval::is_singleton() const{
    return simple_sets->size() == 1 and std::dynamic_pointer_cast<CPPSimpleInterval>(*simple_sets->begin())->is_singleton();
};

bool CPPInterval::contains() const{
    for (const auto &simple_set: *simple_sets) {
        auto simple_interval = std::static_pointer_cast<CPPSimpleInterval>(simple_set);
        if (simple_interval->contains(element)) {
            return true;
        }
    }
    return false;
};