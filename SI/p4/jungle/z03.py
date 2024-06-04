# Jadwiga Swierczynska
# AI, 15.05.2024

# Two agents for Jungle
# 1) described in problem statement, simulating game outcomes
#   for all possible moves
# 2) alpha-beta with iterative deepening
#   (heuristics: sum of strength of pawns, 
#       min distance to competitor's cave,
#       sum of distances to competitor's wall,
#       mobility)

# Results with bosses:
# - random (10:0)
# - baloo (10:0)


import random
from copy import copy, deepcopy
from enum import Enum
import numpy as np
from time import time
import queue
import sys

INF = 1000000000000000
DIV = 10000000
DEPTH = 4
MAX_DEPTH = 100
MAX_N = 23000
MINIMAX_TIME = 0.4

class WrongMove(Exception):
    pass

class Jungle:
    N = 7
    M = 9
    DIRS = [(0, 1), (1, 0), (-1, 0), (0, -1)]
    
    MAP_BOARD = [
        list("..#*#.."),
        list("...#..."),
        list("......."),
        list(".~~.~~."),
        list(".~~.~~."),
        list(".~~.~~."), 
        list("......."),
        list("...#..."),
        list("..#*#..")
    ]

    # lower case - player 0
    # upper case - player 1
    INIT_BOARD = [
        list("L.....T"),
        list(".D...C."),
        list("R.J.W.E"),
        list("......."),
        list("......."),
        list("......."),
        list("e.w.j.r"),
        list(".c...d."),
        list("t.....l")
    ]

    VALID_PAWNS = ["r", "c", "d", "w", "j", "t", "l", "e"]

    STRENGTHS = ["r", "c", "d", "w", "j", "t", "l", "e"]

    def __init__(self):
        self.board = self.initial_board()
        self.move_list = []

    def initial_board(self):
        return deepcopy(self.INIT_BOARD)

    def draw(self):
        for i in range(self.M):
            res = []
            for j in range(self.N):
                if self.board[i][j] != ".":
                    res += [self.board[i][j]]
                else:
                    res += [self.MAP_BOARD[i][j]]
            print(res, file=sys.stderr)
        print('', file=sys.stderr)

    def pawn_player(self, player, pawn):
        if pawn.islower() and player == 0:
            return True
        elif pawn.isupper() and player == 1:
            return True
        else:
            return False
        
    def get_strength(self, pawn : str):
        return self.STRENGTHS.index(pawn.lower())
        
    def own_cave(self, x, y, player):
        if self.get_map(x, y) == "*" and ((player == 0 and y == self.M-1) or (player == 1 and y == 0)):
            return True
        else:
            return False
        
    def get(self, x, y):
        if 0 <= x < self.N and 0 <= y < self.M:
            return self.board[y][x]
        return None
    
    def get_map(self, x, y):
        if 0 <= x < self.N and 0 <= y < self.M:
            return self.MAP_BOARD[y][x]
        return None
    
    def water(self, x, y):
        if 0 <= x < self.N and 0 <= y < self.M:
            return self.MAP_BOARD[y][x] == "~"
        return False
    
    def stronger(self, pawn, next_pawn):
        pawn_lower = pawn.lower()
        next_pawn_lower = next_pawn.lower()

        if pawn_lower == "r" and next_pawn_lower == "e":
            return True
        
        if pawn_lower == "e" and next_pawn_lower == "r":
            return False
        
        strength = self.get_strength(pawn)
        next_strength = self.get_strength(next_pawn)

        return strength >= next_strength
        
    
    def can_beat(self, pawn, cur_x, cur_y, x, y, player):
        next_pawn = self.get(x,y)
        map_field = self.get_map(x,y)

        if self.pawn_player(player, next_pawn):
            return False
        
        if pawn.lower() == "r":
            if self.water(cur_x,cur_y) and (not self.water(x, y)):
                return False        
        
        return self.stronger(pawn, next_pawn) or map_field == "#"

        
    def dist(self, cur_x, cur_y, x, y):
        return abs(cur_x - x) + abs(cur_y - y)
    
    def can_go_to_field(self, pawn, cur_x, cur_y, x, y, player):
        next_pawn = self.get(x,y)
        map_field = self.get_map(x,y)
        dist = self.dist(cur_x, cur_y, x, y)

        if next_pawn == None:
            return False
        
        if map_field == "~" and pawn.lower() != "r":
            return False
        
        # no animal on the next field
        
        if next_pawn == ".":
            if map_field == "." or map_field == "#":
                return True
            elif map_field == "~":
                return pawn.lower() == "r"
            else:
                return not self.own_cave(x, y, player)
        
        # animal on the next field

        return self.can_beat(pawn, cur_x, cur_y, x, y, player)
        

    def pawn_map_moves(self, pawn, x, y):
        res = []

        for dx, dy in self.DIRS:
            nx = x+dx
            ny = y+dy
            
            res += [(nx, ny)]

        return res 
    
    def jumps(self, pawn, x, y, player):

        if pawn.lower() != "l" and pawn.lower() != "t":
            return []
        
        res = []
        
        for dx, dy in self.DIRS:
            nx = x+dx
            ny = y+dy
            map_field = self.get_map(nx, ny)
            next_pawn = self.get(nx,ny)

            while map_field == "~" and (next_pawn.lower() != "r"):
                nx = nx+dx
                ny = ny+dy
                map_field = self.get_map(nx, ny)
                next_pawn = self.get(nx,ny)

            if map_field == "~" and next_pawn.lower() == "r" and (not self.pawn_player(player, next_pawn)):
                continue
            
            res += [(nx, ny)]

        return res
    
    def raw_moves(self, player):
        res = []
        for x in range(self.N):
            for y in range(self.M):
                pawn = self.board[y][x]
                if self.pawn_player(player, pawn):
                    map_moves = self.pawn_map_moves(pawn, x, y)
                    jumps = self.jumps(pawn, x, y, player)

                    res += [(x, y, mx, my) for mx, my in map_moves+jumps]
        return res  

    def moves(self, player):
        res = []
        for x in range(self.N):
            for y in range(self.M):
                pawn = self.board[y][x]
                if self.pawn_player(player, pawn):
                    map_moves = self.pawn_map_moves(pawn, x, y)
                    jumps = self.jumps(pawn, x, y, player)

                    res += [(x, y, mx, my) for mx, my in map_moves+jumps if self.can_go_to_field(pawn, x, y, mx, my, player)]
        return res                 
    

    def do_move(self, move, player):

        assert player == (len(self.move_list) % 2)
        
        possible_moves = self.moves(player)
        if not possible_moves:
            if not (move is None):
                print(f"Wrong move {move}", file=sys.stderr)
                raise WrongMove
        else:
            if move not in possible_moves:
                raise WrongMove
            
        self.move_list.append(move)

        if move is None:
            return
        
        x, y, xn, yn = move

        self.board[yn][xn] = self.board[y][x]
        self.board[y][x] = "." 


    def result(self):
        for x in range(self.N):
            for y in range(self.M):
                if self.get_map(x, y) == "*" and self.get(x, y) != ".":
                    if self.pawn_player(0, self.get(x, y)):
                        return 0 
                    else:
                        return 1
                
        return None

    def terminal(self):
        for x in range(self.N):
            for y in range(self.M):
                if self.get_map(x, y) == "*" and self.get(x, y) != ".":
                    return True

    def random_move(self, player):
        ms = self.moves(player)
        if ms:
            return random.choice(ms)
        return None
    
    def print_move(self, move, player):
        if move is None:
            print("Move = None", file=sys.stderr)
            return 
        x, y, nx, ny = move
        pawn = self.get(x, y)
        print(f"Move = {pawn} goes from ({x}, {y}) to ({nx}, {ny}) [occupied by {self.get(nx, ny)}, type = {self.get_map(nx, ny)}]", file=sys.stderr)
        print(f"Player = {player}, Own cave = {self.own_cave(nx, ny, player)}", file=sys.stderr)

    def whose_pawn(self, pawn):
        if pawn.islower():
            return 0
        elif pawn.isupper():
            return 1
        else:
            return None
        
    def cave_coord(self, player):
        if player == 0:
            return (3, self.M-1)
        else:
            return (3, 0)

