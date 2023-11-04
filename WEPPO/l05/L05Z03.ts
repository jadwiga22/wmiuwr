function forEach<T>( a : T[], f : (x : T) => void ) : void {
    for( let i = 0; i < a.length; i++ ) {
        f( a[i] );
    }
}

function map<T,S>( a:T[], f : (x : T) => S ) : S[] {
    let res : S[] = [];
    for( let i = 0; i < a.length; i++ ) {
        res[i] = f( a[i] );
    }
    return res;
}

function filter<T>( a:T[], f : (x : T) => boolean ) : T[] {
    let res : T[] = [];
    for( let i = 0; i < a.length; i++ ) {
        if( f( a[i] ) ) {
            res[ res.length ] = a[i];
        }
    }
    return res;
}

let A : number[] = [1, 2, 3, 4]; 
forEach( A, _ => { console.log( _ ); } );
console.log( filter( A, _ => _ < 3 ) );
console.log( map( A, _ => _ * 2 ) );
console.log( map( A, _ => _.toString() ) );
console.log( A );

let B : string[] = ["abc", "def", "ghi", "jkl"]; 
forEach( B, _ => { console.log( _ ); } );
console.log( map( B, _ => _.toUpperCase() ) );
console.log( B );
