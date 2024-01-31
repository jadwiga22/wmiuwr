# Jadwiga Swierczynska
# 11.10.2023

import math
import random

# max number of iterations 
THROWS = 10000

# precision
EPS = 1e-5


# checking if a point is in a circle
def inCircle(x, y):
    return (x-0.5)**2 + (y-0.5)**2 <= 0.25

def ApproxPi():
    inside = 0
    total = 0

    for i in range(0,THROWS):
        # generating point in a square 
        x = random.random()
        y = random.random()

        # incrementing counter
        if inCircle(x,y):
            inside += 1
        total +=1

        # calculating current approximation
        approx = inside * 4 / total
        print(f"step: {i} ->", approx)
        if abs( approx - math.pi) < EPS:
            break

def main():
    ApproxPi()

if __name__ == '__main__':
    main()