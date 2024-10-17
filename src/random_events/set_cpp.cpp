#include "set_cpp.h"
#include <stdexcept>

CPPSetElement::CPPSetElement(std::string element_, CPPAllSetElementsPtr_t &all_elements_) {

    this->element = element_;
    this->all_elements = all_elements_;

//    if (element == '-1') {
//        throw std::invalid_argument("element must be non-negative");
//    }

//    if (element != all_elements->size()) {
//        throw std::invalid_argument("element_index must be less than the number of elements in the all_elements set");
//    }
}

CPPSetElement::CPPSetElement(const std::string &element_, CPPAllSetElementsPtr_t &all_elements_) {
    this->all_elements = all_elements_;

    if (element_.empty()) {
        throw std::invalid_argument("element must not be empty");
    }

    auto it = std::find(all_elements->begin(), all_elements->end(), element_);
    if (it == all_elements->end()) {
        throw std::invalid_argument("element must be in the all_elements set");
    }

    this->element = std::distance(all_elements->begin(), it);

}

CPPSetElement::~CPPSetElement() = default;

CPPAbstractSimpleSetPtr_t CPPSetElement::intersection_with(const CPPAbstractSimpleSetPtr_t &other) {
    const auto derived_other = (CPPSetElement *) other.get();
    auto result = make_shared_set_element(all_elements);
    if (this->element == derived_other->element) {
        result->element = this->element;
    }
    return result;
}

SimpleSetSetPtr_t CPPSetElement::complement() {
    return make_shared_simple_set_set();
}

//SimpleSetSetPtr_t CPPSetElement::complement() {
//    auto result = make_shared_simple_set_set();
//    for (int i = 0; i < all_elements->size(); i++) {
//        if (i == element) {
//            continue;
//        }
//        result->insert(make_shared_set_element(i, all_elements));
//    }
//
//    return result;
//}

bool CPPSetElement::contains(const ElementaryVariant *element) {
    return false;
}

bool CPPSetElement::is_empty() {
    return this->element == "-1";
}

bool CPPSetElement::operator==(const CPPAbstractSimpleSet &other) {
    auto derived_other = (CPPSetElement *) &other;
    return *this == *derived_other;
}

bool CPPSetElement::operator==(const CPPSetElement &other) {
    return element == other.element;
}

bool CPPSetElement::operator<(const CPPAbstractSimpleSet &other) {
    const auto derived_other = (CPPSetElement *) &other;
    return *this < *derived_other;
}

bool CPPSetElement::operator<(const CPPSetElement &other) {
    return element < other.element;
}

bool CPPSetElement::operator<=(const CPPAbstractSimpleSet &other) {
    const auto derived_other = (CPPSetElement *) &other;
    return *this <= *derived_other;
}

bool CPPSetElement::operator<=(const CPPSetElement &other) {
    return element <= other.element;
}

std::string *CPPSetElement::non_empty_to_string() {
    return new std::string(element);
}

CPPSetElement::CPPSetElement(const CPPAllSetElementsPtr_t &all_elements_) {
    this->all_elements = all_elements_;
    this->element = -1;
}

CPPSet::CPPSet(const CPPSetElementPtr_t &element_, const CPPAllSetElementsPtr_t &all_elements_) {
    this->simple_sets = make_shared_simple_set_set();
    this->simple_sets->insert(element_);
    this->all_elements = all_elements_;
}

CPPSet::CPPSet(const CPPAllSetElementsPtr_t &all_elements_) {
    this->simple_sets = make_shared_simple_set_set();
    this->all_elements = all_elements_;
}

CPPSet::CPPSet(const SimpleSetSetPtr_t &elements_, const CPPAllSetElementsPtr_t &all_elements_) {
    this->simple_sets = make_shared_simple_set_set();
    this->simple_sets->insert(elements_->begin(), elements_->end());
    this->all_elements = all_elements_;
}

CPPAbstractCompositeSetPtr_t CPPSet::make_new_empty() const {
    return make_shared_set(all_elements);
}

CPPSet::~CPPSet() {
    simple_sets->clear();
}

CPPAbstractCompositeSetPtr_t CPPSet::simplify() {
    return std::make_shared<CPPSet>(simple_sets, all_elements);
}

std::string *CPPSet::to_string() {
    if (is_empty()) {
        return &EMPTY_SET_SYMBOL;
    }
    auto result = new std::string("{");

    bool first_iteration = true;

    for (const auto &simple_set: *simple_sets) {
        if (first_iteration) {
            first_iteration = false;
        } else {
            result->append(", ");
        }
        result->append(*simple_set->to_string());
    }

    result->append("}");

    return result;
}
