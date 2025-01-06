#include "gtest/gtest.h"
#include "sigma_algebra_cpp.h"
#include "interval_cpp.h"
#include "variable_cpp.h"
#include "set_cpp.h"

TEST(Symbolic, ConstructorAndCompartor) {
    auto name = std::make_shared<std::string>("x");
    auto set_element1 = make_shared_set_element(0, make_shared_all_elements(3));
    auto set_element2 = make_shared_set_element(1, make_shared_all_elements(3));
    auto set_element3 = make_shared_set_element(2, make_shared_all_elements(3));
    auto simple_set_set = make_shared_simple_set_set();
    simple_set_set->insert(set_element1);
    simple_set_set->insert(set_element2);
    simple_set_set->insert(set_element3);
    auto set = make_shared_set(simple_set_set, make_shared_all_elements(3));
    auto symbol = make_shared_symbolic(name, set);
    EXPECT_EQ(symbol->name, name);
    EXPECT_EQ(symbol->domain->simple_sets->size(), 3);

    auto name2 = std::make_shared<std::string>("y");
    auto set_element4 = make_shared_set_element(0, make_shared_all_elements(2));
    auto set_element5 = make_shared_set_element(1, make_shared_all_elements(2));
    auto simple_set_set2 = make_shared_simple_set_set();
    simple_set_set2->insert(set_element4);
    simple_set_set2->insert(set_element5);
    auto set2 = make_shared_set(simple_set_set2, make_shared_all_elements(2));
    auto symbol2 = make_shared_symbolic(name2, set2);
    EXPECT_NE(symbol.get(), symbol2.get());
    EXPECT_LT(*symbol, *symbol2);
}

TEST(Continuous, Constructor) {
    auto name = std::make_shared<std::string>("x");
    auto real = make_shared_continuous(name);
    auto reals_to_compare = reals();
    EXPECT_EQ(real->name.get()->compare("x"), 0);
    EXPECT_EQ(*reals_to_compare, *real.get()->domain.get());
}
