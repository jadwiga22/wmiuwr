# Jadwiga Swierczynska
# AI, 22.02.2024

# Solution is based on the following idea:

# We think of the game as a graph, where each state
# is a vertex. Edge from state a to b exists 
# if player, whose turn it is, can perform a move
# which changes state a to state b. 

# Of course we have to check if the states
# are valid (for example if there are two pieces on the same
# spot).

# In such defined graph, the problem is reduced
# to a BFS. 

# The debug mode can be turned on by changing
# the value of DEBUG to 1.

from collections import deque   

# Note: 
# 0 - white player
# 1 - black player
    
KING_MOVES = [(-1, -1), (-1, 0), (-1, 1), (0, -1), (0, 1), (1, -1), (1, 0), (1, 1)]
BOARD_SIZE = 8
DEBUG = 0

class Solution:
    def __init__(self):
        self.distance = {}

        if DEBUG == 1:
            self.prev = {}

    # prints the board
    def print_board(self, player, white_king, white_rook, black_king):
        print(f"Player's {player} move")
        print(f"Distance {self.distance[(player,white_king,white_rook,black_king)]}")
        for i in range(BOARD_SIZE):
            row = ""
            for j in range(BOARD_SIZE):
                if (i,j) == white_king:
                    row += "W"
                elif (i,j) == white_rook:
                    row += "R"
                elif (i,j) == black_king:
                    row += "B"
                else:
                    row += "."
            print(row)

        print("\n")

    # returns true if the black king is checked
    def black_check(self, player, white_king, white_rook, black_king):
        if max(abs(white_king[0]-black_king[0]), abs(white_king[1]-black_king[1])) <= 1:
            return True
        if black_king[0] == white_rook[0] or black_king[1] == white_rook[1]:
            return True
        return False
    
    # returns true if the white king is checked
    def white_check(self, player, white_king, white_rook, black_king):
        if max(abs(white_king[0]-black_king[0]), abs(white_king[1]-black_king[1])) <= 1:
            return True
        return False
    
    # returns true if the positions of the pieces are valid
    def is_valid_pos(self, player, white_king, white_rook, black_king):
        pieces = [white_king, white_rook, black_king]

        # out of bounds
        for p in pieces:
            if p[0] < 0 or p[0] >= 8 or p[1] < 0 or p[1] >= 8:
                return False
            
        # white rook can be captured by black king
        if abs(black_king[0]-white_rook[0])+abs(black_king[1]-white_rook[1]) == 1\
        and max(abs(white_king[0]-white_rook[0]), abs(white_king[1]-white_rook[1])) > 1:
            return False
            
        # collision of positions
        if pieces[0] == pieces[1] or pieces[0] == pieces[2] or pieces[1] == pieces[2]:
            return False
        
        # stepped into check
        if (player == 1 and self.white_check(player, white_king, white_rook, black_king))\
            or (player == 0 and self.black_check(player, white_king, white_rook, black_king)):
            return False
        
        return True

    # returns set of all valid moves available
    # (but they may have been visited already)
    def moves(self, player, white_king, white_rook, black_king):
        res = []
        if player == 1:
            res = [(1-player, white_king, white_rook, (black_king[0]+di, black_king[1]+dj)) \
                    for (di,dj) in KING_MOVES]
        if player == 0:
            res = [(1-player, (white_king[0]+di, white_king[1]+dj), white_rook, black_king) \
                    for (di,dj) in KING_MOVES] +\
                    [(1-player, white_king, (i, white_rook[1]), black_king) \
                    for i in range(8) if i != white_rook[0]] +\
                    [(1-player, white_king, (white_rook[0], i), black_king) \
                    for i in range(8) if i != white_rook[1]]
            

        return [m for m in res if self.is_valid_pos(*m)]
            
    # returns true if the black king is checkmated
    # i.e. it is checked and in any available move 
    # it is checked as well (therefore there are no available moves)
    def mate(self, player, white_king, white_rook, black_king):
        if self.black_check(player, white_king, white_rook, black_king):
            for m in self.moves(player, white_king, white_rook, black_king):
                if not self.black_check(*m):
                    return False
            
            return True
        return False
    
    # prints the play
    # (triggered only in debug mode)
    def print_play(self, start, finish):
        if start == finish:
            self.print_board(*start)
            return
        self.print_play(start, self.prev[finish])
        self.print_board(*finish)

    # simple BFS for available moves
    # returns smallest distance to mate
    # or "INF" if it is impossible to reach mate 
    def BFS(self, player, white_king, white_rook, black_king):        
        queue = deque([(player, white_king, white_rook, black_king)])
        self.distance[(player, white_king, white_rook, black_king)] = 0

        while queue:
            best = queue.popleft()

            if self.mate(*best):
                if DEBUG == 1:
                    self.print_play((player, white_king, white_rook, black_king), best)
                return self.distance[best]
            
            for m in self.moves(*best):
                
                if not (m in self.distance):
                    queue.append(m)
                    self.distance[m] = self.distance[best]+1

                    if DEBUG == 1:
                        self.prev[m] = best

            
        return "INF"

    # parsing the input
    def parse_position(self, pos):
        return int(pos[1])-1, ord(pos[0])-ord("a")

    def solve(self):
        with open("zad1_input.txt") as file:
            with open("zad1_output.txt", "w") as file_out:
                while True:
                    line = file.readline()
                    if not line:
                        break
                    tokens = line.split()
                    player = 0 if tokens[0] == "white" else 1
                    file_out.write(str(self.BFS(player, self.parse_position(tokens[1]), \
                                                self.parse_position(tokens[2]),\
                                                self.parse_position(tokens[3])))+"\n")


def main():
    sol = Solution()
    sol.solve()

if __name__ == "__main__":
    main()