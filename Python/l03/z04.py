# Jadwiga Swierczynska
# 16.10.2023

JEDNOSCI = {
    "zero" : 0,
    "jeden" : 1,
    "dwa" : 2,
    "trzy" : 3,
    "cztery" : 4,
    "pięć" : 5,
    "sześć" : 6,
    "siedem" : 7,
    "osiem" : 8,
    "dziewięć" : 9
}

NASCIE = {
    "jedenaście" : 11,
    "dwanaście" : 12,
    "trzynaście" : 13,
    "czternaście" : 14,
    "piętnaście" : 15,
    "szesnaście" : 16,
    "siedemnaście" : 17,
    "osiemnaście" : 18,
    "dziewiętnaście" : 19,
}

DZIESIATKI = {
    "dziesięć" : 10,
    "dwadzieścia" : 20,
    "trzydzieści" : 30,
    "czterdzieści" : 40,
    "pięćdziesiąt" : 50, 
    "sześćdziesiąt" : 60,
    "siedemdziesiąt" : 70,
    "osiemdziesiąt" : 80,
    "dziewięćdziesiąt" : 90
}

SETKI = {
    "sto" : 100,
    "dwieście" : 200,
    "trzysta" : 300,
    "czterysta" : 400,
    "pięćset" : 500,
    "sześćset" : 600,
    "siedemset" : 700,
    "osiemset" : 800,
    "dziewięćset" : 900,
}

DICT = JEDNOSCI | NASCIE | DZIESIATKI | SETKI

def stringToNumber(s):
    ls = s.split(" ")
    sum = 0

    for x in ls:
        if x == "tysiąc":
            sum += 1000
        elif x == "tysiące" or x == "tysięcy":
            sum *= 1000
        elif x in DICT:
            sum += DICT[x]
        else:
            raise Exception("Nieznana liczba")
        
    return sum
    
def sortListOfNumbers(ls):
    return sorted(ls, key=stringToNumber)

def main():
    assert sortListOfNumbers(['sto dwadzieścia trzy', 'osiemset piętnaście',\
'trzydzieści tysięcy dwieście']) == ['sto dwadzieścia trzy', 'osiemset piętnaście',\
'trzydzieści tysięcy dwieście']
    
    assert sortListOfNumbers(['trzydzieści tysięcy dwieście', 'osiemset piętnaście', 'sto dwadzieścia trzy']) \
    == ['sto dwadzieścia trzy', 'osiemset piętnaście', 'trzydzieści tysięcy dwieście']
    
    assert sortListOfNumbers([]) == []

    assert sortListOfNumbers(['tysiąc', 'sto', 'jeden', 'sto tysięcy sześć', 'czternaście tysięcy', 'zero']) \
    == ['zero', 'jeden', 'sto', 'tysiąc', 'czternaście tysięcy', 'sto tysięcy sześć']

    assert stringToNumber('sto pięćdziesiąt cztery tysiące sto jeden') == 154101

    assert stringToNumber('tysiąc pięćset osiem') == 1508

    assert stringToNumber('dwadzieścia cztery tysiące piętnaście') == 24015
    

if __name__ == '__main__':
    main()