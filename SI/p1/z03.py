# Jadwiga Swierczynska
# AI, 28.02.2024

# Solution is based on the following idea:
# Firstly we implement Poker logic.
# Then, to calculate the probability of winning for player B:
# we take many samples of size 5 from the decks of the players
# and for each sample we check if B wins.

# To find optimal decks:
# We take samples from the starting decks
# which become the new decks ->  
# and for them we find the probability as explained above

import itertools
from random import sample
import threading
import logging

COLORS = range(4)
TF = list(itertools.product(range(11,15), COLORS))
TB = list(itertools.product(range(2,11), COLORS))

# Poker logic

def poker(cards):
    for i in range(1, len(cards)):
        if cards[i][1] != cards[i-1][1] or cards[i][0] != cards[i-1][0]+1:
            return False
        
    return True

def kareta(cards):
    i = 0
    if cards[0][0] != cards[1][0]:
        i = 1

    for j in range(i, i+4):
        if cards[j][0] != cards[i][0]:
            return False
        
    return True

def full(cards):
    return (cards[0][0] == cards[1][0] and cards[2][0] == cards[3][0] and cards[3][0] == cards[4][0])\
        or (cards[0][0] == cards[1][0] and cards[1][0] == cards[2][0] and cards[3][0] == cards[4][0])


def kolor(cards):
    for i in range(1, len(cards)):
        if cards[i][1] != cards[i-1][1]:
            return False
        
    return True

def strit(cards):
    for i in range(1, len(cards)):
        if cards[i][0] != cards[i-1][0]+1:
            return False
        
    return True

def three(cards):
    for i in range(0,3):
        ok = True
        for j in range(i+1, i+3):
            if cards[j][0] != cards[i][0]:
                ok = False
                break
        if ok:
            return True
        
    return False

def twopairs(cards):
    for i in range(1,3):
        if cards[i][0] == cards[i-1][0]:
            for j in range(i+2, len(cards)):
                if cards[j][0] == cards[j-1][0]:
                    return True
                
    return False

sets = [poker, kareta, full, kolor, strit, three, twopairs]

# Calculating rank of the cards
def rank(cards):
    for i in range(len(sets)):
        if sets[i](cards):
            return i
        
    if cards[0][0] > 10:
        return len(sets)
    return len(sets)+1
    
# Returning True if b wins and False otherwise
def b_wins(cards_b, cards_f):
    cards_b.sort()
    cards_f.sort()

    b_rank = rank(cards_b)
    f_rank = rank(cards_f)

    return b_rank < f_rank
    
# Calculating the probability of winning with given decks
# (taking n random games)
def probability_b_wins(tf, tb, n):
    cnt = 0

    for i in range(n):
        cards_b = sample(tb, 5)
        cards_f = sample(tf, 5)
        cards_b.sort()
        cards_f.sort()

        if b_wins(cards_b=cards_b, cards_f=cards_f):
            cnt += 1

    return cnt/n

# Pretty printing the tests
def test(tb, tf, N, number):
    print("Test ", number)
    # print(tf)
    # print(tb)
    print("Size", len(tb))
    print(probability_b_wins(tf, tb, N))
    print("--------")



# Calculating probability of winning
# For each size s of deck:
# - we take num samples of size s from the starting deck
# - and for probes times we check whether b wins or not
def check_deck(num, probes):

    for s in range(11, 10, -1):
        best = 0
        for p in range(num):
            tb = sample(TB, s)
            cur = probability_b_wins(TF, tb, probes)
            if cur > 1/2:
                print("Found! Size", s)
                print(tb)
            
            best = max(best, cur)

        print("Size: ", s, "best result: ", best)

# Dictionary for the results from threads
results = {}

# Calculating probability of winning for size of deck = s_deck
# - we take num samples of size s from the starting deck
# - and for probes times we check whether b wins or not
# Returning the deck of size s_deck for which we have 
# probability of winning > 1/2
def check_one_deck(s_deck, num, probes):
    for p in range(num):
        tb = sample(TB, s_deck)
        cur = probability_b_wins(TF, tb, probes)
        if cur > 1/2:
            results[s_deck] = tb
            return tb
        
    results[s_deck] = "Not found!"
    return []
                
