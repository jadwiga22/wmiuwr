const book = {
    title: 'Harry Potter',
    author: 'Rowling',
    '42weird': 'Lorem ipsum', 
    2: 'two',
    '4': 'four'
}

// notacja nawiasowa:
// mo�na w trakcie programu wyliczy� nazw� w�asno�ci, np:

console.log("Pytanie 1:")

let property
if( 1 < 2 ){
    property = 'title'
} else {
    property = 'author'
}

console.log(book[property])

// nazwy w�asno�ci nie musz� by� 'valid'
console.log(book['42weird'])

// console.log(book.42weird) - b��d
// console.log(book.'42weird') - b��d

// automatyczna konwersja na string
console.log(book[2])
console.log(book["2"])

// console.log(book.2) - b��d
// console.log(book.'2') - b��d

const object = {};
// object[foo] = "foo" - b��d, foo niezdefiniowane
object.bar = "bar"

// console.log(object.foo)
console.log(object.bar)
console.log(object.aux) // wypisuje si� jako undefined

console.log(Object.keys(object))

//////////////////////////////////////////////

console.log("\nPytanie 2:")

console.log(book[1]) // undefined
console.log(book[4]) // 'four'
console.log(book['4']) // 'four'
console.log(String(4))

const movie = {}

const ob1 = {id: 1}
const ob2 = {id: 2}
const ob3 = {id1: 1}

movie[ob1] = "example"
console.log(movie[ob2])
console.log(movie[ob3])
console.log(String(ob1), String(ob2), String(ob3)) // koersja typ�w
console.log(movie)
movie['[object Object]'] = 3
console.log(movie)

//jaki wp�yw na klucz??? przy obiekcie nie ma wp�ywu, przy liczbie ma

//////////////////////////////////////////////

console.log("\nPytanie 3:")

const arr = [1, 'dog', 2, 'cat']

console.log(arr['3']) // ok bo koersja
console.log(arr['cat']) // undefined
arr['cat'] = 7
console.log(arr['cat']) 
console.log(Object.keys(arr)) // zmienia si� jako obiekt
console.log(arr)
console.log(arr.length) // nie zmienia si� jako tablica
arr[ob1] = 77
console.log(arr)
arr[ob3] = 777
console.log(arr) // znowu koersja do '[object Object]'

arr.length = 10
console.log(arr) // dopisuj� si� 3 kropki (undefined elements)
arr.length = 2
console.log(arr) // usuwaj� si� elementy
arr.length = 4
console.log(arr) // dopisa�y si� 3 kropki
console.log(arr[2]) // to jest undefined