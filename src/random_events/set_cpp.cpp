#include "set_cpp.h"
#include <stdexcept>

CPPSetElement::CPPSetElement(int element_index, int all_elements_length) {
    this->element_index = element_index;
    this->all_elements_length = all_elements_length;

    if(element_index >= all_elements_length) {
        throw std::invalid_argument("element_index must be less than the number of elements in the all_elements set");
    }
}

CPPSetElement::~CPPSetElement() = default;

CPPAbstractSimpleSetPtr_t CPPSetElement::intersection_with(const CPPAbstractSimpleSetPtr_t &other) {
    const auto derived_other = (CPPSetElement *) other.get();
    auto result = make_shared_set_element(all_elements_length);
    if (this->element_index == derived_other->element_index) {
        result->element_index = this->element_index;
    }
    return result;
}

SimpleSetSetPtr_t CPPSetElement::complement() {
    auto result = make_shared_simple_set_set();
    for (int i = 0; i < all_elements_length; i++) {
        if (i == element_index) {
            continue;
        }
        result->insert(make_shared_set_element(i, all_elements_length));
    }

    return result;
}

bool CPPSetElement::contains(const ElementaryVariant *element) {
    return false;
}

bool CPPSetElement::is_empty() {
    return this->element_index == -1;
}

bool CPPSetElement::operator==(const CPPAbstractSimpleSet &other) {
    auto derived_other = (CPPSetElement *) &other;
    return *this == *derived_other;
}

bool CPPSetElement::operator==(const CPPSetElement &other) {
    return element_index == other.element_index;
}

bool CPPSetElement::operator<(const CPPAbstractSimpleSet &other) {
    const auto derived_other = (CPPSetElement *) &other;
    return *this < *derived_other;
}

bool CPPSetElement::operator<(const CPPSetElement &other) {
    return element_index < other.element_index;
}

bool CPPSetElement::operator<=(const CPPAbstractSimpleSet &other) {
    const auto derived_other = (CPPSetElement *) &other;
    return *this <= *derived_other;
}

bool CPPSetElement::operator<=(const CPPSetElement &other) {
    return element_index <= other.element_index;
}

std::string *CPPSetElement::non_empty_to_string() {
    return new std::string(std::to_string(element_index));
}

CPPSetElement::CPPSetElement(const int all_elements_length) {
    this->all_elements_length = all_elements_length;
    this->element_index = -1;
}

CPPSet::CPPSet(const CPPSetElementPtr_t &element_, const int all_elements_length) {
    this->simple_sets = make_shared_simple_set_set();
    this->simple_sets->insert(element_);
    this->all_elements_length = all_elements_length;
}

CPPSet::CPPSet(const int all_elements_length) {
    this->simple_sets = make_shared_simple_set_set();
    this->all_elements_length = all_elements_length;
}

CPPSet::CPPSet(const SimpleSetSetPtr_t &elements_, const int all_elements_length) {
    this->simple_sets = make_shared_simple_set_set();
    this->simple_sets->insert(elements_->begin(), elements_->end());
    this->all_elements_length = all_elements_length;
}

CPPAbstractCompositeSetPtr_t CPPSet::make_new_empty() const {
    return make_shared_set(all_elements_length);
}

CPPSet::~CPPSet() {
    simple_sets->clear();
}

CPPAbstractCompositeSetPtr_t CPPSet::simplify() {
    return std::make_shared<CPPSet>(simple_sets, all_elements_length);
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
