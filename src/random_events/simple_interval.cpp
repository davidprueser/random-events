#include <iostream>
#include <limits>
#include "simple_interval.h"

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





bool CPPSimpleInterval::operator==(const CPPSimpleInterval &other) const{
    return lower == other.lower and upper == other.upper and left == other.left and right == other.right;
}

bool CPPSimpleInterval::operator<(const CPPSimpleInterval &other) const{
    if (lower == other.lower) {
        return upper < other.upper;
    }
    return lower < other.lower;
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

bool CPPSimpleInterval::is_empty() {
    return lower > upper or (lower == upper and (left == BorderType::OPEN or right == BorderType::OPEN));
}

bool CPPSimpleInterval::is_singleton() {
    return lower == upper and left == BorderType::CLOSED and right == BorderType::CLOSED;
}

CPPSimpleIntervalPtr_t CPPSimpleInterval::intersection_with(const CPPSimpleIntervalPtr_t &other){
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

SimpleIntervalSetPtr_t CPPSimpleInterval::complement(){
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


std::string CPPSimpleInterval::non_empty_to_string(){
    const char left_representation = left == BorderType::OPEN ? '(' : '[';
    const char right_representation = right == BorderType::OPEN ? ')' : ']';
    return std::string(1, left_representation) + std::to_string(lower) + ", " + std::to_string(upper) + std::string(1, right_representation);
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

bool CPPInterval::operator!=(const CPPInterval &other) const{
    return !operator==(other);
}
