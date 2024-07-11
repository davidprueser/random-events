#include <iostream>
#include "simple_interval.h"


//CPPAbstractCompositeSet CPPAbstractCompositeSet::union_with(const CPPAbstractCompositeSet& other) const{
//    auto result = make_new_empty();
//    result->simple_sets->insert(simple_sets->begin(), simple_sets->end());
//    result->simple_sets->insert(other);
//    auto result2 = result->make_disjoint();
//    return result2;
//}


bool CPPAbstractSimpleSet::operator!=(const CPPAbstractSimpleSet &other){
    return !operator==(other);
}

bool CPPAbstractSimpleSet::operator>(const CPPAbstractSimpleSet &other){
    return !operator<=(other);
}

bool CPPAbstractSimpleSet::operator>=(const CPPAbstractSimpleSet &other){
    return !operator<(other);
}

bool CPPAbstractCompositeSet::operator==(const CPPAbstractCompositeSet &other) const {
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


bool CPPAbstractCompositeSet::operator!=(const CPPAbstractCompositeSet &other) const {
    return !operator==(other);
}



bool CPPSimpleInterval::operator==(const CPPAbstractSimpleSet &other) override {
    auto derived_other = (CPPSimpleInterval *) &other;
    return *this == *derived_other;
};

bool CPPSimpleInterval::operator==(const CPPSimpleInterval &other) {
    return lower == other.lower and upper == other.upper and left == other.left and right == other.right;
};

bool CPPSimpleInterval::operator<(const CPPAbstractSimpleSet &other) override {
    const auto derived_other = (CPPSimpleInterval *) &other;
    return *this < *derived_other;
};

bool CPPSimpleInterval::operator<(const CPPSimpleInterval &other) {
    if (lower == other.lower) {
        return upper < other.upper;
    }
    return lower < other.lower;
};

bool CPPSimpleInterval::operator<=(const CPPAbstractSimpleSet &other) override {
    const auto derived_other = (CPPSimpleInterval *) &other;
    return *this <= *derived_other;
};

bool CPPSimpleInterval::operator<=(const CPPSimpleInterval &other) {
    if (lower == other.lower) {
        return upper <= other.upper;
    }
    return lower <= other.lower;
};




std::tuple<CPPAbstractCompositeSetPtr_t, CPPAbstractCompositeSetPtr_t>
CPPAbstractCompositeSet::split_into_disjoint_and_non_disjoint(){

    // initialize result for disjoint and non-disjoint sets
    auto disjoint = make_new_empty();
    auto non_disjoint = make_new_empty();

    // for every pair of simple sets
    for (const auto &simple_set_i: *simple_sets) {

        // initialize the difference of A_i
        auto difference = simple_set_i;

        // for every other simple set
        for (const auto &simple_set_j: *simple_sets) {

            // if the atomic simple_sets are the same, skip
            if (simple_set_i == simple_set_j) {
                continue;
            }

            // get the intersection of the atomic simple_sets
            auto intersection = simple_set_i->intersection_with(simple_set_j);

            // if the intersection is not empty, append it to the non-disjoint set
            if (!intersection->is_empty()) {
                non_disjoint->simple_sets->insert(intersection);
            }

            // get the difference of the simple set with the intersection.
            auto difference_with_intersection = difference->difference_with(intersection);

            // if the difference is empty
            if (difference_with_intersection->empty()) {
                // all further differences will also be empty and this iteration can be skipped.
                difference = nullptr;
                break;
            }

            // The difference should only contain 1 simple set since the intersection is completely in simple_set_i.
            difference = *difference->difference_with(intersection)->begin();
        }

        // if the difference is empty, skip
        if (difference == nullptr) {
            continue;
        }

        // append the simple_set_i without every other simple set to the disjoint set
        disjoint->simple_sets->insert(difference);
    }

    auto result = std::make_tuple(disjoint, non_disjoint);
    return result;
}

AbstractCompositeSetPtr_t AbstractCompositeSet::make_disjoint(){

    // initialize disjoint, non-disjoint and current sets
    AbstractCompositeSetPtr_t disjoint;
    AbstractCompositeSetPtr_t intersections;
    AbstractCompositeSetPtr_t current_disjoint;

    // start with the initial split
    std::tie(disjoint, intersections) = split_into_disjoint_and_non_disjoint();

    // as long the splitting still produces non-disjoint sets
    while (!intersections->is_empty()) {

        // split into disjoint and non-disjoint sets
        std::tie(current_disjoint, intersections) = intersections->split_into_disjoint_and_non_disjoint();

        // extend the result by the disjoint sets
        disjoint->simple_sets->insert(current_disjoint->simple_sets->begin(), current_disjoint->simple_sets->end());
    }

    // simplify and return the disjoint set
    return disjoint->simplify();;
}

AbstractCompositeSetPtr_t AbstractCompositeSet::intersection_with(const AbstractSimpleSetPtr_t &simple_set){
    auto result = make_new_empty();
    for (const auto& current_simple_set: *simple_sets) {
        auto intersection = current_simple_set->intersection_with(simple_set);
        if (!intersection->is_empty()) {
            result->simple_sets->insert(intersection);
        }
    }
    return result;
}

AbstractCompositeSetPtr_t AbstractCompositeSet::intersection_with(const SimpleSetSetPtr_t &other){
    auto result = make_new_empty();
    for (const auto& current_simple_set: *other) {
        auto current_result = intersection_with(current_simple_set);
        result->simple_sets->insert(current_result->simple_sets->begin(), current_result->simple_sets->end());
    }
    return result;
}

AbstractCompositeSetPtr_t AbstractCompositeSet::intersection_with(const AbstractCompositeSetPtr_t &other){
    auto result =  intersection_with(other->simple_sets);
    return result;
}

AbstractCompositeSetPtr_t AbstractCompositeSet::complement(){
    auto result = make_new_empty();
    bool first_iteration = true;
    for (const auto& simple_set: *simple_sets) {
        auto simple_set_complement = simple_set->complement();
        if (first_iteration) {
            first_iteration = false;
            result->simple_sets->insert(simple_set_complement->begin(), simple_set_complement->end());
            continue;
        }
        result = result->intersection_with(simple_set_complement);
    }
    return result;
    //auto intermediate = result->simplify();
    //return intermediate;
}

AbstractCompositeSetPtr_t AbstractCompositeSet::union_with(const AbstractSimpleSetPtr_t &other) const {
    auto result = make_new_empty();
    result->simple_sets->insert(simple_sets->begin(), simple_sets->end());
    result->simple_sets->insert(other);
    auto result2 = result->make_disjoint();
    return result2;
}

AbstractCompositeSetPtr_t AbstractCompositeSet::union_with(const AbstractCompositeSetPtr_t &other){
    auto result = make_new_empty();
    result->simple_sets->insert(simple_sets->begin(), simple_sets->end());
    result->simple_sets->insert(other->simple_sets->begin(), other->simple_sets->end());
    return result->make_disjoint();
}

AbstractCompositeSetPtr_t AbstractCompositeSet::difference_with(const AbstractSimpleSetPtr_t &other){
    auto result = make_new_empty();
    for (const auto& simple_set: *simple_sets) {
        const auto difference = simple_set->difference_with(other);
        result->simple_sets->insert(difference->begin(), difference->end());
    }
    return result->make_disjoint();
}

AbstractCompositeSetPtr_t AbstractCompositeSet::difference_with(const AbstractCompositeSetPtr_t &other){
    auto result = make_new_empty();

    for (const auto &own_simple_set: *simple_sets) {
        AbstractCompositeSetPtr_t current_difference = make_new_empty();
        bool first_iteration = true;

        for (const auto& other_simple_set: *other->simple_sets) {
            const auto difference_with_simple_set = own_simple_set->difference_with(other_simple_set);

            // handle first iteration
            if (first_iteration) {
                first_iteration = false;
                current_difference->simple_sets->insert(difference_with_simple_set->begin(),
                                                       difference_with_simple_set->end());
                continue;
            }

            auto difference = make_new_empty();
            difference->simple_sets->insert(difference_with_simple_set->begin(), difference_with_simple_set->end());
            current_difference = current_difference->intersection_with(difference);
        }
        result->simple_sets->insert(current_difference->simple_sets->begin(), current_difference->simple_sets->end());
    }
    return result->make_disjoint();
}

bool AbstractCompositeSet::contains(const AbstractCompositeSetPtr_t &other){
    return intersection_with(other) == other;
}
