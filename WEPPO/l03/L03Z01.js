// funkcja zapamiętująca wyliczone wcześniej wartości

function memoize(fn) {
    var cache = {};

    return function(n) {
        if ( n in cache ) {
            return cache[n]
        } else {
            var result = fn(n);
            cache[n] = result;
            return result;
        }
    }
}

function fib(n) {
    if( n <= 1 ) {
        return n;
    }
    return fib( n-1 ) + fib( n-2 );
}

function FibRec(n){
    if(n < 2) return n;
    return FibRec(n-1)+FibRec(n-2);
}

function FibIter(n){
    if(n < 2) return n;
    let f1 = 0, f2 = 1;
    for(let i = 2; i <= n; i++){
        let f3 = f2;
        f2 += f1;
        f1 = f3;
    }
    return f2;
}

 var fib_m = memoize( fib );

// tutaj niestety cache dla różnych wywołań jest różny, więc oba trwają długo
// console.log(fib_m(42));
// console.log(fib_m(41));

// tutaj jest szybkie, bo teraz funkcja fib stała się swoją zmemoizowaną wersją

var fib = memoize( fib );
console.log( fib(42) );
console.log( fib(41) );
console.log( fib(1000) );

for(let i = 30; i <= 42; i++){
    console.log(i);
    
    console.time("rec");
    var a = FibRec(i);
    console.timeEnd("rec");

    console.time("iter");
    a = FibIter(i);
    console.timeEnd("iter");

    console.time("memo");
    a = fib(i);
    console.timeEnd("memo");
}