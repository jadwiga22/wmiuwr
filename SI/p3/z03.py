# Jadwiga Swierczynska
# AI, 04.04.2024

# Sudoku solver in Prolog.
# Added condition for all of the variables within a 3x3 block
# to be different. 

import sys
from itertools import product
from contextlib import redirect_stdout

FILE_IN = "zad_input.txt"
FILE_OUT = "zad_output.txt"


def V(i,j):
    return 'V%d_%d' % (i,j)
    
def domains(Vs):
    return [ q + ' in 1..9' for q in Vs ]
    
def all_different(Qs):
    return 'all_distinct([' + ', '.join(Qs) + '])'
    
def get_column(j):
    return [V(i,j) for i in range(9)] 
            
def get_raw(i):
    return [V(i,j) for j in range(9)] 

# variables from ith 3x3 block
def get_block(i):
    return[V(i,j) for (i,j) in product(range(i-(i%3), i-(i%3)+3), range((i%3)*3, (i%3)*3 + 3))]
                        
def horizontal():   
    return [ all_different(get_raw(i)) for i in range(9)]

def vertical():
    return [all_different(get_column(j)) for j in range(9)]

# variables within all blocks must be different
def block():
    return [all_different(get_block(i)) for i in range(9)]

def print_constraints(Cs, indent, d):
    position = indent
    print (indent * ' ', end='')
    for c in Cs:
        print (c + ',', end=' ')
        position += len(c)
        if position > d:
            position = indent
            print ()
            print (indent * ' ', end='')

      
def sudoku(assigments):
    variables = [ V(i,j) for i in range(9) for j in range(9)]
    
    print (':- use_module(library(clpfd)).')
    print ('solve([' + ', '.join(variables) + ']) :- ')
    
    
    cs = domains(variables) + vertical() + horizontal() + block() #: added blocks
    for i,j,val in assigments:
        cs.append( '%s #= %d' % (V(i,j), val) )
    
    print_constraints(cs, 4, 70),
    print ()
    print ('    labeling([ff], [' +  ', '.join(variables) + ']).' )
    print ()
    print (':- solve(X), write(X), nl.')       

if __name__ == "__main__":
    raw = 0
    triples = []
    
    with open(FILE_IN) as file_in:
        while True:
            x = file_in.readline()
            if not x:
                break
            x = x.strip()
            if len(x) == 9:
                for i in range(9):
                    if x[i] != '.':
                        triples.append( (raw,i,int(x[i])) ) 
                raw += 1
    

    with open(FILE_OUT, 'w') as file_out:
        with redirect_stdout(file_out):
            sudoku(triples)
    
"""
89.356.1.
3...1.49.
....2985.
9.7.6432.
.........
.6389.1.4
.3298....
.78.4....
.5.637.48

53..7....
6..195...
.98....6.
8...6...3
4..8.3..1
7...2...6
.6....28.
...419..5
....8..79

3.......1
4..386...
.....1.4.
6.924..3.
..3......
......719
........6
2.7...3..
"""    
