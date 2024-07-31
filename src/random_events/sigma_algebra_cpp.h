#pragma once

#include <set>
#include <vector>
#include <tuple>
#include <memory>
#include <string>

class CPPAbstractSimpleSet;
class CPPAbstractCompositeSet;

// TYPE DEFINITIONS
template<typename T>
struct PointerLess {
    bool operator()(const T lhs, const T rhs) const {
        return *lhs < *rhs;
    }

};

typedef std::shared_ptr<CPPAbstractSimpleSet> CPPAbstractSimpleSetPtr_t;
typedef std::shared_ptr<CPPAbstractCompositeSet> CPPAbstractCompositeSetPtr_t;

typedef std::set<CPPAbstractSimpleSetPtr_t, PointerLess<CPPAbstractSimpleSetPtr_t>> SimpleSetSet_t;
typedef std::shared_ptr<SimpleSetSet_t> SimpleSetSetPtr_t;

template<typename... Args>
SimpleSetSetPtr_t make_shared_simple_set_set(Args&&... args) {
    return std::make_shared<SimpleSetSet_t>(std::forward<Args>(args)...);
}


static std::string EMPTY_SET_SYMBOL = "∅";

union ElementaryVariant {
    float f;
    int i;
    std::string s;
};



class CPPAbstractSimpleSet : public std::enable_shared_from_this<CPPAbstractSimpleSet> {
public:
    virtual ~CPPAbstractSimpleSet() = default;

    /**
    * Intersect this with another simple set.
    *
    * @param other the other simples set.
    * @return The intersection of both as simple set.
    */
    virtual CPPAbstractSimpleSetPtr_t intersection_with(const CPPAbstractSimpleSetPtr_t &other)= 0;

    /**
    * This method depends on the type of simple set and has to be overwritten.
    *
    * @return The complement of this simple set as disjoint composite set.
    */
    virtual SimpleSetSetPtr_t complement()= 0;

    /**
    * Check if an elementary event is contained in this.
    *
    * @param element The element_index to check.
    * @return True if the element_index is contained in this.
    */
    virtual bool contains(const ElementaryVariant *element)= 0;


    /**
    * This method depends on the type of simple set and has to be overwritten.
    *
    * @return True if this is empty.
    */
    virtual bool is_empty()= 0;

    /**
    * Form the difference with another simple set.
    *
    * @param other The other simple set.
    * @return The difference as disjoint composite set.
    */
    SimpleSetSetPtr_t difference_with(const CPPAbstractSimpleSetPtr_t& other);

    virtual std::string *non_empty_to_string()= 0;

    std::string *to_string();

    virtual bool operator==(const CPPAbstractSimpleSet &other)= 0;

    virtual bool operator<(const CPPAbstractSimpleSet &other)= 0;

    virtual bool operator<=(const CPPAbstractSimpleSet &other)= 0;

    bool operator!=(const CPPAbstractSimpleSet &other);

    bool operator>(const CPPAbstractSimpleSet &other);

    bool operator>=(const CPPAbstractSimpleSet &other);

    std::shared_ptr<CPPAbstractSimpleSet> share_more()
    {
        return shared_from_this();
    }
};


template<typename T>
std::vector<std::tuple<T, T>> unique_combinations(const std::vector<T> &elements) {

    // initialize result
    std::vector<std::tuple<T, T>> combinations;

    // for every pair of elements
    for (std::size_t i = 0; i < elements.size(); ++i) {

        // get element_index from first vector
        T current_element1 = elements[i];
        for (std::size_t j = 0; j < i; ++j) {
            T current_element2 = elements[j];
            std::tuple<T, T> combination = std::make_tuple(current_element1, current_element2);
            combinations.push_back(combination);
        }
    }
    return combinations;
}


class CPPAbstractCompositeSet {
public:

    SimpleSetSetPtr_t simple_sets;

    CPPAbstractCompositeSet() = default;

    virtual ~CPPAbstractCompositeSet() {
        simple_sets->clear();
    }

    /**
    * @return True if this is empty.
    */
    bool is_empty();

    /**
     * @return True if the composite set is disjoint union of simple sets.
     */
    bool is_disjoint();

    /**
    * Simplify the composite set into a shorter but equal representation.
    * The size (shortness9 refers to the number of simple sets contained.
    *
    * @return The simplified composite set into a shorter but equal representation.
    */
    virtual CPPAbstractCompositeSetPtr_t simplify()= 0;

    /**

     * @return A **new** empty composite set
     */
    virtual CPPAbstractCompositeSetPtr_t make_new_empty() const = 0;

    virtual /**
     * @return A string representation of this.
     */
    std::string *to_string();

    bool operator==(const CPPAbstractCompositeSet &other) const;
    bool operator!=(const CPPAbstractCompositeSet &other) const;

    /**
    * Split this composite set into disjoint and non-disjoint parts.
    *
    * This method is required for making the composite set disjoint.
    * The partitioning is done by removing every other simple set from every simple set.
    * The purified simple sets are then disjoint by definition and the pairwise intersections are (potentially)
    * not disjoint yet.
    *
    * This method requires:
    *  - the intersection of two simple sets as a simple set
    *  - the difference of a simple set (A) and another simple set (B) that is completely contained in A (B ⊆ A).
    *      The result of that difference has to be a composite set with only one simple set in it.
    *
    * @return A tuple of disjoint and non-disjoint composite sets.
    */
    std::tuple<CPPAbstractCompositeSetPtr_t, CPPAbstractCompositeSetPtr_t> split_into_disjoint_and_non_disjoint();

    /**
    * Create an equal composite set that contains a disjoint union of simple sets.
    *
    * @return The disjoint composite set.
    */
    CPPAbstractCompositeSetPtr_t make_disjoint();

    /**
     * Form the intersection with an simple set.
     * The intersection is only disjoint if this is disjoint.
     * @param simple_set The simple event to intersect with.
     * @return The intersection.
     */
    CPPAbstractCompositeSetPtr_t intersection_with(const CPPAbstractSimpleSetPtr_t &simple_set);

    CPPAbstractCompositeSetPtr_t intersection_with(const SimpleSetSetPtr_t &other);

    /**
    * Form the intersection with another composite set.
    *
    * The intersection is only disjoint if both composite sets are disjoint.
    *
    * @param other The other composite set.
    * @return The intersection as composite set.
    */
    CPPAbstractCompositeSetPtr_t intersection_with(const CPPAbstractCompositeSetPtr_t &other);

    /**
     * @return the complement of a composite set as disjoint composite set.
     */
    CPPAbstractCompositeSetPtr_t complement();

    /**
    * Form the union with a simple set.
    *
    * @param other The other simple set.
    * @return The union as disjoint composite set.
    */
    CPPAbstractCompositeSetPtr_t union_with(CPPAbstractSimpleSetPtr_t &other) const;

    /**
    * Form the union with another composite set.
    *
    * @param other The other composite set.
    * @return The union as disjoint composite set.
    */
    CPPAbstractCompositeSetPtr_t union_with(const CPPAbstractCompositeSetPtr_t &other);

    /**
     * Form the difference with a simple set.
     *
     * @param other the simple set
     * @return The difference as disjoint composite set.
     */
    CPPAbstractCompositeSetPtr_t difference_with(const CPPAbstractSimpleSetPtr_t &other);

    /**
     * Form the difference with another composite set.
     *
     * @param other The other composite set.
     * @return The difference as disjoint composite set.
     */
    CPPAbstractCompositeSetPtr_t difference_with(const CPPAbstractCompositeSetPtr_t &other);

    bool contains(const CPPAbstractCompositeSetPtr_t &other);

};
