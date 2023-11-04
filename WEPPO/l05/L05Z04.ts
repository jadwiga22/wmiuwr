// importujemy zgodnie z nazwami, jakie są w pliku
import {Person, Worker} from "./L05Z04mod"

// importujemy jeden obiekt 
import func from "./L05Z04mod2";

// można też tak
import  Add from "./L05Z04mod2";
import  Fib from "./L05Z04mod2";
import { Sub } from "./L05Z04mod2";



// ale tak nie działa ???
// import { Add } from  "./L05Z04mod2";
// import Sub from "./L05Z04mod2";


var p : Person = {
    name : 'Jan', 
    surname : 'Kowalski', 
    age : 22
};

console.log( p );

var p2 : Worker = {
    name : 'Jan', 
    surname : 'Kowalski', 
    age : 22,
    job : 'Programmer'
};

console.log( p2 );

let a : number = 5;
let b : number = 3;

console.log( func.Add( a, b ) );
console.log( func.Fib(10) );
// console.log( func.Sub( a, b ) ); 
// nie ma czegoś takiego! wyeksportował się jeden obiekt

console.log( Sub(a,b) );
// ale tak można, bo wyeksportowaliśmy to osobno

console.log( Object.keys( func ) );