class Simulate:
    def __init__(self, player=0):
        self.player = player

    def result_for_player(self, board : Jungle):
        if self.player == 1:
            return board.result()
        else:
            return 1-board.result()

    def rate_board(self, board_orig : Jungle):
        # 1-self.player starts!

        cnt_moves = 0
        player = 1-self.player
        board = deepcopy(board_orig)

        while not board.terminal():
            m = board.random_move(player)
            board.do_move(m, player)
            player = 1-player
            cnt_moves += 1
        
        return self.result_for_player(board), cnt_moves
    

    def make_move(self, board : Jungle):
        moves = board.moves(self.player)
        random.shuffle(moves)

        new_boards = []
        for m in moves:
            new_board = deepcopy(board)
            new_board.do_move(m, self.player)
            new_boards += [new_board]


        total_moves = 0
        results = [0 for _ in new_boards]
        rounds = 0

        while rounds == 0 or total_moves + (total_moves/rounds) < MAX_N:
            for idx, new_board_orig in enumerate(new_boards):
                new_board = deepcopy(new_board_orig)
                res, n_moves = self.rate_board(new_board)
                total_moves += n_moves
                results[idx] += res

            rounds += 1

        print(f"TOTAL MOVES = {total_moves}", file=sys.stderr)

        assert len(results) == len(moves)

        best_move = None 
        best_res = -1

        for m, res in zip(moves, results):
            if res > best_res:
                best_res = res
                best_move = m

        return best_move
        

    
