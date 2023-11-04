var http = require( 'http' );
var express = require( 'express' );

var app = express();

app.use( (req, res, next) => {
    res.write( '123' );
    next();
    res.write( 'BACK' );
    // res.end();
});

app.use( (req, res, next) => {
    res.write( 'HERE' );
})

http.createServer( app ).listen( 3000 );
console.log( 'started' );