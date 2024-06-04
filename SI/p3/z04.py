# Jadwiga Swierczynska
# AI, 04.04.2024

# Solver for storms (a logic puzzle). 
# The solution is based on the following idea:
# we have to fulfill the constraints:
# - each pixel is 0 or 1
# - sum of pixels in each row and column must be equal to given values
# - each rectangle 3x1 and 1x3 must be valid
# - each square 2x2 must be valid

# Rectangle 1x3 [A, B, C] (similarily for 3x1) is valid
# <=> if B=1 then A=1 or C=1

# Square 2x2 [[A, B], [C, D]] is valid
# <=> (A=1 and D=1) iff (B=1 and C=1)


FILE_IN = "zad_input.txt"
FILE_OUT = "zad_output.txt"

def B(i,j):
    return 'B_%d_%d' % (i,j)

def domains(Bs):
    return [ q + ' in 0..1' for q in Bs ]

def get_row(n, m, i, sum):
    return "+".join([B(i,j) for j in range(m)]) + f" #= {sum}"

def get_col(n, m, j, sum):
    return "+".join([B(i,j) for i in range(n)]) + f" #= {sum}"

def valid_rectangle_horizontal(i, j):
    return f"{B(i, j+1)} #==> ({B(i, j)} + {B(i, j+2)} #> 0)"

def valid_rectangle_vertical(i, j):
    return f"{B(i+1, j)} #==> ({B(i, j)} + {B(i+2, j)} #> 0)"

def valid_square(i, j):
    return f"(({B(i,j)}+{B(i+1, j+1)} #= 2) #<==> ({B(i+1,j)}+{B(i, j+1)} #= 2))"

def row_sums(n, m, rows):
    return [get_row(n, m, i, rs) for i, rs in enumerate(rows)]

def col_sums(n, m, cols):
    return [get_col(n, m, j, cs) for j, cs in enumerate(cols)]

def rectangles_hor(n, m):
    return [valid_rectangle_horizontal(i, j) for i in range(n) for j in range(m-2)]

def rectangles_ver(n, m):
    return [valid_rectangle_vertical(i, j) for i in range(n-2) for j in range(m)]

def squares(n, m):
    return [valid_square(i, j) for i in range(n-1) for j in range(m-1)]

def assignments(vals):
    return [f"{B(i,j)} #= {v}" for [i, j, v] in vals]


def write_constraints(Cs, indent, d, file_out):
    position = indent
    file_out.write(indent * ' ')
    for c in Cs:
        file_out.write(c + ',')
        position += len(c)
        if position > d:
            position = indent
            file_out.write("\n")
            file_out.write(indent * ' ')
    
def storms(rows, cols, triples, file_out):
    writeln(':- use_module(library(clpfd)).', file_out)
    
    n = len(rows)
    m = len(cols)
    
    bs = [ B(i,j) for i in range(n) for j in range(m)]
    
    writeln('solve([' + ', '.join(bs) + ']) :- ', file_out)

    cs = domains(bs) + row_sums(n, m, rows) + col_sums(n, m, cols) + squares(n, m) + rectangles_hor(n, m) + rectangles_ver(n, m) + assignments(triples)

    write_constraints(cs, 4, 70, file_out)
    
    writeln('    labeling([ff], [' +  ', '.join(bs) + ']).' , file_out)
    writeln('', file_out)
    writeln(":- tell('prolog_result.txt'), solve(X), write(X), nl, told.", file_out)

def writeln(s, file_out):
    file_out.write(s + '\n')

def main():
    with open(FILE_IN) as file_in:
        txt = file_in.readlines()

    rows = [int(x) for x in txt[0].split()]
    cols = [int(x) for x in txt[1].split()]

    with open(FILE_OUT, 'w') as file_out:
        triples = []

        for i in range(2, len(txt)):
            if txt[i].strip():
                triples.append([int(x) for x in txt[i].split()])

        storms(rows, cols, triples, file_out)  
    

if __name__ == "__main__":
    main()



          
        

