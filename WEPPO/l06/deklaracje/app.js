var http = require('http');
var express = require('express');
var cookieParser = require('cookie-parser')

var app = express();

app.set('view engine', 'ejs');
app.set('views', './views');

app.use(express.urlencoded({extended: true}));
app.use(cookieParser());
app.use( express.static( "./static" ) );

app.get('/', (req, res) => {
    res.render('index', {name: '', surname: '', subject: '', task: []});
});

app.post('/', (req, res) => {
    var {name, surname, subject, task} = req.body;
    if( !name || !surname || !subject ) {
        res.render( 'index', {
            name: name,
            surname: surname,
            subject: subject,
            task: task,
            message: 'Uzupełnij imię, nazwisko i nazwę przedmiotu'
        });
    }
    else {
        res.cookie( "name", name );
        res.cookie( "surname", surname );
        res.cookie( "subject", subject );
        res.cookie( "task", task );
        res.redirect( 'print?name='+name+'&surname='+surname+'&subject='+subject+'&task='+task );
    }
});

app.get('/print', (req, res) => {
    var { name, surname, subject, task } = req.cookies;
    res.render( 'print', {name: name, surname: surname, subject: subject, task: task});
});

http.createServer( app ).listen( 8000 );
console.log( 'started' );