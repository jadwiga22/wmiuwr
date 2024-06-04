# Jadwiga Swierczynska
# AI, 17.03.2024

# Solution is base on the following idea:
# we implement A* algorithm with the few versions of the approximate 
# distance function instead of max:
# - sum
# - max+1
# - 2max
# - max^2
# - 1.5max

# Results decribed below.

import numpy as np
import queue
import random
import functools
import heapq
import time

FILE_IN = "zad_input.txt"
FILE_OUT = "zad_output.txt"

MOVES = "LDRU"
MOVES_INT = [(0, -1), (1, 0), (0, 1), (-1, 0)]

board = []
n = 0
m = 0
dist_final_locs = []

def final_location(locs):
    for x,y in locs:
        if board[x][y] != "B" and board[x][y] != "G":
            return False
        
    return True

@functools.cache
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
    yield from [(move(locs, i), MOVES[i]) for i in range(4)]

def find_final_dists(final_locs):
    q = queue.Queue()

    global dist_final_locs
    dist_final_locs = np.full((n,m), n*m, dtype=int)
    
    for xl, yl in final_locs:
        q.put((xl, yl))
        dist_final_locs[xl, yl] = 0

    while not q.empty():
        x, y = q.get()

        for i in range(4):
            dx = x+MOVES_INT[i][0]
            dy = y+MOVES_INT[i][1]

            if valid_move(dx, dy) and dist_final_locs[dx,dy] == n*m:
                dist_final_locs[dx,dy] = dist_final_locs[x,y]+1
                q.put((dx, dy))


# z03.py: time = 26s, moves = 526

#  max -> sum : 738-526=212, 0.23841142654418945s
# def approx_dist(locs):
#     res = sum([dist_final_locs[xl, yl] for (xl,yl) in locs])
#     return res

# max -> max+1 : opt, 26.5s 
# def approx_dist(locs):
#     res = max([dist_final_locs[xl, yl] for (xl,yl) in locs])+1
#     return res

# max ->2max : 582-526=56, 2.550671339035034s
def approx_dist(locs):
    res = max([dist_final_locs[xl, yl] for (xl,yl) in locs])*2
    return res

# max -> max^2 : 611-526=85, 0.10352778434753418s
# def approx_dist(locs):
#     res = max([dist_final_locs[xl, yl] for (xl,yl) in locs])**2
#     return res

# max ->1.5max : 559-526=33, 9.23263955116272s               
# def approx_dist(locs):
#     res = max([dist_final_locs[xl, yl] for (xl,yl) in locs])*3 // 2
#     return res

def get_start_locs():
    res = []
    for i in range(n):
        for j in range(m):
            if board[i][j] == "S" or board[i][j] == "B":
                res += [(i,j)]
    return tuple(res)

def get_final_locs():
    res = []
    for i in range(n):
        for j in range(m):
            if board[i][j] == "G" or board[i][j] == "B":
                res += [(i,j)]
    return tuple(res)

def Astar(possible_loc):

    possible_loc = tuple(list(set(possible_loc)))
    final_locs = get_final_locs()
    find_final_dists(final_locs)

    q = [(approx_dist(possible_loc), possible_loc)]
    heapq.heapify(q)

    paths = {}
    paths[possible_loc] = ""

    vis = set()

    if final_location(possible_loc):
        return ""

    while q != []:
        _, cur = heapq.heappop(q)

        if (cur in vis):
            continue
            
        vis.add(cur)

        path = paths[cur]
            
        for i in range(4):
            nxt = []
            final = True
            for (x, y) in cur:
                dx = x+MOVES_INT[i][0]
                dy = y+MOVES_INT[i][1]

                if not valid_move(dx,dy):
                    dx = x
                    dy = y
                
                if board[dx][dy] != "G" and board[dx][dy] != "B":
                    final = False

                nxt += [(dx,dy)]

            nxt = tuple(list(set(nxt)))
            move = MOVES[i]

            if (not (nxt in paths)) or len(path)+1 < len(paths[nxt]):
                paths[nxt] = path+move
                # q.put((len(path)+1+approx_dist(nxt), nxt))
                heapq.heappush(q, (len(path)+1+approx_dist(nxt), nxt))

            if final:
                return paths[nxt]

    return "Not found :("

def find_path():
    locs = get_start_locs()
    path = Astar(locs)

    return path   

def solve():
    start_time = time.time()
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
            print("PATH:", len(path))
            
            file_out.write(path)   

            s = 0

            with open("results_nopt_z04.txt") as file_ans:
                line = file_ans.readline()
                
                if line:
                    s = int(line.replace("\n", ""))

            with open("results_nopt_z04.txt", "w") as file_ans:
                file_ans.write(str(s+len(path)))

    end_time = time.time()

    t = 0
    with open("time_nopt_z04.txt") as file_ans:
        line = file_ans.readline()
        
        if line:
            t = float(line.replace("\n", ""))


    with open("time_nopt_z04.txt", "w") as file_ans:
        file_ans.write(str(t + end_time - start_time))


def main():
    solve()

if __name__ == "__main__":
    main()