class MiniMax:
    def __init__(self, player=0):
        self.player = player

    def result_for_player(self, board : Jungle):
        if self.player == 1:
            return board.result()
        else:
            return 1-board.result()

    def pawns_heuristcs(self, board : Jungle):
        max_result = 0
        min_result = 0

        for x in range(board.N):
            for y in range(board.M):
                pawn = board.get(x, y)

                if pawn == ".":
                    continue

                strength = board.get_strength(pawn)
                player = board.whose_pawn(pawn)

                if player == self.player:
                    max_result += strength
                elif player == (1-self.player):
                    min_result += strength

        assert min_result+max_result > 0
        return 100*(max_result-min_result)/(max_result+min_result)

    def min_dist_heuristics(self, board : Jungle):
        max_result = INF
        min_result = INF 

        for x in range(board.N):
            for y in range(board.M):
                pawn = board.get(x, y)
                player = board.whose_pawn(pawn)

                if player == self.player:
                    cave_x, cave_y = board.cave_coord(1-self.player)
                    max_result = min(max_result, board.dist(x, y, cave_x, cave_y))
                elif player == (1-self.player):
                    cave_x, cave_y = board.cave_coord(self.player)
                    min_result = min(min_result, board.dist(x, y, cave_x, cave_y))

        return 100*(min_result-max_result)/(max_result+min_result)
    
    def sum_dist_heuristics(self, board : Jungle):
        max_result = 0
        min_result = 0 

        for x in range(board.N):
            for y in range(board.M):
                pawn = board.get(x, y)
                player = board.whose_pawn(pawn)

                if player == self.player:
                    # max_result += board.dist(x, y, 3, 0)
                    _, cave_y = board.cave_coord(1-self.player)
                    max_result += board.dist(x, y, x, cave_y)
                elif player == (1-self.player):
                    # min_result += board.dist(x, y, 3, board.M-1)
                    _, cave_y = board.cave_coord(self.player)
                    min_result += board.dist(x, y, x, cave_y)

        return 100*(min_result-max_result)/(max_result+min_result)
    
    def mobility_heuristics(self, board : Jungle):
        max_result = len(board.moves(self.player))
        min_result = len(board.moves(1-self.player))

        if max_result+min_result == 0:
            return 0
        else:
            return (max_result-min_result)/(max_result+min_result)

    def heuristic_value(self, board : Jungle, round):
        p = self.pawns_heuristcs(board)
        md = self.min_dist_heuristics(board)
        m = self.mobility_heuristics(board)
        sd = self.sum_dist_heuristics(board)

        return (10*p + 5000*md + 10*m + sd)


    
    def max_value(self, board : Jungle, alpha, beta, depth, round):
        if board.terminal():
            return (self.result_for_player(board)*INF, None) 
        
        if depth == DEPTH:
            return self.heuristic_value(board, round), None
        
        value = -INF
        moves = board.moves(self.player)
        new_boards = []

        for m in moves:
            new_board = deepcopy(board)
            new_board.do_move(m, self.player)
            heur = self.heuristic_value(new_board, round+1)
            new_boards += [(heur, new_board, m)]

        if depth < 3:
            new_boards = sorted(new_boards, key=lambda x : -x[0])
        else:
            pass

        best_move = None

        for (_, new_board, m) in new_boards:
            min_value = self.min_value(new_board, alpha, beta, depth+1, round)
            if min_value > value or best_move is None:
                value = min_value  
                best_move = m
            if value >= beta:
                return (value, m)
            alpha = max(alpha, value)

        return value, best_move
    

    def min_value(self, board : Jungle, alpha, beta, depth, round):
        if board.terminal():
            return self.result_for_player(board)*INF

        if depth == DEPTH:
            return self.heuristic_value(board, round)

        value = INF
        moves = board.moves(1-self.player)
        new_boards = []

        for m in moves:
            new_board = deepcopy(board)
            new_board.do_move(m, 1-self.player)
            new_boards += [(self.heuristic_value(new_board, round+1), new_board, m)]
        
        if depth < 5:
            new_boards = sorted(new_boards, key=lambda x : x[0])
        else:
            pass

        for (_, new_board, m) in new_boards:
            max_value, _ = self.max_value(new_board, alpha, beta, depth+1, round)
            value = min(value, max_value)
            if value <= alpha:
                return value
            beta = min(alpha, value)

        return value

    def max_move(self, board : Jungle, round):
        last_iter_time = 0
        start_time = time()

        for d in range(3, MAX_DEPTH):
            if time()+last_iter_time*3 - start_time > MINIMAX_TIME:
                # if d > 4:
                # print(f"DEPTH = {d}", file=sys.stderr)
                break
            else:
                global DEPTH
                DEPTH = d
                start_iter_time = time()
                _, move = self.max_value(board, -INF, INF, 0, round)
                last_iter_time = time() - start_iter_time

        return move 
    
