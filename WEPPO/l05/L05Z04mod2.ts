function Fib( n : number ) : number {
    if( n < 2 ) {
        return n;
    } else {
        return Fib( n-1 ) + Fib( n-2 );
    }
}

function Add( a : number, b : number) : number {
    return a+b;
}

export function Sub( a : number, b : number) : number {
    return a-b;
}

export default { Add, Fib };