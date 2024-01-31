# Jadwiga Swierczynska
# 16.10.2023


# calculating beginning and end of longest subsequence with maximum sum of elements

def max_sublists_sum(ls):
    # sum of current subsequence and maximum sum of subsequence
    curSum, maxSum = 0, float('-inf')

    # beginning and end of current subsequence
    curBeg, curEn = 0, -1

    # beginning and end of maximum subsequence
    maxBeg, maxEn = 0, -1

    for i,x in enumerate(ls):

        # if current sum plus current element is not less than 0
        # then we want to extend the curent subsequence
        # otherwise we change the beginning of current subsequence

        if curSum + x >=0:
            curSum += x
        else:
            curSum = x
            curBeg = i

        # moving the end of current subsequence

        curEn = i

        # updating maximum
        
        if curSum > maxSum:
            maxSum = curSum
            maxBeg, maxEn = curBeg, curEn

    return maxBeg, maxEn


def main():
    assert max_sublists_sum([1,2,3]) == (0,2)
    assert max_sublists_sum([-3, 4, -1, 2, -7, 2, -1, 5, -2, 1]) == (5,7)
    assert max_sublists_sum([]) == (0,-1)
    assert max_sublists_sum([-1]) == (0,0)
    assert max_sublists_sum([-3, -2, -1]) == (2,2)

if __name__ == '__main__':
    main()

        