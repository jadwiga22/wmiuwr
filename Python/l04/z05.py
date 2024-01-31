# Jadwiga Swierczynska
# 23.10.2023

import operator

# removing duplicate elements from list
def removeDuplicatesFromList(xs):
    return list(dict.fromkeys(xs))

# generator 
# parameters:
# xs - list of characters to be translated to digits
# i - index of currently translated character
# ns - remainging digits that can be assigned to xs[i]
# dict - current dictionary of translation (mapping character -> digit)
# a - first argument of criptarithm
# b - second argument of criptarithm
# res - result of criptarithm
# op - operator in criptarithm
def genDigits(xs, i, ns, dict, a, b, res, op):
    # checking if we finished processing every character in xs
    if i >= len(xs):
        dictASCII = {}
        for k in dict:
            dictASCII[ord(k)] = ord(str(dict[k]))

        # applying translation to arguments of criptarithm
        ax, bx, resx = int(a.translate(dictASCII)),  int(b.translate(dictASCII)), int(res.translate(dictASCII))

        # checking if the result is correct and if there are no leading zeros
        if op(ax,bx) == resx and len(str(ax)) == len(a) and len(str(bx)) == len(b) and len(str(resx)) == len(res):
            yield ax, bx, resx
    else:
        # checking every possibility of matching character xs[i] with a digit from ns
        for y in ns:
            dict[xs[i]] = y
            yield from genDigits(xs, i+1, \
                        [a for a in ns if a != y],
                        dict,
                        a, b, res, op)



def kryptarytm(a, b, res, op):
    xs = removeDuplicatesFromList(list(a) + list(b)+ list(res))
    if len(xs) > 10:
        raise Exception("Incorrect data")
    
    return genDigits(xs, 0, list(range(10)), {},  a, b, res, op)
    

def main():
    assert [k for k in kryptarytm("KIOTO", "OSAKA", "TOKIO", operator.add)] == [(41373, 32040, 73413)]
    assert [k for k in kryptarytm("SEND", "MORE", "MONEY", operator.add)] == [(9567, 1085, 10652)]
    assert [k for k in kryptarytm("A", "A", "B", operator.add)] == [(1, 1, 2), (2, 2, 4), (3, 3, 6), (4, 4, 8)]
    assert [k for k in kryptarytm("A", "A", "A", operator.add)] == [(0, 0, 0)]

    for k in kryptarytm("A", "A", "B", operator.add):
        print(k)

    for k in kryptarytm("KIOTO", "OSAKA", "TOKIO", operator.add):
        print(k)

    for k in kryptarytm("SEND", "MORE", "MONEY", operator.add):
        print(k)

    for k in kryptarytm("A", "A", "A", operator.add):
        print(k)


if __name__ == '__main__':
    main()
