#ifndef SIMPLE_INTERVAL_HPP
#define SIMPLE_INTERVAL_HPP

#include <functional>

class CPPSimpleInterval {
public:
    float lower;
    float upper;
    int left;
    int right;

    CPPSimpleInterval(float lower = 0, float upper = 0, int left = 0, int right = 0)
        : lower(lower), upper(upper), left(left), right(right) {}

    bool operator<(const CPPSimpleInterval& other) const {
        if (lower == other.lower) {
            return upper < other.upper;
        }
        return lower < other.lower;
    }

    bool operator==(const CPPSimpleInterval& other) const {
        return lower == other.lower && upper == other.upper && left == other.left && right == other.right;
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