def dueler_minimax():
    board = Jungle()
    print("RDY")
    minimax_agent = MiniMax()
    round = 0
    player = None

    while True:
        round += 1
        line = input()
        toks = line.split(" ")

        if toks[0] == "UGO":
            minimax_agent.player = 0
            player = 0

            move = minimax_agent.max_move(board, round)
            board.print_move(move, minimax_agent.player)
            board.do_move(move, minimax_agent.player)
            board.draw()

            if move is None:
                move = (-1, -1, -1, -1)

            print(f"IDO {move[0]} {move[1]} {move[2]} {move[3]}")

        elif toks[0] == "HEDID":
            if player is None:
                player = 1
                minimax_agent.player = 1
            
            move = int(toks[3]), int(toks[4]), int(toks[5]), int(toks[6])

            if move == (-1, -1, -1, -1):
                move = None

            board.print_move(move, 1-minimax_agent.player)
            board.do_move(move, 1-minimax_agent.player)
            board.draw()

            move = minimax_agent.max_move(board, round)
            board.print_move(move, minimax_agent.player)
            board.do_move(move, minimax_agent.player)
            board.draw()

            if move is None:
                move = (-1, -1, -1, -1)

            print(f"IDO {move[0]} {move[1]} {move[2]} {move[3]}")

        elif toks[0] == "ONEMORE":
            board = Jungle()
            player = None
            round = 0 
            print("RDY")
        elif toks[0] == "BYE":
            break


