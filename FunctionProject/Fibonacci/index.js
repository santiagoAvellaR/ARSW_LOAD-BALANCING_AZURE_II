var bigInt = require("big-integer");

// Memoization cache (persiste mientras la función esté viva)
const fibCache = {
    0: bigInt.zero,
    1: bigInt.one
};

function fibonacciMemo(n) {
    if (fibCache[n] !== undefined) {
        return fibCache[n];
    }
    // Recursivo con memorización
    fibCache[n] = fibonacciMemo(n - 1).add(fibonacciMemo(n - 2));
    return fibCache[n];
}

module.exports = async function (context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    let nth = req.body.nth;
    let answer;

    if (nth < 0)
        throw 'must be greater than 0';
    else
        answer = fibonacciMemo(nth);

    context.res = {
        body: answer.toString()
    };
}