# Same as check_deck but using multithreading
def check_deck_async(num, probes):
    # format = "%(asctime)s: %(message)s"
    # logging.basicConfig(format=format, level=logging.INFO,
    #                     datefmt="%H:%M:%S")
    
    ths = [threading.Thread(target=check_one_deck, args=(i, num, probes)) for i in range(11, 12)]

    [ th.start() for th in ths ]
    [ th.join() for th in ths]

    # for idx, th in enumerate(ths):
    #     logging.info("Main    : before starting thread %d.", idx)
    #     th.start()

    # for idx, th in enumerate(ths):
    #     logging.info("Main    : before joining thread %d.", idx)
    #     th.join()
    #     logging.info("Main    : thread %d done", idx)
    
    max_i = 11
    for i, item in results.items():
        if i > max_i and item != "Not found!":
            max_i = i

    print(max_i, ": ", results[max_i])


def simple_tests():
    tb = TB
    tf = TF
    N = 100000

    test(tb, tf, N, 0)

    tb = list(itertools.product(range(2,10), COLORS))
    test(tb, tf, N, 1)

    tb = list(itertools.product(range(3,11), COLORS))
    test(tb, tf, N, "1b")

    tb = list(itertools.product(range(2,9), COLORS))
    test(tb, tf, N, 2)

    tb = list(itertools.product(range(3,9), COLORS))
    test(tb, tf, N, 3)

    tb = list(itertools.product(range(2,11), range(3)))
    test(tb, tf, N, 4)

    tb = list(itertools.product(range(3,9), COLORS)) + list(itertools.product([2,9,10], range(3)))
    test(tb, tf, N, 5)

    tb = list(itertools.product(range(5,8), COLORS)) + list(itertools.product([2,10], range(1))) \
        + list(itertools.product([3,9], range(2))) + list(itertools.product([4,8], range(3)))
    test(tb, tf, N, 6)

    tb = list(itertools.product(range(5,10), [1])) 
    test(tb, tf, N, 7)

    tb = [(8, 3), (8, 1), (8, 0), (3, 3), (7, 3), (2, 3), (8, 2), (7, 2)]
    test(tb, tf, N, 8)

    tb = [(4, 0), (10, 1), (6, 2), (6, 0), (4, 2), (6, 1), (4, 3)]
    test(tb, tf, N, 9)

    tb = [(3, 3), (6, 3), (8, 1), (3, 1), (5, 2), (6, 0), (3, 0), (6, 1), (3, 2)]
    test(tb, tf, N, 10)

    tb = [(2, 0), (2, 3), (4, 1), (2, 2), (6, 0), (4, 3), (2, 1)]
    test(tb, tf, N, 11)

    tb = [(7, 1), (3, 2), (7, 0), (3, 3), (9, 2), (7, 2), (6, 0), (3, 0), (3, 1)]
    test(tb, tf, N, 12)

    tb = [(5, 3), (5, 0), (2, 2), (8, 2), (2, 3), (2, 1), (8, 0), (8, 3)]
    test(tb, tf, N, 13)

    tb = [(2, 1), (10, 3), (4, 0), (10, 0), (4, 1), (10, 1), (4, 2), (2, 3), (2, 2)]
    test(tb, tf, N, 14)

    tb = [(5, 0), (5, 3), (6, 0), (5, 1), (6, 1), (6, 2), (7, 0), (6, 3), (9, 1), (5, 2)]
    test(tb, tf, N, 15)




def main():
    # check_deck(10, 100000)
    # for i in range(10):
    #     print(f"Program run: {i}")
        # check_deck_async(1000, 1000)
        # print(check_one_deck(11, 1000, 1000))
        # check_deck(1000, 1000)
    simple_tests()


if __name__ == "__main__":
    main()