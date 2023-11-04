var http = require('http');
var express = require('express');
var multer  = require('multer');
var upload = multer({ dest: 'uploads/' });
var fs = require( 'fs' );

var app = express();

app.set('view engine', 'ejs');
app.set('views', './views');

app.use(express.urlencoded({extended: true}));

app.get( '/', (req,res) => {
    res.render( 'index' );
})

app.post( '/upload', upload.single('text'), (req, res) => {
   res.render('upload');
});

app.get( '/pattern', (req,res) => {
    res.render('pattern');
})


http.createServer( app ).listen( 3000 );
console.log( 'started' );