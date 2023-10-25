// const, let, var ...?

function GetDigit(n){
    return n%10;
}

function GoodNumber(n){
    let res = 0, copy = n;
    while(n > 0){
        const d = GetDigit(n);
        res += d;
        if(d==0 || (copy%d)!=0){
            return false;
        }
        n = Math.floor(n/10);        
    }
    return ((copy%res)==0);
}

for (let i = 1; i <= 100000; i++){
    if(GoodNumber(i)){
        console.log(i);
    }
}