function FibRec(n){
    if(n < 2) return n;
    return FibRec(n-1)+FibRec(n-2);
}

function FibIter(n){
    if(n < 2) return n;
    let f1 = 0, f2 = 1;
    for(let i = 2; i <= n; i++){
        let f3 = f2;
        f2 += f1;
        f1 = f3;
    }
    return f2;
}


for(let i = 10; i <= 44; i++){
    console.log(i);
    
    console.time("rec");
    var a = FibRec(i);
    console.timeEnd("rec");

    console.time("iter");
    a = FibIter(i);
    console.timeEnd("iter");
}