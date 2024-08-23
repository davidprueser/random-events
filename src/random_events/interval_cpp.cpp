#include <iostream>
#include <limits>
#include "interval_cpp.h"


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

bool CPPSimpleInterval::is_singleton() {
    return lower == upper and left == BorderType::CLOSED and right == BorderType::CLOSED;
}

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

bool CPPInterval::is_singleton() const{
    return simple_sets->size() == 1 and std::dynamic_pointer_cast<CPPSimpleInterval>(*simple_sets->begin())->is_singleton();
};

bool CPPInterval::contains(float element) const{
    for (const auto &simple_set: *simple_sets) {
        auto simple_interval = std::static_pointer_cast<CPPSimpleInterval>(simple_set);
        if (simple_interval->contains(element)) {
            return true;
        }
    }
    return false;
};