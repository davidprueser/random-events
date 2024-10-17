#include "sigma_algebra_cpp.h"
#include <set>
#include <utility>
#include <algorithm>

// FORWARD DECLARATIONS
class CPPSetElement;

class CPPSet;


// TYPEDEFS
typedef std::set<std::string> CPPAllSetElements_t;
using CPPAllSetElementsPtr_t = std::shared_ptr<CPPAllSetElements_t>;
using CPPSetElementPtr_t = std::shared_ptr<CPPSetElement>;

template<typename... Args>
CPPAllSetElementsPtr_t make_shared_all_elements(Args &&... args) {
    return std::make_shared<std::set<std::string>>(std::forward<Args>(args)...);
}


template<typename... Args>
CPPSetElementPtr_t make_shared_set_element(Args &&... args) {
    return std::make_shared<CPPSetElement>(std::forward<Args>(args)...);
}

typedef std::shared_ptr<CPPSet> CPPSetPtr_t;

template<typename... Args>
CPPSetPtr_t make_shared_set(Args &&... args) {
    return std::make_shared<CPPSet>(std::forward<Args>(args)...);
}


class CPPSetElement : public CPPAbstractSimpleSet {
public:

    /**
     * The element to be chose from the all_elements set
     */
    std::string element;

    /**
     * The set of all possible strings
     */
    CPPAllSetElementsPtr_t all_elements;



    explicit CPPSetElement(const CPPAllSetElementsPtr_t &all_elements_);

    CPPSetElement(std::string element_, CPPAllSetElementsPtr_t &all_elements_);

    CPPSetElement(const std::string &element_, CPPAllSetElementsPtr_t &all_elements_);

    ~CPPSetElement() override;

    CPPAbstractSimpleSetPtr_t intersection_with(const CPPAbstractSimpleSetPtr_t &other) override;

    SimpleSetSetPtr_t complement() override;

    bool contains(const ElementaryVariant *element) override;

    bool is_empty() override;

    /**
     * Two simple sets are equal if the element_index is equal. The all_elements set is not considered.
     *
     * @param other The other simple set.
     * @return True if they are equal.
     */
    bool operator==(const CPPAbstractSimpleSet &other) override;

    bool operator==(const CPPSetElement &other);

    std::string *non_empty_to_string() override;

    bool operator<(const CPPAbstractSimpleSet &other) override;

    /**
     * Compare two set elements. Set elements are ordered by their element index.
     *
     * Note that all elements set is ignored in ordering.
     *
     * @param other The other interval
     * @return True if this interval is less than the other interval.
     */
    bool operator<(const CPPSetElement &other);


    bool operator<=(const CPPAbstractSimpleSet &other) override;

    /**
    * Compare two simple intervals. Simple intervals are ordered by lower bound. If the lower bound is equal, they are
    * ordered by upper bound.
    *
    * Note that border types are ignored in ordering.
    *
    * @param other The other interval
    * @return True if this interval is less or equal to the other interval.
    */
    bool operator<=(const CPPSetElement &other);

};

class CPPSet : public CPPAbstractCompositeSet {
public:

    CPPAllSetElementsPtr_t all_elements;

    explicit CPPSet(const CPPAllSetElementsPtr_t& all_elements_);
    CPPSet(const CPPSetElementPtr_t& element_, const CPPAllSetElementsPtr_t& all_elements_);
    CPPSet(const SimpleSetSetPtr_t& elements, const CPPAllSetElementsPtr_t& all_elements_);
    ~CPPSet() override;

    CPPAbstractCompositeSetPtr_t simplify() override;

    CPPAbstractCompositeSetPtr_t make_new_empty() const override;

    std::string *to_string() override;

};
