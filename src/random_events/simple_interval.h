#ifndef SIMPLE_INTERVAL_H
#define SIMPLE_INTERVAL_H
#include <functional>


class CPPAbstractSimpleSet {
public:
    virtual ~CPPAbstractSimpleSet() = default;
};

class CPPSimpleInterval : public CPPAbstractSimpleSet{
public:
    float lower;
    float upper;
    int left;
    int right;

    CPPSimpleInterval();
    CPPSimpleInterval(float lower, float upper, int left, int right);
    bool operator<(const CPPSimpleInterval& other) const;
    bool operator==(const CPPSimpleInterval& other) const;
};

class CPPAbstractCompositeSet {
public:
    virtual ~CPPAbstractCompositeSet() = default;
    CPPAbstractCompositeSet union_with(const CPPAbstractCompositeSet& other) const;

};

#endif