var fs = require('fs');
var util = require('util');

fs.readFile( 'data.txt', 'utf-8', (err, data) => {
    console.log( "BASIC ", data );
})

function MyReadFile1( name, encoding ) {
    return new Promise( ( res, rej ) => {
        fs.readFile( name, encoding, (err, data) => {
            if( err ) {
                rej( err );
            }
            res( data );
        })
    })
}

var MyReadFile2 = function( data, encoding ) {
    var PromisedReadfile = util.promisify( fs.readFile );
    return PromisedReadfile( data, encoding );
}

var MyReadFile3 = function( data, encoding ) {
    return fs.promises.readFile( data, encoding );
}


var MyPromise1 = MyReadFile1( 'data.txt', 'utf-8' )
    .then( data => {
        console.log( "1 PROMISE ", data );
    })
    .catch( err => {
        console.log( `error: ${err}` );
    });

var MyPromise2 = MyReadFile2( 'data.txt', 'utf-8' )
    .then( res => {
        console.log( "1 UTIL.PROMISIFY ", res );
    })
    .catch( err => {
        console.log( `error: ${err}` );
    });

var MyPromise3 = MyReadFile3( 'data.txt', 'utf-8' )
    .then( (data) => {
        console.log("1 FS.PROMISES ", data);
    })
    .catch( (err) => {
        console.log( `error: ${err}` );
    });


(async function() {
    var Await1 = await MyReadFile1( 'data.txt', 'utf-8' );
    var Await2 = await MyReadFile2( 'data.txt', 'utf-8' );
    var Await3 = await MyReadFile3( 'data.txt', 'utf-8' );

    console.log( "2 PROMISE ", Await1 );
    console.log( "2 UTIL.PROMISIFY ", Await2 );
    console.log( "2 FS.PROMISES ", Await3 );
})();