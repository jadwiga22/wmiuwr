# Jadwiga Swierczynska
# AI, 28.03.2024

# Solution is based on the following idea:
# 1) create a random board
# 2) for r in 0, 1, ..., MAX_ROUNDS
#   2a) draw a row for which we have nonzero penalty (distance)
#   2b) if no such row was found after 1 attempt
#        draw a column for which we have nonzero penalty (distance)
#   2b') if no such column was found, go to 2a
#   2c) for this row (column) 
#       - with the probability = 0.75 find the best pixel
#           which minimizes total delta of the penalty after change
#       - with the probability = 0.25 draw a pixel at random
#   2d) change this pixel
#   2e) if the total penalty = 0, return the board
#  3) if valid board was not found, go to 1)


import numpy as np
import random
from itertools import product

FILE_IN = "zad_input.txt"
FILE_OUT = "zad_output.txt"

COIN_PROB = 75
MULT_PROBES = 50

class Nonogram:
    # returns the description of a row/column
    def seq_description(self, xs):
        res = [len(x) for x in xs.split("0") if x != ""]
        if res == []:
            res = [0]
        return res
    
    # initalizes class - sets size of board
    # and desired rows and columns;
    # sets max rounds for a particular start board to n*m*MULT_PROBES
    def __init__(self, n, m, rows, cols):
        self.n = n
        self.m = m
        self.rows = rows
        self.cols = cols
        self.dp = np.full((17, 17), 0, dtype=int)
        self.max_rounds = n*m*MULT_PROBES
        self.NUM_XS = {}
        self.cache = {}
        self.row_domains = {}

        for row in product("01", repeat=m):
            row_string = "".join(row)
            desc = self.seq_description(row_string)
            desc = tuple(desc)

            if desc in self.row_domains:
                self.row_domains[desc] += [row]
            else:
                self.row_domains[desc] = [row]
        
    def get_start_board(self):
        self.board = np.zeros(shape=(self.n, self.m))

        for i in range(self.n):
            r = random.choice(self.row_domains[self.rows[i]])
            self.board[i] = np.array([int(x) for x in r])

    # initializes round - draws pixels on board, 
    # calculates penalty for rows and columns
    def init_round(self):
        # cnt_ones = np.sum([np.sum(r) for r in self.rows])
        # print("HERE", cnt_ones)
        # self.board = np.random.randint(0,2,size=(self.n,self.m),dtype=int)
        # self.board = np.random.binomial(n=1, p=(cnt_ones/(self.n*self.m)), size=(self.n, self.m))
        self.get_start_board()
        self.board_transposed = np.copy(self.board.T, order="C")

        self.penalty_rows = np.zeros(self.n, dtype=int)
        self.penalty_cols = np.zeros(self.m, dtype=int)
        self.penalty = 0

        for i in range(self.n):
            self.penalty_rows[i] = self.opt_dist(self.board[i], self.rows[i])
            self.penalty += self.penalty_rows[i]

        for i in range(self.m):
            self.penalty_cols[i] = self.opt_dist(self.board_transposed[i], self.cols[i])
            self.penalty += self.penalty_cols[i]

    # finds optimal distance 
    # i.e. min number of changes of bits
    # needed to obtain blocks described by ds;
    # calculates the distance by counting the minimum 
    # of a number of different bits for all sequences that
    # correspond to ds
    def opt_dist(self, xs, ds):
        num_xs = xs.tobytes()
        if (num_xs, ds) in self.cache:
            return self.cache[(num_xs, ds)]       
        
        self.dp.fill(self.n*self.m+5)
        self.dp[0, 0] = 0
        start_idx = 0

        block = ds[0]
        j = 0
        cnt_zeros = block-np.sum(xs[0:block])
        cnt_ones = 0

        self.dp[block-1,1] = cnt_zeros
        
        for i in range(block, len(xs)):
            add = 0
            if xs[i] == 0:
                cnt_zeros += 1
            else:
                add = 1

            if xs[i-block] == 0:
                cnt_zeros -= 1
            else:
                cnt_ones += 1

            self.dp[i, j+1] = min(self.dp[i-1,j+1] + add, cnt_ones + cnt_zeros)

        start_idx += (block+1)

        for j, block in enumerate(ds[1:]):
            cnt_zeros = block-np.sum(xs[start_idx-1:start_idx+block-1])
            for i in range(start_idx+block-1, len(xs)):

                add1 = 0
                add2 = 0

                if xs[i] == 0:
                    cnt_zeros += 1
                else:
                    add1 = 1
                if xs[i-block] == 0:
                    cnt_zeros -= 1
                else:
                    add2 = 1
                    
                self.dp[i, j+2] = min(self.dp[i-1, j+2] + add1, self.dp[i-block-1, j+1] + cnt_zeros + add2)

            start_idx += (block+1)

            
        res = self.dp[len(xs)-1, len(ds)]
        self.cache[(num_xs, ds)] = res
        return res    

    # given row i returns the best pixel (i,j)
    # which minimizes total penalty after change
    def find_pixel_row(self, i):
        best_j = -1
        best_di = self.m*self.n + 5
        best_dj = self.m*self.n + 5

        for j in range(self.m):
            
            self.board[i,j] = 1-self.board[i,j]
            self.board_transposed[j,i] = 1-self.board_transposed[j,i]
            di = self.opt_dist(self.board[i], self.rows[i])-self.penalty_rows[i]
            dj = self.opt_dist(self.board_transposed[j], self.cols[j])-self.penalty_cols[j]
            self.board[i,j] = 1-self.board[i,j]
            self.board_transposed[j,i] = 1-self.board_transposed[j,i]

            if di+dj < best_di+best_dj:
                best_j = j
                best_di = di
                best_dj = dj

        return i, best_j, best_di, best_dj
    
    # given column j returns the best pixel (i,j)
    # which minimizes total penalty after change
    def find_pixel_col(self, j):
        best_i = -1
        best_di = self.n*self.m + 5
        best_dj = self.n*self.m + 5

        for i in range(self.n):
            self.board[i,j] = 1-self.board[i,j]
            self.board_transposed[j,i] = 1-self.board_transposed[j,i]
            di = self.opt_dist(self.board[i], self.rows[i]) -self.penalty_rows[i]
            dj = self.opt_dist(self.board_transposed[j], self.cols[j])-self.penalty_cols[j]
            self.board[i,j] = 1-self.board[i,j]
            self.board_transposed[j,i] = 1-self.board_transposed[j,i]

            if di+dj < best_di+best_dj:
                best_i = i
                best_di = di
                best_dj = dj

        return best_i, j, best_di, best_dj
    
    # finds the best (with probability = 0.75) pixel (or random,  with probability = 0.25) to change
    # returns coordinates of this pixel and deltas of penalties
    # (i, j, di, dj)
    def change_pixel(self):
        coin = int(random.random()*2)

        if coin == 0:
            pos = int(random.random()*self.m)
            if self.penalty_cols[pos] != 0:
                coin = int(random.random()*100)
                if coin < COIN_PROB:
                    return self.find_pixel_col(pos)
                else:
                    j = pos
                    i = int(random.random()*self.n)
                    self.board[i,j] = 1-self.board[i,j]
                    self.board_transposed[j,i] = 1-self.board_transposed[j,i]
                    di = self.opt_dist(self.board[i], self.rows[i]) -self.penalty_rows[i]
                    dj = self.opt_dist(self.board_transposed[j], self.cols[j])-self.penalty_cols[j]
                    self.board[i,j] = 1-self.board[i,j]
                    self.board_transposed[j,i] = 1-self.board_transposed[j,i]
                    return i, j, di, dj
        else:
            pos = int(random.random()*self.n)
            if self.penalty_rows[pos] != 0:
                coin = int(random.random()*100)
                if coin < COIN_PROB:
                    return self.find_pixel_row(pos)   
                else:
                    i = pos
                    j = int(random.random()*self.m)
                    self.board[i,j] = 1-self.board[i,j]
                    self.board_transposed[j,i] = 1-self.board_transposed[j,i]
                    di = self.opt_dist(self.board[i], self.rows[i]) -self.penalty_rows[i]
                    dj = self.opt_dist(self.board_transposed[j], self.cols[j])-self.penalty_cols[j]
                    self.board[i,j] = 1-self.board[i,j]
                    self.board_transposed[j,i] = 1-self.board_transposed[j,i]
                    return i, j, di, dj 
        
        return None


    # simulation of coloring
    # returns board if succeeded and None otherwise 
    # (number of pixels changed is bounded by MAX_ROUNDS = n*m*MULT_PROBES)
    def simulate(self):
        self.init_round()

        for r in range(self.max_rounds):
            if self.penalty == 0:
                return 
            
            p = self.change_pixel()

            if p is None:
                continue
            
            i,j,di,dj = p
            self.board[i,j] = 1 - self.board[i,j]
            self.board_transposed[j,i] = 1-self.board_transposed[j,i]
            self.penalty += (di+dj)

            self.penalty_rows[i] += di
            self.penalty_cols[j] += dj


    # try to simulate until valid board is found
    def draw(self):
        self.simulate()
        while self.penalty != 0:
            self.simulate()      


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
                rows[i] = tuple(x)

            for j in range(m):
                line = file.readline()
                x = [int(x) for x in line.split()]
                cols[j] = tuple(x)

            sol = Nonogram(n,m,rows,cols)
            sol.draw()
            for r in sol.board:
                file_out.write(("".join([("#" if x == 1 else ".") for x in r.tolist()])) + "\n")
                

def main():
    solve()

if __name__ == "__main__":
    main()