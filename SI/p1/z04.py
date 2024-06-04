# Jadwiga Swierczynska
# AI, 22.02.2024

# Solution is based on the following idea:

# We think of the problem as maintaining
# two pointers marking the interval 
# of the length d that we are currently looking at.

# At the same time we maintain the numbers:
#  - ones_left = number of ones to the left of our interval
#  - ones_center = number of ones inside our interval
#  - ones_right = number of ones to the right of our interval

# Moving the pointers and changing above numbers is straightforward.
# Number of required operations for current interval
# is equal to d-ones_center + ones_left + ones_right.
# We choose minimum value. 

def opt_dist(xs, d):
    ones_left = 0
    ones_right = 0
    ones_center = 0

    for i in range(len(xs)):
        if xs[i] == "1":
            if i < d:
                ones_center +=1
            else:
                ones_right += 1

    min_ops = d-ones_center + ones_right

    for j in range(d, len(xs)):
        if xs[j-d] == "1":
            ones_left += 1
            ones_center -=1
        if xs[j] == "1":
            ones_center += 1
            ones_right -= 1
        
        min_ops = min(min_ops, d-ones_center + ones_right + ones_left)

    return min_ops

def solve():
    with open("zad4_input.txt") as file:
        with open("zad4_output.txt", "w") as file_out:
            while True:
                line = file.readline()
                if not line:
                    break
                tokens = line.split()
                file_out.write(str(opt_dist(tokens[0], int(tokens[1])))+"\n")


def main():
    solve()

if __name__ == "__main__":
    main()

