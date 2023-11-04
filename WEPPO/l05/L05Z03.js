function forEach(a, f) {
    for (var i = 0; i < a.length; i++) {
        f(a[i]);
    }
}
function map(a, f) {
    var res = [];
    for (var i = 0; i < a.length; i++) {
        res[i] = f(a[i]);
    }
    return res;
}
function filter(a, f) {
    var res = [];
    for (var i = 0; i < a.length; i++) {
        if (f(a[i])) {
            res[res.length] = a[i];
        }
    }
    return res;
}
var A = [1, 2, 3, 4];
forEach(A, function (_) { console.log(_); });
console.log(filter(A, function (_) { return _ < 3; }));
console.log(map(A, function (_) { return _ * 2; }));
console.log(A);
var B = ["abc", "def", "ghi", "jkl"];
forEach(B, function (_) { console.log(_); });
console.log(map(B, function (_) { return _.toUpperCase(); }));
console.log(B);
