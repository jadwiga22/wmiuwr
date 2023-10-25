console.log("Iterator")

function fib() {
  let [cur, prev] = [1, 0];
  return {
    next: function () {
      [cur, prev] = [cur + prev, cur];
      return {
        value: cur,
        done: false,
      };
    },
  };
}

var f = fib();
for (let i = 0; i < 10; i++) {
  console.log(f.next().value);
}

// nieskończona iteracja

/*
var _it = fib();
for (var _result; (_result = _it.next()), !_result.done; ) {
  console.log(_result.value);
}
*/

// iterowanie po wartościach (wywołuje błąd)

// niemożliwe, bo fib nie zwraca czegoś iterowalnego, tylko funkcję next
/*
console.log( fib() );
for ( var i of fib() ) {
    console.log( i );
}
*/


console.log("Generator")

function *fib1() {
    let [cur, prev] = [1, 0];
    while( true ) {
        [cur, prev] = [cur + prev, cur];
        yield cur;
    }
}

var f1 = fib1();
for (let i = 0; i < 10; i++) {
  console.log(f1.next().value);
}

// nieskończona iteracja

/*
var _it = fib1();
for (var _result; (_result = _it.next()), !_result.done; ) {
  console.log(_result.value);
}
*/

// iterowanie po wartościach - jest możliwe

/*
console.log( fib1() );
for ( var i of fib1() ) {
    console.log( i );
}
*/
