# Jadwiga Swierczynska
# AI, 21.02.2024

# Solution is based on the following idea:
# - create a set (hash table) containing all of the words 
# - for each line from input create array sums,
#   such that
#   sums[i] = best result for suffix line[i..n-1]
#       (i. e. max value of sum of squared lengths of substrings)
#   sums[i] is calculated as follows:
#       sums[i] = max (j-i)^2 + sums[j] for j > i such that line[i:j] is valid word

FILE_IN = "zad2_input.txt"
FILE_OUT = "zad2_output.txt"
DICT = "words_for_ai1.txt"


class Solution:
    def __init__(self):
        self.words = set()
        self.best_sum = 0
        self.best_word_list = []

    def prepare(self):
        cnt = 0
        with open(DICT) as file:
            while True:
                word = file.readline()
                if not word:
                    break
                self.words.add(word.replace("\n", ""))

    def solve_line(self, l):
        sums = [0] * (len(l)+1)
        nexts = [len(l)] * len(l)

        for i in range(len(l)-1,-1,-1):
            for j in range(i+1,len(l)+1):
                prefix = l[i:j]
                if prefix in self.words:
                    if sums[i] < sums[j] + (j-i)**2:
                        sums[i] = sums[j] + (j-i)**2
                        nexts[i] = j

        index = 0

        while index < len(l):
            self.best_word_list += [l[index:nexts[index]]]
            index = nexts[index]


def main():
    sol = Solution()
    sol.prepare()

    with open(FILE_IN) as file:
        with open(FILE_OUT, "w") as file_out:
            while True:
                line = file.readline()
                
                if not line:
                    break
                line = line.replace("\n", "")
                if line == "":
                    continue

                sol.best_sum = 0
                sol.best_word_list = []
                sol.solve_line(line)
                file_out.write(" ".join(sol.best_word_list)+"\n")

    

if __name__ == "__main__":
    main()