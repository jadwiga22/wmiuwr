import timeit

def is_perfect(x):
    if x<=1:
        return False
    
    i = 2
    divSum = 0
    while i*i <= x:
        if x%i == 0:
            divSum += i
            if i*i < x:
                divSum += (x/i)

        i += 1

    return divSum+1 == x
    

def doskonale_imperatywna(n):
    res = []

    for x in range(2,n+1):
        if is_perfect(x):
            res.append(x)

    return res

def doskonale_skladana(n):
    # return [x for x in range(2,n+1) if is_perfect(x)]
    return [x for x in range(2,n+1) if sum(y for y in range(1,x) if x%y == 0) == x ]

def doskonale_funkcyjna(n):
    return list(filter(lambda x: sum(filter(lambda y: x%y == 0, range(1,x))) == x, range(2,n+1)))

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
    assert doskonale_imperatywna(10000) == [6, 28, 496, 8128]
    assert doskonale_imperatywna(5) == [] 

    assert doskonale_skladana(10000) == [6, 28, 496, 8128]
    assert doskonale_skladana(5) == [] 

    assert doskonale_funkcyjna(10000) == [6, 28, 496, 8128]
    assert doskonale_funkcyjna(5) == [] 

    timeRes = [["n", "imperatywna", "składana", "funkcyjna"]]

    for n in range(10,100,10):
        timeCur = [n, timeTest(doskonale_imperatywna, n), \
                timeTest(doskonale_skladana, n), \
                timeTest(doskonale_funkcyjna, n)]
        timeRes.append(timeCur)

    prettyPrint(timeRes)



if __name__ == '__main__':
    main()