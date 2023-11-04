// funkcja zapamiętująca wyliczone wcześniej wartości

// ta funkcja jest dobra dla wszystkich rekurencyjnych funkcji typu number => number
function memoize(fn : Function) : Function {
    var cache : Array<number> = [];

    return function(n : number) : number {
        if ( n in cache ) {
            return cache[n]
        } else {
            var result : number = fn(n);
            cache[n] = result;
            return result;
        }
    }
}

function fib(n : number) : number {
    if( n <= 1 ) {
        return n;
    }
    return fib( n-1 ) + fib( n-2 );
}

var fib_m : Function = memoize( fib );

console.log( fib(10) );
console.log( fib_m(20) );