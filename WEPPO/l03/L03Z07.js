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

function* fib1() {
  let [cur, prev] = [1, 0];
  while (true) {
    [cur, prev] = [cur + prev, cur];
    yield cur;
  }
}

function* take(it, top) {
  for (let i = 0; i < top; i++) {
    yield(it.next().value);
  }
}
// zwróć dokładnie 10 wartości z potencjalnie
// "nieskończonego" iteratora/generatora

console.log("Iterator")
for (let num of take(fib(), 10)) {
  console.log(num);
}

console.log("\nGenerator")
for (let num of take(fib1(), 10)) {
  console.log(num);
}
