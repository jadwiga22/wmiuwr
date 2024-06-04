# Jadwiga Swierczynska
# AI, 17.03.2024

# Solution is base on the following idea:
# - firstly we reduce the number of possible starting locations by making greedy moves
# - then we simply run bfs to move to the set of final locations 

# Uncertainty (number of possible starting locations): 2 or 3

import numpy as np
import queue
import random

FILE_IN = "zad_input.txt"
FILE_OUT = "zad_output.txt"

MOVES = "LDRU"
MOVES_INT = [(0, -1), (1, 0), (0, 1), (-1, 0)]
REDUCTION_ROUNDS = 10

board = []
n = 0
m = 0

def reduce_locs(locs):
    path = ""

    global n,m

    start_moves =  (min(n-1,m-1) * [2,3]) + (max(n-1,m-1) * [0,1]) + (6*[2]) + (4*[1]) + ((m-1)*[0]) + (4 * [1])

    for mov in start_moves:
        path += MOVES[mov]
        locs = move(locs, mov)
    return locs, path


def final_location(locs):
    for x,y in locs:
        if board[x][y] != "B" and board[x][y] != "G":
            return False
        
    return True

def valid_move(x, y):
    return board[x][y] != "#"

def move(locs, i):
    new_locs = []
    for (x,y) in locs:
        dx = x+MOVES_INT[i][0]
        dy = y+MOVES_INT[i][1]
        if valid_move(dx, dy):
            new_locs += [(dx, dy)]
        else:
            new_locs += [(x, y)]
    new_locs = tuple(list(set(new_locs)))
    return new_locs

def neighbours(locs):
    res = []
    for i in range(4):
        res += [(move(locs, i), MOVES[i])]
    return res


def bfs(possible_loc, start_string):
    vis = set()

    possible_loc = tuple(list(set(possible_loc)))
    vis.add(possible_loc)

    q = queue.Queue()
    q.put((possible_loc, ""))

    while not q.empty():
        cur, path = q.get()
        # print("BFS", cur, path)
        if final_location(cur):
            return start_string+path
        for nxt, move in neighbours(cur):
            if nxt not in vis:
                vis.add(nxt)
                q.put((nxt, path+move))

    return "Not found :("

def get_start_locs():
    res = []
    for i in range(n):
        for j in range(m):
            if board[i][j] == "S" or board[i][j] == "B":
                res += [(i,j)]
    return tuple(res)

def find_path():
    locs = get_start_locs()
    locs, path = reduce_locs(locs)
    # print(locs, path)

    # for i in range(n):
    #     row = ""
    #     for j in range(m):
            
    #         # row += board[i][j]
    #         if (i,j) in locs:
    #             row += "H"
    #         else:
    #             row += board[i][j]
    #     print(row)

    return bfs(locs, path)      

def solve():
    with open(FILE_IN) as file:
        with open(FILE_OUT, "w") as file_out:
            while True:
                line = file.readline()
                if not line:
                    break
                line = line.replace("\n", "")
                global board
                board += [line]

            global n
            n = len(board)
            global m
            m = len(board[0])

            path = find_path()
            # print("PATH:", len(path))
            
            file_out.write(path)   

def main():
    solve()

if __name__ == "__main__":
    main()