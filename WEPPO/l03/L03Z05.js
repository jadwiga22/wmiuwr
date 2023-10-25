/*
function createGenerator() {
  var _state = 0;
  return {
    next: function () {
      return {
        value: _state,
        done: _state++ >= 10,
      };
    },
  };
}
*/

// dodajemy opakowanie funkcji, bo iterator musi być funkcją bez argumentów, która...

function createGenerator(n) {
  return function () {
    var _state = 0;
    return {
      next: function () {
        return {
          value: _state,
          done: _state++ >= n,
        };
      },
    };
  };
}

console.log("Generator dla 5")
var foo = {
  [Symbol.iterator]: createGenerator(5),
};

for (var f of foo) console.log(f);

console.log("Generator dla 10")
var foo1 = {
  [Symbol.iterator]: createGenerator(10),
};

for (var f of foo1) console.log(f);

console.log("Generator dla 2")
var foo2 = {
  [Symbol.iterator]: createGenerator(2),
};

for (var f of foo2) console.log(f);
