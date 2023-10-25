module.exports = { fact_a };
var b = require('./b');

/**
 * @param {number} n number 
 * @returns {number} factorial of n
 */

function fact_a(n) {
    if(n > 0){
        var res = n*b.fact_b(n-1);
        console.log( res );
        return res;
    } else {
        return 1;
    }
}


console.log("wywołanie a");
