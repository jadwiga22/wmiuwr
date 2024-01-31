import func_timeout

def sudan(n, x, y):
    if n == 0:
        return x+y
    elif y == 0:
        return x
    else:
        return sudan(n-1, sudan(n, x, y-1), sudan(n, x, y-1)+y)

cache = {}

def sudanMemo(n, x, y):
    if((n, x, y) in cache):
        return cache[(n, x, y)]
    
    if n == 0:
        cache[(n, x, y)] = x+y
    elif y == 0:
        cache[(n, x, y)] = x
    else:
        cache[(n, x, y)] = sudanMemo(n-1, sudanMemo(n, x, y-1), sudanMemo(n, x, y-1)+y)

    return cache[(n, x, y)]

def run_function(f, n, x, y):
    try:
        return func_timeout.func_timeout(1, f, args=(n,x,y))
    except func_timeout.FunctionTimedOut:
        pass
    return None


# BEZ SPAMIETYWANIA:

# max czas wykonania: 1s
# dla n = 0 -> mozemy uzyc dowolnie duzych x,y (bo funkcja liczy sie w O(1))
# dla y = 0 -> analogicznie mozemy uzyc dowolnie duzego n,x
# wpp:
# - jesli wezmiemy n = 1 -> musimy wziac y <= 22 (bo inaczej dlugo sie liczy)
#                        -> wtedy mozemy wziac duze x (nawet <= 10^800)
# - jesli wezmiemy n = 2 -> dla y = 1 : x <= 21
#                        -> dla y = 2 : x <= 1
#                        -> dla y = 3 : x <= 0
#                        -> dla y = 4 : nawet dla x=0 za gleboka rekursja
# - jesli wezmiemy n > 2 -> x <= 1, y <= 1


# print(run_function(sudan, 1, 10**800, 22))
# print(run_function(sudan, 3, 1, 2))

# ZE SPAMIETYWANIEM:

# max czas wykonania: 1s
# dla n = 0 -> mozemy uzyc dowolnie duzych x,y (bo funkcja liczy sie w O(1))
# dla y = 0 -> analogicznie mozemy uzyc dowolnie duzego n,x
# wpp:
# - jesli wezmiemy n = 1 -> y <= 994 (potem komunikat o zbyt glebokiej rekursji), x dowolnie duze
# - jesli wezmiemy n = 2 -> dla y = 1 : x <= 992
#                        -> dla y = 2 : x <= 5
#                        -> dla y = 3 : x <= 0
#                        -> dla y = 4 : nawet dla x=0 za gleboka rekursja
# - jesli wezmiemy n > 2 -> dla y = 1 : x <= 1
#                        -> dla y = 2 : nawet dla x=0 za gleboka rekursja


# print(run_function(sudanMemo, 3, 0, 2))
