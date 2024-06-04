# Jadwiga Swierczynska
# AI, 22.02.2024

# Solution is based on the following idea:
# 1) create a random board
# 2) for r in 0, 1, ..., MAX_ROUNDS
#   2a) draw a row for which we have nonzero penalty (distance)
#   2b) if no such a row is found after (n+3) attempts
#        draw a column for which we have nonzero penalty (distance)
#   2c) for this row (column) find the best pixel
#       which minimizes total delta of the penalty after change
#   2d) change this pixel
#   2e) if the total penalty = 0, return the board
#  3) if valid board was not found, go to 1)


import numpy as np
import random

# maximum number of rounds performed 
# for the particular starting board
MAX_ROUNDS = 100

# finds optimal distance 
# i.e. min number of changes of bits
# needed to obtain one block of ones of length d
def opt_dist(xs, d):
    ones_left = 0
    ones_right = 0
    ones_center = 0

    for i in range(len(xs)):
        if xs[i] == 1:
            if i < d:
                ones_center +=1
            else:
                ones_right += 1

    min_ops = d-ones_center + ones_right

    for j in range(d, len(xs)):
        if xs[j-d] == 1:
            ones_left += 1
            ones_center -=1
        if xs[j] == 1:
            ones_center += 1
            ones_right -= 1
        
        min_ops = min(min_ops, d-ones_center + ones_right + ones_left)

    return min_ops

# given row i returns the best pixel (i,j)
# which minimizes total penalty after change
def find_pixel_row(board, penalty_cols, penalty_rows, cols, rows, i):
    n = len(penalty_rows)
    m = len(penalty_cols)
    best_j = -1
    best_di = n*n + 5
    best_dj = m*m + 5

    for j in range(m):
        di = -penalty_rows[i]
        dj = -penalty_cols[j]

        board[i,j] = 1-board[i,j]
        di += opt_dist(board[i], rows[i])
        dj += opt_dist(board[:,j], cols[j])
        board[i,j] = 1-board[i,j]

        if di+dj < best_di+best_dj:
            best_j = j
            best_di = di
            best_dj = dj

    return i, best_j, best_di, best_dj

# given column j returns the best pixel (i,j)
# which minimizes total penalty after change
def find_pixel_col(board, penalty_cols, penalty_rows, cols, rows, j):
    n = len(penalty_rows)
    m = len(penalty_cols)

    best_i = -1
    best_di = n*n + 5
    best_dj = m*m + 5

    for i in range(n):
        di = -penalty_rows[i]
        dj = -penalty_cols[j]

        board[i,j] = 1-board[i,j]
        di += opt_dist(board[i], rows[i])
        dj += opt_dist(board[:,j], cols[j])
        board[i,j] = 1-board[i,j]

        if di+dj < best_di+best_dj:
            best_i = i
            best_di = di
            best_dj = dj

    return best_i, j, best_di, best_dj

# finds the best pixel to change
# returns coordinates of this pixel and deltas of penalties
# (i, j, di, dj)
def change_pixel(n, m, board, penalty_cols, penalty_rows, cols, rows):
    for i in range(n+3):
        pos = random.randint(0,n-1)
        if penalty_rows[pos] != 0:
            return find_pixel_row(board, penalty_cols, penalty_rows, cols, rows, pos)
        
    for j in range(m+3):
        pos = random.randint(0, n-1)
        if penalty_cols[pos] != 0:
            return find_pixel_col(board, penalty_cols, penalty_rows, cols, rows, pos)
        
    return None

# simulation of coloring
# returns board if succeeded and None otherwise 
# (number of pixels changed is bounded by MAX_ROUNDS)
def simulate(rows, cols):
    n = len(rows)
    m = len(cols)
    board = np.random.randint(0,2,size=(n,m),dtype=int)
    penalty_rows = np.zeros(n, dtype=int)
    penalty_cols = np.zeros(m, dtype=int)
    penalty = 0

    for i in range(n):
        penalty_rows[i] = opt_dist(board[i], rows[i])
        penalty += penalty_rows[i]

    for i in range(m):
        penalty_cols[i] = opt_dist(board[:,i], cols[i])
        penalty += penalty_cols[i]
    
    for r in range(MAX_ROUNDS):
        try:
            i,j,di,dj = change_pixel(n, m, board, penalty_cols, penalty_rows, cols, rows)
            board[i,j] = 1 - board[i,j]

            penalty += (di+dj)

            penalty_rows[i] += di
            penalty_cols[j] += dj

        except TypeError:
            pass
        finally:
            if penalty == 0:
                return board
        
    return None

# try to simulate until valid board is found
def draw(rows, cols):
    board = simulate(rows, cols)

    while board is None:
        board = simulate(rows, cols)

    return board

def solve():
    with open("zad5_input.txt") as file:
        with open("zad5_output.txt", "w") as file_out:
            line0 = file.readline()
            n, m = [int(x) for x in line0.split()]
            rows = [0] * n
            cols = [0] * m

            for i in range(n):
                line = file.readline()
                x = [int(x) for x in line.split()][0]
                rows[i] = x

            for j in range(m):
                line = file.readline()
                x = [int(x) for x in line.split()][0]
                cols[j] = x

            board = draw(rows, cols)
            for r in board:
                file_out.write(("".join([("#" if x == 1 else ".") for x in r.tolist()])) + "\n")
                

def main():
    solve()

if __name__ == "__main__":
    main()