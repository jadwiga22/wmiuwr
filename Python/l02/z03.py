langs = {
    'italian' : 'ita.txt' ,
    'english' : 'eng.txt',
    'polish' : 'pol.txt',
    'latin' : 'lat.txt'
}

def processFile(filename):

    cnt = 0
    dict = {}

    with open(filename) as f:
        line = f.readline()
        while line:
            for a in line:
                if a.isalpha():
                    cnt += 1
                    if a.lower() in dict:
                        dict[a.lower()] += 1
                    else:
                        dict[a.lower()] = 1
            line = f.readline()

    freqs = {}

    for a in dict:
        freqs[a] = dict[a]/cnt

    return freqs


def createFreqs():
    freqs = {}

    for l in langs:
        freqs[l] = processFile(langs[l])

    return freqs


def calcDist(occ, occLang):
    res = 0
    for a in occ:
        if a in occLang:
            res += abs(occ[a] - occLang[a])
        else:
            res += occ[a]
        
    for a in occLang:
        if a not in occ:
            res += abs(occLang[a])

    return res



def guessLang(filename, freqs):
    freq = processFile(filename)

    res = float('+inf')
    lang = 'unknown'

    for l in langs:
        curSim = calcDist(freq, freqs[l])
        if curSim < res:
            res = curSim
            lang = l

    return lang

    
def main(): 
    freqs = createFreqs()

    for l in langs:
        print(l, ", guess: ", guessLang(langs[l], freqs))

    print('polish, guess: ', guessLang('test1_pol.txt', freqs))
    print('english, guess: ', guessLang('test2_eng.txt', freqs))
    print('dutch, guess: ', guessLang('test3_dutch.txt', freqs))
    print('italian, guess: ', guessLang('test4_ita.txt', freqs))
    print('latin, guess: ', guessLang('test5_latin.txt', freqs))
    

if __name__ == "__main__":
    main()

