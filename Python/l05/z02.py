# Jadwiga Swierczynska
# 31.10.2023

# exceptions

class MissingValuationOfVariable(Exception):
    "Raised when a variable in formula does not have associated valuation"
    pass

class InvalidValuationOfVariable(Exception):
    "Raised when a value associated to variable is not bool"
    pass

class InvalidVariableName(Exception):
    """Raised when a variable name is not valid, \
        i. e. a nonempty string containig only letters and not containing \
        "true" or "false" as a substring"""
    pass

class InvalidConstExpr(Exception):
    "Raised when expression passed to Const constructor is not a boolean"
    pass

# represenation of logic formulas

class Formula:
    def __add__(self, other):
        return Or(self, other)
    
    def __mul__(self, other):
        return And(self, other)
    
    def tautology(self):
        vars = list(self.getVars())

        def setVal(i, dict):
            if i >= len(vars):
                yield dict
            else:
                dict[vars[i]] = True
                yield from setVal(i+1, dict)
                dict[vars[i]] = False
                yield from setVal(i+1, dict)
        
        for v in setVal(0,{}):
            if not self.eval(v):
                return False
        return True
    
    def simplify(self):
        return self
        

class Const(Formula):
    def __init__(self, b):
        if not isinstance(b, bool):
            raise InvalidConstExpr
        self.b = b
    
    def __str__(self):
        if self.b:
            return "true"
        else:
            return "false"

    def eval(self, vars):
        return self.b
    
    def getVars(self):
        return set()


class Var(Formula):
    def __init__(self, p):
        if isinstance(p, str) and p.isalpha() and ("true" not in p) and ("false" not in p) and p != "":
            self.var = p
        else:
            raise InvalidVariableName

    def __str__(self):
        return self.var

    def eval(self, vars):
        if self.var not in vars:
            raise MissingValuationOfVariable
        elif not isinstance(vars[self.var], bool):
            raise InvalidValuationOfVariable
        else:  
            return vars[self.var]   
    
    def getVars(self):
        return {self.var}


class Not(Formula):
    def __init__(self, fi):
        self.fi = fi

    def __str__(self):
        if isinstance(self.fi, Var) or isinstance(self.fi, Const):
            return "¬" + self.fi.__str__()
        else:
            return  "¬(" + self.fi.__str__() + ")"

    def eval(self, vars):
        return not self.fi.eval(vars)
    
    def getVars(self):
        return self.fi.getVars()
    
    def simplify(self):
        f = self.fi.simplify()
        if isinstance(f, Not):
            return f.fi
        elif isinstance(f, Const):
            return Const(not f.b)
        else:
            return Not(f)


class Or(Formula):
    def __init__(self, fi, psi):
        self.fi, self.psi = fi, psi

    def __str__(self):
        return self.fi.__str__() + " ∨ " + self.psi.__str__() 

    def eval(self, vars):
        return self.fi.eval(vars) or self.psi.eval(vars)
    
    def getVars(self):
        return self.fi.getVars().union(self.psi.getVars())
    
    def simplify(self):
        l, r = self.fi.simplify(), self.psi.simplify()

        if (isinstance(l, Const) and l.b) or (isinstance(r, Const) and (not r.b)):
            return l
        elif (isinstance(l, Const) and (not l.b)) or (isinstance(r, Const) and r.b):
            return r
        else:
            return Or(l,r)


class And(Formula):
    def __init__(self, fi, psi):
        self.fi, self.psi = fi, psi

    def __str__(self):
        f, p = self.fi.__str__(), self.psi.__str__()
        if isinstance(self.fi, Or):
            f = "(" + f + ")"
        if isinstance(self.psi, Or):
            p = "(" + p + ")"
        return f + " ∧ " + p

    def eval(self, vars):
        return self.fi.eval(vars) and self.psi.eval(vars)
    
    def getVars(self):
        return self.fi.getVars().union(self.psi.getVars())
    
    def simplify(self):
        l, r = self.fi.simplify(), self.psi.simplify()
        if (isinstance(l, Const) and (not l.b)) or (isinstance(r, Const) and (not r.b)):
            return Const(False)
        elif isinstance(l, Const) and l.b:
            return r
        elif isinstance(r, Const) and r.b:
            return l
        else:
            return And(l,r)
    

