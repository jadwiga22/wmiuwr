# Jadwiga Swierczynska
# AI, 03.04.2024

# The solution is based on the following idea:
# firstly create a list of all possible rows and columns
# given the descriptions. Then perform ac3 for arcs for each
# triple (0/1, i, j) - where 0 denotes checking the domain of
# ith row and 1 denotes checking the domain of jth column. 

# After that perform a backtracking. Let r be an unassigned row. 
# For each v in the domain of r
#       assign value v to r
#       if it is consistent (ac3)
#           proceed to the next unassigned row
# If there are no unassigned rows, then return the result. 


from itertools import product
from collections import deque
import copy

FILE_IN = "zad_input.txt"
FILE_OUT = "zad_output.txt"


class Nonogram:
    # returns the description of a row/column
    def seq_description(self, xs):
        res = [len(x) for x in xs.split("0") if x != ""]
        if res == []:
            res = [0]
        return res
        
    # initalizes class - sets size of board
    # and desired rows and columns;
    # creates all possible rows and columns given the description
    # (unary constraints)
    def __init__(self, n, m, rows, cols):
        self.n = n
        self.m = m
        self.rows = rows
        self.cols = cols
        self.row_domains = [set() for _ in range(n)]
        self.col_domains = [set() for _ in range(m)]

        for row in product("01", repeat=m):
            row_string = "".join(row)
            desc = self.seq_description(row_string)

            for i in range(n):
                if desc == rows[i]:
                    self.row_domains[i].add(row_string)

        
        for col in product("01", repeat=n):
            col_string = "".join(col)
            desc = self.seq_description(col_string)

            for i in range(m):
                if desc == cols[i]:
                    self.col_domains[i].add(col_string)
    
    # revises domain of ith row
    def revise_row(self, i, j):
        to_delete = []

        for x in self.row_domains[i]:
            found = False

            for y in self.col_domains[j]:
                if x[j] == y[i]:
                    found = True
                    break
            
            if found:
                continue
            else:
                to_delete += [x]

        for x in to_delete:
            self.row_domains[i].remove(x)

        return to_delete != []
                
    # revises domain of jth column
    def revise_col(self, i, j):
        to_delete = []

        for y in self.col_domains[j]:
            found = False

            for x in self.row_domains[i]:
                if x[j] == y[i]:
                    found = True
                    break

            if found:
                continue
            else:
                to_delete += [y]

        for y in to_delete:
            self.col_domains[j].remove(y)
            
        return to_delete != []

    # performs ac3 on rows and columns with arcs
    def ac3(self):
        q = deque()

        # create arcs - triples
        # (b, i, j)
        # b = 0 - check for row
        # b = 1 - check for col
        for i in range(self.n):
            for j in range(self.m):
                q.append((0, i, j))
                q.append((1, i, j))

        while q:
            b, i, j = q.popleft()

            if b == 0:
                revised = self.revise_row(i, j)

                if len(self.row_domains[i]) == 0:
                    return False
                
                if revised:
                    for j2 in range(self.m):
                        if j2 == j:
                            continue
                        q.append((0, i, j2))
                        q.append((1, i, j2))
                        
            else:
                revised = self.revise_col(i, j)

                if len(self.col_domains[j]) == 0:
                    return False
                
                if revised:
                    for i2 in range(self.n):
                        if i2 == i:
                            continue
                        q.append((0, i2, j))
                        q.append((1, i2, j))


        return True

    # Performs backtracking. Finds first row that doesn't have assigned
    # value and iterates through all of the values from its domain. 
    # If it finds a value that is consistent with other rows and columns
    # then it proceeds to the next row. Otherwise it yields a failure. 
    def backtrack(self):
        row = None

        for i in range(self.n):
            if len(self.row_domains[i]) > 1:
                row = i
                break

        if row is None:
            return True
        
        
        row_domains = copy.deepcopy(self.row_domains)
        col_domains = copy.deepcopy(self.col_domains)


        for r in row_domains[row]:

            self.row_domains[row] = set()
            self.row_domains[row].add(r)

            if  self.ac3() and self.backtrack():
                return True

            self.row_domains = copy.deepcopy(row_domains)
            self.col_domains = copy.deepcopy(col_domains)


        return False

    # creates a valid board
    def get_board(self):
        self.ac3()
        self.backtrack()
        self.board = []

        for i in range(self.n):
            self.board += self.row_domains[i]



def solve():
    with open(FILE_IN) as file:
        with open(FILE_OUT, "w") as file_out:
            line0 = file.readline()
            n, m = [int(x) for x in line0.split()]
            rows = [0] * n
            cols = [0] * m

            for i in range(n):
                line = file.readline()
                x = [int(x) for x in line.split()]
                rows[i] = x

            for j in range(m):
                line = file.readline()
                x = [int(x) for x in line.split()]
                cols[j] = x

            sol = Nonogram(n, m, rows, cols)
            sol.get_board()
            
            for r in sol.board:
                file_out.write(("".join([("#" if x == '1' else ".") for x in r])) + "\n")
                

def main():
    solve()

if __name__ == "__main__":
    main()