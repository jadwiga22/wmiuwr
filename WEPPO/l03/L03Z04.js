// 3 kropki zbierają wszystkie parametry w tablicę -> rest parameters

function sum(...tab) {
    let res = 0;
    for( let i = 0; i < tab.length; i++) {
        res += tab[i];
    }
    return res;
}

console.log("Wersja 1:")
console.log(sum());
console.log(sum(1,2,3,4));
console.log(sum(7));

var a = [-7, 10, 5];
// tutaj 3 kropki rozwijają tablicę w listę -> spread operator
console.log(sum(...a));


// można też z użyciem arguments

function sum2() {
    let res = 0;
    for( let i = 0; i < arguments.length; i++) {
        res += arguments[i];
    }
    return res;
}

console.log("\nWersja 2:")
console.log(sum2());
console.log(sum2(1,2,3,4));
console.log(sum2(7));
console.log(sum2(...a));