// CPPAbstractCompositeSet.h

#ifndef SIMPLE_INTERVAL_H
#define SIMPLE_INTERVAL_H
#include <functional>
#include <memory>
#include <set>


//FORWARD DECLARE
class CPPSimpleInterval;
class CPPInterval;

// TYPE DEFINITIONS
template<typename T>
struct PointerLess {
    bool operator()(const T lhs,
                    const T rhs) const {
        return *lhs < *rhs;
    }

};


// TYPEDEFS
typedef std::shared_ptr<CPPSimpleInterval> CPPSimpleIntervalPtr_t;
typedef std::shared_ptr<CPPInterval> CPPIntervalPtr_t;
typedef std::set<CPPSimpleIntervalPtr_t, PointerLess<CPPSimpleIntervalPtr_t>> SimpleIntervalSet_t;
typedef std::shared_ptr<SimpleIntervalSet_t> SimpleIntervalSetPtr_t;


template<typename... Args>
SimpleIntervalSetPtr_t make_shared_simple_interval_set(Args&&... args) {
    return std::make_shared<SimpleIntervalSet_t>(std::forward<Args>(args)...);
}

static std::string EMPTY_SET_SYMBOL = "∅";

union ElementaryVariant {
    float f;
    int i;
    std::string s;
};



enum class BorderType {
    /**
     * Open indicates that a value is included in the interval.
     */
    OPEN,

    /**
     * Close indicates that a value is excluded in the interval.
     */
    CLOSED
};

class CPPSimpleInterval: public std::enable_shared_from_this<CPPSimpleInterval>{
public:
    float lower;
    float upper;
    BorderType left;
    BorderType right;

    explicit CPPSimpleInterval(float lower = 0, float upper = 0, BorderType left = BorderType::OPEN, BorderType right = BorderType::OPEN) {
        this->lower = lower;
        this->upper = upper;
        this->left = left;
        this->right = right;

}

    bool operator==(const CPPSimpleInterval &other) const;
    bool operator<(const CPPSimpleInterval &other) const;
    bool operator<=(const CPPSimpleInterval &other) const;
    bool operator!=(const CPPSimpleInterval &other) const;

    template<typename... Args>
    static CPPSimpleIntervalPtr_t make_shared(Args &&... args) {
        return std::make_shared<CPPSimpleInterval>(std::forward<Args>(args)...);
    };


    bool is_empty();
    bool is_singleton();
    CPPSimpleIntervalPtr_t intersection_with(const CPPSimpleIntervalPtr_t &other);
    SimpleIntervalSetPtr_t complement();
    std::string non_empty_to_string();

};


class CPPInterval{
public:
    SimpleIntervalSetPtr_t simple_sets;

    CPPInterval() {
        this->simple_sets = make_shared_simple_interval_set();
    };

    explicit CPPInterval(const SimpleIntervalSetPtr_t &simple_sets_){
        this->simple_sets = simple_sets_;
    }
    explicit CPPInterval(SimpleIntervalSetPtr_t &simple_sets_){
        this->simple_sets = simple_sets_;
    }
    explicit CPPInterval(const CPPSimpleInterval &simple_interval){
        simple_sets->insert(std::make_shared<CPPSimpleInterval>(simple_interval));
    }

    bool operator==(const CPPInterval &other) const;
    bool operator!=(const CPPInterval &other) const;

};

#endif