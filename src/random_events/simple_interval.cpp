#include <iostream>
#include "simple_interval.h"


CPPAbstractCompositeSet CPPAbstractCompositeSet::union_with(const CPPAbstractCompositeSet& other) const{
    auto result = make_new_empty();
    result->simple_sets->insert(simple_sets->begin(), simple_sets->end());
    result->simple_sets->insert(other);
    auto result2 = result->make_disjoint();
    return result2;
}



CPPSimpleInterval::CPPSimpleInterval(){}
CPPSimpleInterval::CPPSimpleInterval(float lower, float upper, int left, int right){
    this->lower = lower;
    this->upper = upper;
    this->left = left;
    this->right = right;
}

bool CPPSimpleInterval::operator<(const CPPSimpleInterval& other) const {
    if (lower == other.lower) {
        return upper < other.upper;
    }
    return lower < other.lower;
}

bool CPPSimpleInterval::operator==(const CPPSimpleInterval& other) const {
    return lower == other.lower && upper == other.upper && left == other.left && right == other.right;
}
