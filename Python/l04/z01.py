# Jadwiga Swierczynska
# 23.10.2023

import timeit, functools
from math import *

def pierwsze_imperatywna(n):
    res = []
    for x in range(2,n+1):
        i = 2
        is_prime = True
        while i*i <= x:
            if x%i == 0:
                is_prime = False
                break
            i += 1
        if is_prime:
            res.append(x)

    return res

def pierwsze_skladana(n):
    return [x for x in range(2,n+1) if [] == [y for y in range(2,floor(sqrt(x))+1) if x%y == 0] ]

def pierwsze_funkcyjna(n):
    return list(filter(lambda x: list(filter(lambda y: x%y == 0, range(2,floor(sqrt(x))+1))) == [], \
                        range(2,n+1)))

def timeTest(f, n):
    t = timeit.Timer(lambda: f(n))
    return t.timeit(10000)

def prettyPrint(t):
    colLen = 15

    for ls in t:
        for l in ls:
            if type(l) == float:
                print(("{: >"+str(colLen)+".4f}").format(l), end="")
            else:
                print(("{: >"+str(colLen)+"}").format(l), end="")
            
        print()

def main():
    assert pierwsze_imperatywna(20) == [2, 3, 5, 7, 11, 13, 17, 19]
    assert pierwsze_imperatywna(1) == [] 

    assert pierwsze_skladana(20) == [2, 3, 5, 7, 11, 13, 17, 19]
    assert pierwsze_skladana(1) == [] 

    assert pierwsze_funkcyjna(20) == [2, 3, 5, 7, 11, 13, 17, 19]
    assert pierwsze_funkcyjna(1) == [] 

    timeRes = [["n", "imperatywna", "składana", "funkcyjna"]]

    for n in range(10,100,10):
        timeCur = [n, timeTest(pierwsze_imperatywna, n), \
                timeTest(pierwsze_skladana, n), \
                timeTest(pierwsze_funkcyjna, n)]
        timeRes.append(timeCur)

    prettyPrint(timeRes)



if __name__ == '__main__':
    main()