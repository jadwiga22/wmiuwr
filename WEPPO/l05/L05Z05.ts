type User = {
    name: string;
    age: number;
    occupation: string;
}

type Admin = {
    name: string;
    age: number;
    role: string;
}
    
export type Person = User | Admin;
    
export const persons: Person[] = [
    {
        name: 'Jan Kowalski',
        age: 17,
        occupation: 'Student'
    },

    {
        name: 'Tomasz Malinowski',
        age: 20,
        role: 'Administrator'
    }
];


// // można dodać funkcję type-guard
// function isAdmin( p : Person ) : p is Admin {
//     return 'role' in p;
// }

// wcześniej nie działało, bo person.role może być  === null
   
function logPerson(person: Person) {
    let additionalInformation: string;
    if ( 'role' in person ) {
        additionalInformation = person.role;
    } else {
        additionalInformation = person.occupation;
    }
    console.log(`- ${person.name}, ${person.age}, ${additionalInformation}`);
}

for( let i = 0; i < 2; i++ ) {
    logPerson( persons[i] );
}