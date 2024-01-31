# Jadwiga Swierczynska
# 04.12.2023

import matplotlib.pyplot as plt
import matplotlib.animation as animation
import numpy as np
import matplotlib.patches as mpatches

# length and width of board
SIZE = 10
# size of square on board
SQUARE_SIZE = 100
# color of dead cell (red)
DEAD_COLOR = [0.839, 0.259, 0.071]
# color of alive cell (red)
ALIVE_COLOR = [0.29, 0.839, 0.067]
# representation of being alive
ALIVE_STATE = True
# representation of being dead
DEAD_STATE = False

# checking if the cell is alive or not 
# (returns True if out of range)
def is_dead(arr, i, j):
    n, m = arr.shape
    if i < 0 or j < 0 or i >= n or j >= m:
        return True
    return arr[i,j] == DEAD_STATE

# returns number of alive neighbours
def alive_neighs(arr, i, j):
    cnt = 0

    for di in range(i-1, i+2):
        for dj in range(j-1, j+2):
            if di == i and dj == j:
                continue
            if not is_dead(arr, di, dj):
                cnt += 1

    return cnt

# rules of the game 
def new_state(arr, i, j):
    alives = alive_neighs(arr, i, j)
    if is_dead(arr, i, j) and alives == 3:
        return ALIVE_STATE
    if (not is_dead(arr, i, j)) and (alives <= 1 or alives > 3):
        return DEAD_STATE
    return arr[i,j]

# updating whole board
def update_board(arr):
    n, m = arr.shape
    res = arr
    for i in range(n):
        for j in range(m):
            res[i,j] = new_state(arr,i,j)

    return res

# initialize board - random states
def initialize():
    board = np.zeros((SIZE, SIZE))
    for i in range(board.shape[0]):
        for j in range(board.shape[1]):
            board[i,j] = bool(np.random.randint(2))
    return board

# returning color in RGB
def get_color(board, i, j):
    if is_dead(board, i, j):
        # red
        return DEAD_COLOR
    else:
        # green
        return ALIVE_COLOR

# changing board to a picture
def get_picture_board(board):
    image = np.zeros((SIZE * SQUARE_SIZE, SIZE * SQUARE_SIZE, 3))
    for i in range(image.shape[0]):
        for j in range(image.shape[1]):
            board_i, board_j = i // SQUARE_SIZE, j // SQUARE_SIZE
            image[i,j,:] = get_color(board, board_i, board_j)
    return image

# ----------- animation --------------
board_global = initialize()

def init():
    global board_global
    return plt.imshow(get_picture_board(board_global)),

def animate(i):
    global board_global
    board_global = update_board(board_global)
    return plt.imshow(get_picture_board(board_global)),

def main():
    fig = plt.figure()
    ani = animation.FuncAnimation(fig, func=animate, init_func=init, frames=5000, interval=50)

    plt.axis("off")
    plt.title("Conway's Game of Life")
    red_patch = mpatches.Patch(color=DEAD_COLOR, label='Dead')
    green_patch = mpatches.Patch(color=ALIVE_COLOR, label='Alive')
    plt.legend(handles=[red_patch, green_patch],loc='center left', bbox_to_anchor=(1, 0.5))
    plt.show()

if __name__ == "__main__":
    main()