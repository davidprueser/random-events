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

class CPPSimpleInterval: public CPPAbstractSimpleSet {
public:
    float lower;
    float upper;
    BorderType left;
    BorderType right;

    CPPSimpleInterval(float lower = 0, float upper = 0, BorderType left = BorderType::OPEN, BorderType right = BorderType::OPEN) {
}

    bool operator==(const CPPAbstractSimpleSet &other) override{
        auto derived_other = (CPPSimpleInterval *) &other;
            return *this == *derived_other;
    }
//    bool operator==(const CPPSimpleInterval &other) const;
    bool operator<(const CPPAbstractSimpleSet &other) override{
        const auto derived_other = (CPPSimpleInterval *) &other;
        return *this < *derived_other;
    }
//    bool operator<(const CPPSimpleInterval &other) const;
    bool operator<=(const CPPAbstractSimpleSet &other) override{
        const auto derived_other = (CPPSimpleInterval *) &other;
        return *this <= *derived_other;
    }
//    bool operator<=(const CPPSimpleInterval &other) const;
//    bool operator!=(const CPPSimpleInterval &other) const;

    template<typename... Args>
    static CPPSimpleIntervalPtr_t make_shared(Args &&... args) {
        return std::make_shared<CPPSimpleInterval>(std::forward<Args>(args)...);
    };


    bool is_empty() override{
        return lower > upper or (lower == upper and (left == BorderType::OPEN or right == BorderType::OPEN));
    }

    bool is_singleton();

    CPPAbstractSimpleSetPtr_t intersection_with(const CPPAbstractSimpleSetPtr_t &other) override{
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

    SimpleSetSetPtr_t complement() override{
        auto resulting_intervals = make_shared_simple_set_set();

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

    std::string *non_empty_to_string() override{
        const char left_representation = left == BorderType::OPEN ? '(' : '[';
        const char right_representation = right == BorderType::OPEN ? ')' : ']';
        return new std::string(
                    left_representation + std::to_string(lower) + ", " + std::to_string(upper) + right_representation);
    };

    bool contains(const ElementaryVariant *element) override{
        return false;
    };

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

    CPPAbstractCompositeSetPtr_t simplify() override{
        auto result = make_shared_simple_set_set();
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

    CPPAbstractCompositeSetPtr_t make_new_empty() const override{
        return CPPInterval::make_shared();
    };

    bool is_singleton() const;
    bool contains(float element) const;
};