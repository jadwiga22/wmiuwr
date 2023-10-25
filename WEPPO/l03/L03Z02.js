function forEach( a, f ) {
    for( let i = 0; i < a.length; i++ ) {
        f( a[i] );
    }
}

function map( a, f ) {
    let res = [];
    for( let i = 0; i < a.length; i++ ) {
        res[i] = f( a[i] );
    }
    return res;
}

function filter( a, f ) {
    let res = [];
    for( let i = 0; i < a.length; i++ ) {
        if( f( a[i] ) ) {
            res[ res.length ] = a[i];
        }
    }
    return res;
}

let a = [1, 2, 3, 4]; 

forEach( a, _ => { console.log( _ ); } );
// [1,2,3,4]
console.log( filter( a, _ => _ < 3 ) );
// [1,2]
console.log( map( a, _ => _ * 2 ) );
// [2,4,6,8]
console.log( map( [], _ => _ * 2 ) );

console.log( a );

// czy forEach powinien móc zmieniać zawartość tablicy?

// console.log( forEach( a, _ => _ * 2 ) );
// console.log( a );