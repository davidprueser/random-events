#pragma once

#include "sigma_algebra_cpp.h"
#include <memory>
#include <utility>
#include <limits>

//FORWARD DECLARE
class CPPSimpleInterval;
class CPPInterval;


// TYPEDEFS
typedef std::shared_ptr<CPPSimpleInterval> CPPSimpleIntervalPtr_t;
typedef std::shared_ptr<CPPInterval> CPPIntervalPtr_t;


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

class CPPSimpleInterval: public CPPAbstractSimpleSet {
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

    bool operator==(const CPPAbstractSimpleSet &other) override;
    bool operator==(const CPPSimpleInterval &other) const;
    bool operator<(const CPPAbstractSimpleSet &other) override;
    bool operator<(const CPPSimpleInterval &other) const;
    bool operator<=(const CPPAbstractSimpleSet &other) override;
    bool operator<=(const CPPSimpleInterval &other) const;

    template<typename... Args>
    static CPPSimpleIntervalPtr_t make_shared(Args &&... args) {
        return std::make_shared<CPPSimpleInterval>(std::forward<Args>(args)...);
    };


    bool is_empty() override;
    bool is_singleton();
    CPPAbstractSimpleSetPtr_t intersection_with(const CPPAbstractSimpleSetPtr_t &other) override;
    SimpleSetSetPtr_t complement() override;
    std::string *non_empty_to_string() override;
    bool contains(const ElementaryVariant *element) override;
    bool contains(float element) const;

};


class CPPInterval: public CPPAbstractCompositeSet{
public:

    CPPInterval() {
        this->simple_sets = make_shared_simple_set_set();
    };

    explicit CPPInterval(const SimpleSetSetPtr_t &simple_sets_){
        this->simple_sets = simple_sets_;
    }
    explicit CPPInterval(SimpleSetSetPtr_t &simple_sets_){
        this->simple_sets = simple_sets_;
    }
    explicit CPPInterval(const CPPSimpleInterval &simple_interval){
        simple_sets->insert(std::make_shared<CPPSimpleInterval>(simple_interval));
    }

    ~CPPInterval() override {
        simple_sets->clear();
    }

    bool operator==(const CPPInterval &other) const;
    bool operator!=(const CPPInterval &other) const;

    template<typename... Args>
    static std::shared_ptr<CPPInterval> make_shared(Args &&... args) {
        return std::make_shared<CPPInterval>(std::forward<Args>(args)...);
    }

    CPPAbstractCompositeSetPtr_t simplify() override;
    CPPAbstractCompositeSetPtr_t make_new_empty() const override;
    bool is_singleton() const;
    bool contains(float element) const;
};