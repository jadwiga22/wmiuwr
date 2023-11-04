var http = require( 'http' );
var express = require( 'express' );
var cookieParser = require( 'cookie-parser' );

var app = express();

app.set('view engine', 'ejs');
app.set('views', './views');

app.use(express.urlencoded({extended:true}));
app.use(cookieParser());

app.get('/', (req,res) => {
    res.render('index');
})

app.get('/evil', (req,res) => {
    res.render('evil');
})

app.get('/evil_lost', (req,res) => {
    res.render('evil_lost');
})


http.createServer( app ).listen(8000);
console.log('started');