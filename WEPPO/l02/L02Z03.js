console.log( (![]+[])[+[]]+(![]+[])[+!+[]]+([![]]+[][[]])[+!+[]+[+[]]]+(![]+[])[!+[]+!+[]] );


console.log("\nPierwsza grupa")
console.log( (![] + [])[+[]] )
console.log( ![] ) // pusta tablica -> true
console.log( ( ![] + [] ) ) // false + Obj (konw. do string)
// poniewa¿ prawe siê wylicza do stringa, to + jest konkatenacj¹
console.log( +[] ) //konwersja tablicy do liczby -> 0
//czyli mamy "false"[0] -> "f"

console.log("\nDruga grupa")
console.log( ( ![] + [] )[+ !+[]] )
console.log( ![] + [] ) // analogicznie jw. -> 'false'
console.log( +[] ) //0
console.log( !+[] ) // true, bo !0 = true
console.log( + !+[] ) // true na number -> 1
// czyli "false"[1] -> "a"

console.log("\nTrzecia grupa")
console.log( ( [![]] + [][[]] )[ +!+[] + [+[]] ] )

console.log( [ ![] ] ) // tablica [false]
console.log( [][ [] ] ) // pusta tab[0] -> undefined
console.log( [ ![] ] + [][ [] ] ) // konw. do stringów -> falseundefined
console.log(typeof([![]]+[][[]]))
console.log( +!+[] + [+[]] )
console.log( + !+[] ) // true -> number (czyli 1)
console.log( [+[]] ) // tablica [0]
console.log( +!+[] + [+[]] ) // 1 + [0] -> "1" + "0" = "10"
//czyli "falseundefined"["10"] -> "falseundefined"[10] = "i"

console.log("\nCzwarta grupa")
console.log( ( ![] + [] )[ !+[] + !+[] ] )
console.log( ![] + [] ) // false + [] -> "false"
console.log( !+[] ) // true
console.log( !+[] + !+[] ) // true + true -> 1 + 1 = 2
// czyli "false"[2] -> "l"
