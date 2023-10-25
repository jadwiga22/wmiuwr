// czy ten sposób też jest dobry?

// function Foo( name ) {
//     this.name = name;
// }

// Foo.prototype.Bar = 
//     function () {
//         function Qux() {
//             console.log( "Hello world!" );
//         }
//         Qux();
//     }


// sposób z wykładu -------------------------

var Foo = (function () {
    function Foo(name) {
        this.name = name;
    }
    var Qux = function () {
        console.log("Hello world!");
    }
    Foo.prototype.Bar = function() {
        Qux();
    }
    return Foo;
})();

var o = new Foo( "XYZ" );
o.Bar();

// błąd
// o.Qux();
// o.Bar.Qux();
// o.Bar().Qux();