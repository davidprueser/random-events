#pragma once
#include <string>
#include <memory>
#include "sigma_algebra_cpp.h"
#include "interval_cpp.h"
#include "set_cpp.h"
#include <iostream>

using NamePtr_t = std::shared_ptr<std::string>;


class AbstractVariable {
public:
    virtual ~AbstractVariable() = default;

    NamePtr_t name;

    virtual CPPAbstractCompositeSetPtr_t get_domain() const = 0;

    const std::type_info& get_type() const {
        return typeid(*this);
    }

    bool operator==(const AbstractVariable &other) const {
        return *this->name == *other.name;
    }

    /**
     * Compare two variables. Variables are ordered by their name.
     *
     * Note that the domain is ignored in ordering.
     *
     * @param other The other variable
     * @return True if this variable is less than the other variable.
     */
    bool operator<(const AbstractVariable &other) const {
        return *name < *other.name;
    }

    /**
     * Compare two variables. Variables are ordered by their name.
     *
     * Note that the domain is ignored in ordering.
     *
     * @param other The other variable
     * @return True if this variable is less or equal than the other variable.
     */
    bool operator<=(const AbstractVariable &other) const {
        return *name <= *name;
    }

};

using AbstractVariablePtr_t = std::shared_ptr<AbstractVariable>;

class Symbolic : public AbstractVariable {
public:
    CPPSetPtr_t domain;

    Symbolic(const NamePtr_t& name, const CPPSetPtr_t& domain) {
        this->name = name;
        this->domain = domain;
    }

    Symbolic(const char* name, const CPPSetPtr_t& domain) {
        this->name = std::make_shared<std::string>(name);
        this->domain = domain;
    }

    CPPAbstractCompositeSetPtr_t get_domain() const override {
        return domain;
    }
};

class Continuous : public AbstractVariable {
public:
    const CPPIntervalPtr_t domain = reals();

    explicit Continuous(const NamePtr_t &name) {
        this->name = name;
    }

    explicit Continuous(const char* name) {
        this->name = std::make_shared<std::string>(name);
    }

    CPPAbstractCompositeSetPtr_t get_domain() const override {
        return domain;
    }
};

class Integer : public AbstractVariable {
public:
    const CPPIntervalPtr_t domain = reals();

    explicit Integer(const NamePtr_t &name) {
        this->name = name;
    }

    explicit Integer(const char* name) {
        this->name = std::make_shared<std::string>(name);
    }

    CPPAbstractCompositeSetPtr_t get_domain() const override {
        return domain;
    }

};


using SymbolicPtr_t = std::shared_ptr<Symbolic>;
using IntegerPtr_t = std::shared_ptr<Integer>;
using ContinuousPtr_t = std::shared_ptr<Continuous>;

template<typename... Args>
SymbolicPtr_t make_shared_symbolic(Args &&... args) {
    return std::make_shared<Symbolic>(std::forward<Args>(args)...);
}

template<typename... Args>
IntegerPtr_t make_shared_integer(Args &&... args) {
    return std::make_shared<Integer>(std::forward<Args>(args)...);
}

template<typename... Args>
ContinuousPtr_t make_shared_continuous(Args &&... args) {
    return std::make_shared<Continuous>(std::forward<Args>(args)...);
}
