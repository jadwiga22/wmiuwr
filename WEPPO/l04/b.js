module.exports = { fact_b };
var a = require('./a');

/**
 * @param {number} n number
 * @returns {number} factorial of n
 */

function fact_b(n) {
    if(n > 0){
        var res = n*a.fact_a(n-1);
        console.log( res );
        return res;
    } else{
        return 1;
    }
}


console.log("wywołanie b");