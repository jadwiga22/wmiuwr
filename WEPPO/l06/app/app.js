// zadanie 3

var http = require( 'http' );
var express = require( 'express' );

var app = express();

app.set('view engine', 'ejs');
app.set('views', './views');

app.use(express.urlencoded({extended:true}));

app.get('/', (req, res) => {
    res.render('index');
});
   

app.get('/print', (req, res) => {
    res.render('print');
});

app.get('/code', (req, res) => {
    res.render('code');
});

app.get('/download', (req,res) => {
    res.header( 'Content-disposition', 'attachment; filename="plik.txt"');
    res.end('Hello world from file!');
})

app.get('/login', (req, res) => {
    res.render('login', {username: ''});
});

app.post('/login', (req, res) => {
    var username = req.body.username;
    if( username && username.length > 5 ) {
        res.redirect( 'userinfo?username='+username );
    } else {
        res.render('login', {
            username: username,
            message: 'Nazwa użytkownika musi być dłuższa niż 5 znaków'
        });
    }
})

app.get('/userinfo', (req, res) => {
    var username = req.query.username;
    res.render('userinfo', {username});
});

app.use( (req, res) => {
    var przelewy = [
        { kwota : 123, data : '2016-01-03', id : 1 },
        { kwota : 124, data : '2016-01-02', id : 2 },
        { kwota : 125, data : '2016-01-01', id : 3 },
    ];
    res.render('table', {przelewy: przelewy});
})

http.createServer( app ).listen( 3000 );
console.log( 'started' );