def dueler_simulate():
    board = Jungle()
    print("RDY")
    simulate_agent = Simulate()
    round = 0
    player = None

    while True:
        round += 1
        line = input()
        toks = line.split(" ")

        if toks[0] == "UGO":
            simulate_agent.player = 0
            player = 0

            move = simulate_agent.make_move(board)
            board.print_move(move, simulate_agent.player)
            board.do_move(move, simulate_agent.player)
            board.draw()

            if move is None:
                move = (-1, -1, -1, -1)

            print(f"IDO {move[0]} {move[1]} {move[2]} {move[3]}")

        elif toks[0] == "HEDID":
            if player is None:
                player = 1
                simulate_agent.player = 1
            
            move = int(toks[3]), int(toks[4]), int(toks[5]), int(toks[6])

            if move == (-1, -1, -1, -1):
                move = None

            board.print_move(move, 1-simulate_agent.player)
            board.do_move(move, 1-simulate_agent.player)
            board.draw()

            move = simulate_agent.make_move(board)
            board.print_move(move, simulate_agent.player)
            board.do_move(move, simulate_agent.player)
            board.draw()

            if move is None:
                move = (-1, -1, -1, -1)

            print(f"IDO {move[0]} {move[1]} {move[2]} {move[3]}")

        elif toks[0] == "ONEMORE":
            board = Jungle()
            player = None
            round = 0 
            print("RDY")
        elif toks[0] == "BYE":
            break


def dueler_random():
    board = Jungle()
    print("RDY")

    agent_player = None
    round = 0
    player = None

    while True:
        round += 1
        line = input()
        toks = line.split(" ")

        if toks[0] == "UGO":
            agent_player = 0
            player = 0

            move = board.random_move(agent_player)
            board.print_move(move, agent_player)
            board.do_move(move, agent_player)
            board.draw()

            if move is None:
                move = (-1, -1, -1, -1)

            print(f"IDO {move[0]} {move[1]} {move[2]} {move[3]}")

        elif toks[0] == "HEDID":
            if player is None:
                player = 1
                agent_player = 1
            
            move = int(toks[3]), int(toks[4]), int(toks[5]), int(toks[6])

            if move == (-1, -1, -1, -1):
                move = None

            board.print_move(move, 1-agent_player)
            board.do_move(move, 1-agent_player)
            board.draw()

            move = board.random_move(agent_player)

            board.print_move(move, agent_player)
            board.do_move(move, agent_player)
            board.draw()

            if move is None:
                move = (-1, -1, -1, -1)

            print(f"IDO {move[0]} {move[1]} {move[2]} {move[3]}")

        elif toks[0] == "ONEMORE":
            board = Jungle()
            player = None
            round = 0 
            print("RDY")
        elif toks[0] == "BYE":
            break


def local_round():
    board = Jungle()
    player = 0
    cnt = 0
    round = 0

    simulate_agent = Simulate(player=0)
    minimax_agent = MiniMax(player=1)
    simulate_time = 0
    minimax_time = 0

    while True:
        round += 1
        print(f"ROUND {round}")
        player_string = "lower" if player == 0 else "upper"
        print(f"Player {player_string}, number {player}")

        board.draw()
        # B.show()

        if player == 0:
            start_time = time()
            m = simulate_agent.make_move(board)
            simulate_time = time()-start_time

            board.print_move(m, player)
            board.do_move(m, player)
        else:
            start_time = time()
            m = minimax_agent.max_move(board, round)
            minimax_time = time() - start_time
            board.do_move(m, player)
            board.print_move(m, player)
            print(f"Time ratio = {minimax_time/simulate_time}")
        
        player = 1-player
        
        if board.terminal():
            break

    return board.result()
  
def experiment():
    wins = 0
    loses = 0

    for _ in range(10):
        res = local_round()
        if res == 1:
            wins += 1
        else:
            loses += 1

    print("--- Experiment result ---")
    print(f"Minimax won-lost : {wins} {loses}")

     

def main():
    # experiment()
    # local_round()
    # dueler_simulate()
    dueler_minimax()
            


if __name__ == "__main__":
    main()