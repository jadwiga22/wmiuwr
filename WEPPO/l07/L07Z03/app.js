var http = require("http");
var express = require("express");
var cookieParser = require("cookie-parser");
var session = require("express-session");
var FileStore = require('session-file-store')(session);

var app = express();

app.set("view engine", "ejs");
app.set("views", "./views");

var fileStoreOptions = {path : './sessions/'};

app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(
    session({
        store: new FileStore(fileStoreOptions),
        secret: "secretkey2387932879",
        saveUninitialized: true,
        cookie: { maxAge: 2000 },
        resave: false
    }));

app.get("/", (req, res) => {
    res.render("index", {name:""});

});

app.post("/", (req, res) => {
    var name = req.body.name;
    res.cookie("name", name, { maxAge: 5000 });
    res.redirect("name");
});

app.get("/name", (req, res) => {
    var name = req.cookies.name;
    res.render("name", { name: name });
});

app.post("/name", (req, res) => {
    var name = req.body.name;
    res.cookie("name", name, { maxAge: -1 });
    res.redirect("/");
});

app.get("/sess", (req, res) => {
    res.render("sess", {sessionName: ""});
})

app.post("/sess", (req, res) => {
    var sessionValue = req.session.sessionValue;
    var sessionName = req.session.sessionName;
    if ( !sessionValue ) {
        sessionValue = new Date().toString();
        req.session.sessionValue = sessionValue;
    } 
    if( !sessionName ) {
        req.session.sessionName = req.body.sessionName;
    } 
    res.redirect("/sess_value");
})

app.get("/sess_value", (req,res) => {
    var sessionValue = req.session.sessionValue;
    var sessionName = req.session.sessionName;
    res.render("sess_value", {sessionValue: sessionValue, sessionName: sessionName});
})

app.post("/sess_value", (req,res) => {
    delete req.session.sessionName;
    var sessionValue = req.session.sessionValue;
    if(!sessionValue) {
        res.redirect("/sess");
    } else {
        res.render("sess_value", {sessionValue: sessionValue, sessionName: ""});
    }
})

app.get('/view', (req,res) => {
    var numberOfViews = req.session.numberOfViews;
    if(numberOfViews) {
        numberOfViews++;
    }
    else {
        numberOfViews = 1;
    }
    req.session.numberOfViews = numberOfViews;
    res.render('view', {numberOfViews: numberOfViews});
})

http.createServer(app).listen(3000);
console.log("started");
