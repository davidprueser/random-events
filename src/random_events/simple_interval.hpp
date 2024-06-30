#ifndef SIMPLE_INTERVAL_HPP
#define SIMPLE_INTERVAL_HPP

#include <functional>

enum class CPPBound {
    OPEN = 0,
    CLOSED = 1,
    };

CPPBound intersect(CPPBound first, CPPBound other) {
    if (first == CPPBound::OPEN || other == CPPBound::OPEN) {
        return CPPBound::OPEN;
    }
    return CPPBound::CLOSED;
}

CPPBound invert(CPPBound first) {
    if (first == CPPBound::OPEN) {
        return CPPBound::CLOSED;
    }
    return CPPBound::OPEN;
}

class CPPSimpleInterval {
public:
    float lower;
    float upper;
    CPPBound left;
    CPPBound right;

    CPPSimpleInterval(float lower = 0, float upper = 0, CPPBound left = CPPBound::OPEN, CPPBound right = CPPBound::OPEN)
        : lower(lower), upper(upper), left(left), right(right){}

    bool operator<(const CPPSimpleInterval& other) const {
        if (lower == other.lower) {
            return upper < other.upper;
        }
        return lower < other.lower;
    }

    bool operator==(const CPPSimpleInterval& other) const {
        return lower == other.lower && upper == other.upper && left == other.left && right == other.right;
    }

    bool contains(float value) const {
        return lower < value < upper || (lower == value && left == CPPBound::CLOSED) || (upper == value && right == CPPBound::CLOSED);
    }

    bool is_singleton() const {
        return lower == upper && left == CPPBound::CLOSED && right == CPPBound::CLOSED;
    }

    bool is_empty() const {
        return lower > upper || (lower == upper && (left == CPPBound::OPEN || right == CPPBound::OPEN));
    }

    float center() const {
        return ((lower + upper) / 2) + lower;
    }

    CPPSimpleInterval intersection_with(const CPPSimpleInterval& other) const {
        float new_lower = std::max(lower, other.lower);
        float new_upper = std::min(upper, other.upper);

        if (new_lower > new_upper) {
            return CPPSimpleInterval();
        }

        if (lower == other.lower) {
            CPPBound new_left = intersect(left, other.left);
        }
        else{
            CPPBound new_left = CPPBound::OPEN;
        }
    }
};

//namespace std {
//    template <>
//    struct hash<CPPSimpleInterval> {
//        std::size_t operator()(const CPPSimpleInterval& si) const {
//            return std::hash<float>()(si.lower) ^ std::hash<float>()(si.upper) ^
//                   std::hash<int>()(si.left) ^ std::hash<int>()(si.right);
//        }
//    };
//}

#endif