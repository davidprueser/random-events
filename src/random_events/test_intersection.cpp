#include <gtest/gtest.h>
#include "product_algebra_cpp.h"  // Include your SimpleEvent header file
#include "interval_cpp.h"  // Include your CPPInterval header file
#include "set_cpp.h"  // Include your CPPSetElement header file
#include "sigma_algebra_cpp.h"  // Include your CPPAbstractSimpleSet header file
#include <memory>

// run with g++ -std=c++17 test_intersection.cpp product_algebra_cpp.cpp interval_cpp.cpp set_cpp.cpp sigma_algebra_cpp.cpp -lgtest -lgtest_main -pthread -o test_intersection

TEST(SimpleEventTest, IntersectionWith) {
    std::cout << "SimpleEventTest, IntersectionWith" << std::endl;
    // Define the sets and intervals
    auto sa = make_shared_set_element(1, make_shared_all_elements(4));
    auto sb = make_shared_set_element(2, make_shared_all_elements(4));
    auto sc = make_shared_set_element(3, make_shared_all_elements(4));
    std::cout << "set elements work" << std::endl;

//    CPPInterval x_interval1(CPPSimpleInterval(0.0, 1.0, BorderType::OPEN, BorderType::OPEN));
//    CPPInterval x_interval2(CPPSimpleInterval(0.5, 1.0, BorderType::OPEN, BorderType::OPEN));
//    CPPInterval y_interval(CPPSimpleInterval(0.0, 1.0, BorderType::OPEN, BorderType::OPEN));
    std::cout << "intervals work" << std::endl;

    auto ss = make_shared_simple_set_set();
    ss->insert(sa);
    ss->insert(sb);
    ss->insert(sc);

    auto sab = make_shared_simple_set_set();
    sab->insert(sa);
    sab->insert(sb);

    auto a = make_shared_symbolic("a", make_shared_set(ss, make_shared_all_elements(4)));
    auto aa = make_shared_symbolic("a", make_shared_set(sa, make_shared_all_elements(4)));
    auto ab = make_shared_symbolic("a", make_shared_set(sb, make_shared_all_elements(4)));
    auto b = make_shared_symbolic("b", make_shared_set(sb, make_shared_all_elements(4)));
    auto c = make_shared_symbolic("c", make_shared_set(sc, make_shared_all_elements(4)));
    auto x = make_shared_continuous("x");
    auto y = make_shared_continuous("y");

    auto var = make_shared_variable_set();
    var->insert(aa);
    var->insert(x);
    var->insert(y);
    auto varab = make_shared_variable_set();
    varab->insert(a);
    varab->insert(b);

    auto var2 = make_shared_variable_set();
    var2->insert(a);
    var2->insert(x);

    auto var3 = make_shared_variable_set();
    var3->insert(a);

    auto var_exp = make_shared_variable_set();
    var_exp->insert(a);
    var_exp->insert(x);
    var_exp->insert(b);

    // Create SimpleEvent instances
    auto event1 = make_shared_simple_event(varab);
    auto event2 = make_shared_simple_event(var2);
    auto event_exp = make_shared_simple_event(var_exp);

    // Perform intersection
    std::cout << "before first intersection " << std::endl;
    auto intersection = event1->intersection_with(event2);
    std::cout << "first intersection " << *intersection->to_string() << std::endl;

    // Assertions
//    ASSERT_EQ(intersection, event_exp);
//    ASSERT_NE(intersection, event1);

    // Test for empty intersection
    auto event3 = make_shared_simple_event(var3);
    std::cout << "before second intersection " << std::endl;
    auto second_intersection = std::static_pointer_cast<SimpleEvent>(event1->intersection_with(event3));
    std::cout << "second intersection " << *second_intersection->to_string() << std::endl;
    ASSERT_TRUE(second_intersection->is_empty());
}

//int main(int argc, char **argv) {
//    ::testing::InitGoogleTest(&argc, argv);
//    return RUN_ALL_TESTS();
//}