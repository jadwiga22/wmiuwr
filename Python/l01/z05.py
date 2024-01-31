# Jadwiga Swierczynska
# 11.10.2023

# returning length of longest common prefix of two strings
def length_longest_prefix(a, b):
    l = min(len(a), len(b))
    for i in range(0,l):
        if a[i] != b[i]:
            return i
    return l

# returning longest common prefix of two strings
def longest_prefix(a, b):
    return a[:length_longest_prefix(a,b)]

# returning longest common prefix of at least 3 words
# note: we can just check lcp for all sets of three words
def common_prefix(ls):
    res = 0
    pref = ""

    ls = list(map(lambda x : x.lower(), ls))

    for i in range(0, len(ls)):
        for j in range(i+1, len(ls)):
            curPref = longest_prefix(ls[i], ls[j])
            if len(curPref) <= res:
                break
            for k in range(j+1, len(ls)):
                curPrefK = longest_prefix(curPref, ls[k])
                if len(curPrefK) > res:
                    res = len(curPrefK)
                    pref = curPrefK


    return pref


def main():
    print(common_prefix(["Cyprian", "cyberotoman", "cynik", "ceniąc", "czule"]))
    print(common_prefix(["abs", "absksudhfj", "absdkf"]))
    print(common_prefix(["sduh", "sdjn"]))
    print(common_prefix(["aaaaa", "aaaaa", "aaaaa", "aaaaa", "aaaaa", "aaaaa"]))

if __name__ == '__main__':
    main()