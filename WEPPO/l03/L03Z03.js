//  -------------------- WERSJA Z WYKŁADU -----------------------------

console.log("Wersja z wykladu");

function createFs(n) { // tworzy tablicę n funkcji
    var fs = []; // i-ta funkcja z tablicy ma zwrócić i
    for ( var i=0; i<n; i++ ) {
        fs[i] =
            function() {
                return i;
            };
    };
    return fs;
}
var myfs = createFs(10);
console.log( myfs[0]() ); // zerowa funkcja miała zwrócić 0
console.log( myfs[2]() ); // druga miała zwrócić 2
console.log( myfs[7]() );
// 10 10 10 // ale wszystkie zwracają 10!?

// działa źle, bo var ma zasięg funkcyjny, więc w domknięciu nie ma tego, czego byśmy oczekiwali


//  -------------------- WERSJA POPRAWIONA 1 -----------------------------

console.log("\nWersja poprawiona 1");

function createFs1(n) { // tworzy tablicę n funkcji
    var fs = []; // i-ta funkcja z tablicy ma zwrócić i
    for ( let i=0; i<n; i++ ) {
        fs[i] =
            function() {
                return i;
            };
    };
    return fs;
}
var myfs1 = createFs1(10);
console.log( myfs1[0]() ); 
console.log( myfs1[2]() ); 
console.log( myfs1[7]() );

// let ma zasięg blokowy, więc w domknięciu jest to, co powinno


//  -------------------- WERSJA POPRAWIONA 2 -----------------------------

console.log("\nWersja poprawiona 2");

function createFs2(n) { // tworzy tablicę n funkcji
    var fs = []; // i-ta funkcja z tablicy ma zwrócić i
    function makeFunction(i) {
        return () => (i);
    }
    for ( var i=0; i<n; i++ ) {
        fs[i] = makeFunction(i);           
    };
    return fs;
}
var myfs2 = createFs2(10);
console.log( myfs2[0]() ); 
console.log( myfs2[2]() ); 
console.log( myfs2[7]() );

// tutaj przesyłamy do domknięcia innej funkcji


//  -------------------- WERSJA POPRAWIONA 3 -----------------------------

console.log("\nWersja poprawiona 3");

function createFs3(n) { // tworzy tablicę n funkcji
    var fs = []; // i-ta funkcja z tablicy ma zwrócić i
    for ( var i=0; i<n; i++ ) {
        (function () {
            var j = i;
            fs[j] = function () {
                return j;
            }
        })();        
    };
    return fs;
}
var myfs3 = createFs3(10);
console.log( myfs3[0]() ); 
console.log( myfs3[2]() ); 
console.log( myfs3[7]() );

// tutaj przesyłamy do domknięcia innej funkcji