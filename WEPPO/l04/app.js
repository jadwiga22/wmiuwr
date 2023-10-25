// function Clock() {
//     var now = new Date();
//     console.log( now.getHours() + " " + now.getMinutes() + " " + now.getSeconds() + " " );
// }

// setInterval(Clock, 1000);

let myPromise = new Promise( (resolve, reject) => {
    setTimeout( () => {
        resolve( "Hello" );
    }, 2000);
})

myPromise.then( (value) => {
    console.log( value );
})