#include "gtest/gtest.h"
#include "set_cpp.h"
#include <set>

TEST(CPPSetElement, Constructor) {
    CPPAllSetElementsPtr_t all_elements = make_shared_all_elements(3);
    CPPSetElement set_element(1, all_elements);
    EXPECT_EQ(set_element.element_index, 1);
    EXPECT_EQ(set_element.all_elements_length, all_elements);

    CPPSetElement set_element2(2, all_elements);
    EXPECT_EQ(set_element2.element_index, 2);
    EXPECT_EQ(set_element2.all_elements_length, all_elements);

    CPPSetElement set_element3(all_elements);
    EXPECT_EQ(set_element3.element_index, -1);
    EXPECT_EQ(set_element3.all_elements_length, all_elements);
}

TEST(CPPSetElement, IntersectionWith) {
    CPPAllSetElementsPtr_t all_elements = make_shared_all_elements(3);
    auto set_element1 = make_shared_set_element(1, all_elements);
    auto set_element2 = make_shared_set_element(2, all_elements);
    auto set_element3 = make_shared_set_element(1, all_elements);

    auto result = std::static_pointer_cast<CPPSetElement>(set_element1->intersection_with(set_element2));
    EXPECT_EQ(result->element_index, -1);
    EXPECT_TRUE(result->is_empty());

    result = std::static_pointer_cast<CPPSetElement>(set_element1->intersection_with(set_element3));
    EXPECT_EQ(result->element_index, 1);
    EXPECT_FALSE(result->is_empty());
}

TEST(CPPSetElement, Complement) {
    CPPAllSetElementsPtr_t all_elements = make_shared_all_elements(3);
    auto set_element1 = make_shared_set_element(1, all_elements);
    auto set_element2 = make_shared_set_element(2, all_elements);

    auto result = set_element1->complement();
    EXPECT_EQ(result->size(), 2);
    EXPECT_EQ(result->count(set_element1), 0);
    EXPECT_EQ(result->count(set_element2), 1);
}

TEST(CPPSet, Simplify){
    CPPAllSetElementsPtr_t all_elements = make_shared_all_elements(3);
    auto set_element1 = make_shared_set_element(1, all_elements);
    auto set_element2 = make_shared_set_element(2, all_elements);
    auto sets = make_shared_simple_set_set();
    sets->insert(set_element1);
    auto set = make_shared_set(sets, all_elements);
    auto result = set->simplify();
    EXPECT_EQ(result->simple_sets->size(), 1);
}

TEST(CPPSet, MakeNewEmpty) {
    CPPAllSetElementsPtr_t all_elements = make_shared_all_elements(3);
    auto set_element1 = make_shared_set_element(1, all_elements);
    auto set_element2 = make_shared_set_element(2, all_elements);
    auto sets = make_shared_simple_set_set();
    sets->insert(set_element1);
    sets->insert(set_element2);
    auto set = make_shared_set(sets, all_elements);
    auto result = set->make_new_empty();
}


TEST(CPPSet, Constructor) {
    CPPAllSetElementsPtr_t all_elements = make_shared_all_elements(3);
    auto set_element1 = make_shared_set_element(1, all_elements);
    auto set_element2 = make_shared_set_element(2, all_elements);
    auto sets = make_shared_simple_set_set();
    sets->insert(set_element1);
    sets->insert(set_element2);
    auto set = make_shared_set(sets, all_elements);
    //EXPECT_EQ(set->simple_sets, sets);
    //EXPECT_EQ(set->all_elements, all_elements);
    EXPECT_EQ(set->simple_sets->size(), 2);
    auto b = set->simplify();
    auto b2 = b->simplify();
    EXPECT_EQ(b2->simple_sets->size(), 2);
    auto a = set->complement();

    EXPECT_EQ(a->simple_sets->size(), 1);
}

TEST(CPPSet, UnionWith){
    auto all_elements = make_shared_all_elements(3);
    auto a = std::static_pointer_cast<CPPAbstractCompositeSet>(make_shared_set(all_elements));
    auto element = make_shared_set_element(0, all_elements);
    auto a_ = a->union_with(element);
    EXPECT_EQ(a_->simple_sets->size(), 1);
}