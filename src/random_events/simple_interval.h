// CPPAbstractCompositeSet.h

#ifndef SIMPLE_INTERVAL_H
#define SIMPLE_INTERVAL_H
#include <functional>
#include <memory>
#include <set>


class CPPAbstractSimpleSet;
class CPPAbstractCompositeSet;

// TYPE DEFINITIONS
template<typename T>
struct PointerLess {
    bool operator()(const T lhs, const T rhs) const {
        return *lhs < *rhs;
    }

};

typedef std::shared_ptr<CPPAbstractCompositeSet> CPPAbstractCompositeSetPtr_t;
typedef std::shared_ptr<CPPAbstractSimpleSet> CPPAbstractSimpleSetPtr_t;

typedef std::set<CPPAbstractSimpleSetPtr_t, PointerLess<CPPAbstractSimpleSetPtr_t>> CPPSimpleSetSet_t;
typedef std::shared_ptr<CPPSimpleSetSet_t> CPPSimpleSetSetPtr_t;

class CPPAbstractSimpleSet {
public:
    virtual ~CPPAbstractSimpleSet() = default;
    bool operator!=(const CPPAbstractSimpleSet& other) const;
    bool operator>(const CPPAbstractSimpleSet& other) const;
    bool operator>=(const CPPAbstractSimpleSet& other) const;
    bool operator==(const CPPAbstractSimpleSet& other) const;
    bool operator!=(const CPPAbstractSimpleSetPtr_t &other) const;
    virtual bool operator==(const CPPAbstractSimpleSet &other)= 0;
    virtual bool operator<(const CPPAbstractSimpleSet &other)= 0;
    virtual bool operator<=(const CPPAbstractSimpleSet &other)= 0;
};

class CPPSimpleInterval : public CPPAbstractSimpleSet{
public:
    float lower;
    float upper;
    int left;
    int right;

    explicit CPPSimpleInterval(float lower = 0, float upper = 0, int left = 0, int right = 0) {
        this->lower = lower;
        this->upper = upper;
        this->left = left;
        this->right = right;
    }
    bool operator==(const CPPAbstractSimpleSet& other) const;
    bool operator==(const CPPSimpleInterval& other) const;
    bool operator<(const CPPAbstractSimpleSet& other) const;
    bool operator<(const CPPSimpleInterval& other) const;
    bool operator<=(const CPPAbstractSimpleSet& other) const;
    bool operator<=(const CPPSimpleInterval& other) const;
};

class CPPAbstractCompositeSet {
public:
    std::set<CPPAbstractSimpleSet> *simple_sets;

    CPPAbstractCompositeSet() = default;

    virtual ~CPPAbstractCompositeSet() {
        simple_sets->clear();
    }


    virtual CPPAbstractCompositeSetPtr_t make_new_empty() const = 0;
    CPPAbstractCompositeSetPtr_t union_with(const CPPAbstractCompositeSet& other) const;
    CPPAbstractCompositeSetPtr_t intersection_with_simple_set(const CPPAbstractSimpleSet& other) const;
    CPPAbstractCompositeSetPtr_t make_disjoint() const;
    std::tuple<CPPAbstractCompositeSetPtr_t, CPPAbstractCompositeSetPtr_t> split_into_disjoint_and_non_disjoint();
    CPPAbstractCompositeSetPtr_t make_disjoint();
    CPPAbstractCompositeSetPtr_t intersection_with(const CPPAbstractSimpleSetPtr_t &simple_set);
    CPPAbstractCompositeSetPtr_t intersection_with(const CPPSimpleSetSetPtr_t &other);
    CPPAbstractCompositeSetPtr_t intersection_with(const CPPAbstractCompositeSetPtr_t &other);
    CPPAbstractCompositeSetPtr_t complement();
    CPPAbstractCompositeSetPtr_t union_with(const CPPAbstractSimpleSetPtr_t &other) const;
    CPPAbstractCompositeSetPtr_t union_with(const CPPAbstractCompositeSetPtr_t &other);
    CPPAbstractCompositeSetPtr_t difference_with(const CPPAbstractSimpleSetPtr_t &other);
    CPPAbstractCompositeSetPtr_t difference_with(const CPPAbstractCompositeSetPtr_t &other);
    bool contains(const CPPAbstractCompositeSetPtr_t &other);
};

#endif