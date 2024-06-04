# Jadwiga Swierczynska
# AI, 17.03.2024

# Solution is base on the following idea:
# we implement A* algorithm.

# Approximate distance to final location:
# Let {l1, l2, ..., ln} be a set of currently possible locations 
# and let dist(l) be a distance from location l to the nearest
# end point (calculated by BFS on the board). Then 
# approx_dist({l1, l2, ..., ln}) = max(dist(l1), ..., dist(ln)).


import numpy as np
import queue
import random
import functools
import heapq

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

def approx_dist(locs):
    res = max([dist_final_locs[xl, yl] for (xl,yl) in locs])
    return res

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
                heapq.heappush(q, (len(path)+1+approx_dist(nxt), nxt))

            if final:
                return paths[nxt]
            

    return "Not found :("

def find_path():
    locs = get_start_locs()
    path = Astar(locs)

    return path   

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
            print("PATH:", len(path))
            
            file_out.write(path)   

def main():
    solve()

if __name__ == "__main__":
    main()