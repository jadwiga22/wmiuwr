var http = require( 'http' );
var express = require( 'express' );
var cookieParser = require( 'cookie-parser' );

var app = express();

app.set('view engine', 'ejs');
app.set('views', './views');

app.use(express.urlencoded({extended:true}));
app.use(cookieParser());

var USERS = {
    'user1': {password : 'password1', email : 'person1@example.com'},
    'user2': {password : 'password2', email : 'person2@example.com'}
};

var DATA = {
    'user1': ['1','3'],
    'user2': ['2']
};

var DOCS = {
    '1' : {name: 'Jan', surname: 'Kowalski', phone: '123 456 789'},
    '2' : {name: 'Adam', surname: 'Nowak', phone: '789 456 123'},
    '3' : {name: 'Anna', surname: 'Nowa', phone: '321 654 987'}
};

app.get('/', (req,res) => {
    res.render('index', {login: '', password: ''});
})

app.post('/', (req,res) => {
    var login = req.body.login;
    var password = req.body.password;
    
    if( !login || !password ) {
        res.render('index', {
            login: login, 
            password: password, 
            message: 'Wpisz login i hasło'
        });
    } else if ( !USERS[login] || USERS[login].password != password ) {
        res.render('index', {
            login: login, 
            password: password, 
            message: 'Niepoprawny login lub hasło'
        });
    } else {
        res.cookie('login', login);
        res.redirect('/user');
    }
})

app.get('/user', (req,res) => {
    var login = req.cookies.login;
    if( !login ) {
        res.render('unknownuser');
    } else {
        res.render( 'user', {login: login} );
    }
})

app.post('/user', (req,res) => {
    res.redirect( '/mail' );
})

app.get('/mail', (req, res) => {
    var login = req.cookies.login;
    if( !login ) {
        res.render('unknownuser');
    } else {
        var currentMail = USERS[login].email;
        res.render('mail', {mail : currentMail});
    }
})

app.post('/mail', (req, res) => {
    var newMail = req.body.mail;
    var login = req.cookies.login;
    USERS[login].email = newMail;
    res.redirect('/user');
})

app.get('/logout', (req,res) => {
    res.cookie('login', '', {maxAge: -1});
    res.redirect('/');
})

app.get('/data', (req,res) => {
    var login = req.cookies.login;
    if( !login ) {
        res.render( 'unknownuser' );
    } else {
        var dataS = DATA[login];
        res.render('data_list', {dataS: dataS});
    }
})

app.get('/data/:id', (req, res) => {
    var id = req.params.id;
    if( !DOCS[id] ) {
        res.render('not_found', {url : req.url});
    } else {
        var person = DOCS[id];
        res.render('data', person);
    }
    
});



http.createServer( app ).listen(3000);
console.log('started');