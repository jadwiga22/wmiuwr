function Tree(val, left, right) {
  this.left = left;
  this.right = right;
  this.val = val;
}

// ----------------- DFS -------------------------

/*
Tree.prototype[Symbol.iterator] = function* () {
  yield this.val;
  if (this.left) yield* this.left;
  if (this.right) yield* this.right;
};
*/

// ----------------- BFS -------------------------

function AddToQueue(q, val) {
  q.splice(0, 0, val);
}

function RemoveFromQueue(q) {
  return q.splice(-1, 1)[0];
}

Tree.prototype[Symbol.iterator] = (function () {
  let a = [];
  return function* () {
    AddToQueue(a, this);
    while (a.length > 0) {
      var v = RemoveFromQueue(a);
      yield v.val;
      if (v.left) AddToQueue(a, v.left);
      if (v.right) AddToQueue(a, v.right);
    }
  };
})();

var root = new Tree(1, new Tree(2, new Tree(3)), new Tree(4));

for (var e of root) {
  console.log(e);
}

// inaczej niż w treści? ale chyba tak powinno być
// 1 2 4 3
// ze stosem zrobi się DFS


// ----------------- testy kolejki ------------------------
// let a = [ 1, 2, 3, 4];
// console.log( RemoveFromQueue( a )) ;
// console.log( a );
// AddToQueue( a, 54 );
// console.log( a );