def formula_test():
    f1 = Or(Not(Var("x")), And(Var("y"), Const(True)))
    f2 = Not(Var("x"))
    f3 = And(Or(Not(Const(False)), Var("s")), Var("x"))
    f4 = Not(Or(Var("x"), Not(Var("x"))))
    T = Const(True)
    F = Const(False)

    assert f1.__str__() == "¬x ∨ y ∧ true"
    assert f2.__str__() == "¬x"
    assert f3.__str__() == "(¬false ∨ s) ∧ x"
    assert f4.__str__() == "¬(x ∨ ¬x)"

    assert f1.eval({"x" : True, "y" : False}) == False
    assert f1.eval({"x" : False, "y" : False}) == True
    assert f2.eval({"x" : True}) == False
    assert f3.eval({"s" : True, "x" : True}) == True
    assert f4.eval({"x" : True}) == False
    assert f4.eval({"x" : False}) == False
    assert T.eval({}) == True
    assert F.eval({}) == False

    m1 = f1 * f2
    m2 = f3 * f4
    m3 = T * F
    a1 = f1 + f3
    a2 = f2 + f4
    a3 = F + T

    assert m1.__str__() == "(¬x ∨ y ∧ true) ∧ ¬x"
    assert m2.__str__() == "(¬false ∨ s) ∧ x ∧ ¬(x ∨ ¬x)"
    assert m3.__str__() == "true ∧ false"
    assert a1.__str__() == "¬x ∨ y ∧ true ∨ (¬false ∨ s) ∧ x"
    assert a2.__str__() == "¬x ∨ ¬(x ∨ ¬x)"
    assert a3.__str__() == "false ∨ true"

    f5 = Not(f4)

    # (p -> q) ∧ p -> q  ===  p ∧ ¬q ∨ ¬p ∨ q
    modus_ponens = Or(Or(And(Var("p"), Not(Var("q"))), Not(Var("p"))), Var("q"))

    assert f1.tautology() == False
    assert f2.tautology() == False
    assert f3.tautology() == False
    assert f4.tautology() == False
    assert f5.tautology() == True
    assert modus_ponens.tautology() == True
    assert T.tautology() == True
    assert F.tautology() == False

    assert f1.simplify().__str__() == "¬x ∨ y"
    assert f2.simplify().__str__() == "¬x"
    assert f3.simplify().__str__() == "x"
    assert f4.simplify().__str__() == "¬(x ∨ ¬x)"
    assert f5.simplify().__str__() == "x ∨ ¬x"
    assert m3.simplify().__str__() == "false"
    assert a3.simplify().__str__() == "true"


def exception_test():
    try:
        a = Const("s")
    except InvalidConstExpr:
        pass
    except:
        print("Unknown exception")
    else:
        print("Successfully executed, but it shouldn't have happened")

    try:
        a = Var("a ")
    except InvalidVariableName:
        pass
    except:
        print("Unknown exception")
    else:
        print("Successfully executed, but it shouldn't have happened")

    try:
        a = Var("true ")
    except InvalidVariableName:
        pass
    except:
        print("Unknown exception")
    else:
        print("Successfully executed, but it shouldn't have happened")

    try:
        a = Var("truea")
    except InvalidVariableName:
        pass
    except:
        print("Unknown exception")
    else:
        print("Successfully executed, but it shouldn't have happened")

    try:
        a = Var("false")
    except InvalidVariableName:
        pass
    except:
        print("Unknown exception")
    else:
        print("Successfully executed, but it shouldn't have happened")

    try:
        a = Var("")
    except InvalidVariableName:
        pass
    except:
        print("Unknown exception")
    else:
        print("Successfully executed, but it shouldn't have happened")

    try:
        a = Var("p1")
    except InvalidVariableName:
        pass
    except:
        print("Unknown exception")
    else:
        print("Successfully executed, but it shouldn't have happened")

    try:
        a = Var("123")
    except InvalidVariableName:
        pass
    except:
        print("Unknown exception")
    else:
        print("Successfully executed, but it shouldn't have happened")
    
    try:
        a = Var(1)
    except InvalidVariableName:
        pass
    except:
        print("Unknown exception")
    else:
        print("Successfully executed, but it shouldn't have happened")

    f1 = Or(Not(Var("x")), And(Var("y"), Const(True)))

    try:
        f1.eval({"x" : True})
    except MissingValuationOfVariable:
        pass
    except:
        print("Unknown exception")
    else:
        print("Successfully executed, but it shouldn't have happened")

    try:
        f1.eval({})
    except MissingValuationOfVariable:
        pass
    except:
        print("Unknown exception")
    else:
        print("Successfully executed, but it shouldn't have happened")

    try:
        f1.eval({"x" : 3, "y" : True})
    except InvalidValuationOfVariable:
        pass
    except:
        print("Unknown exception")
    else:
        print("Successfully executed, but it shouldn't have happened")

    try:
        f1.eval({"x" : 3})
    except InvalidValuationOfVariable:
        pass
    except MissingValuationOfVariable:
        pass
    except:
        print("Unknown exception")
    else:
        print("Successfully executed, but it shouldn't have happened")


def main():
    formula_test()
    exception_test()

if __name__ == '__main__':
    main()