"use strict";
exports.__esModule = true;
exports.logPerson = exports.isUser = exports.isAdmin = exports.persons = void 0;
exports.persons = [
    {
        type: 'user',
        name: 'Jan Kowalski',
        age: 17,
        occupation: 'Student'
    },
    {
        type: 'admin',
        name: 'Tomasz Malinowski',
        age: 20,
        role: 'Administrator'
    }
];
// musimy powiedzieć, że te funkcje są strażnikami typów
function isAdmin(person) {
    return (person.type === 'admin');
}
exports.isAdmin = isAdmin;
function isUser(person) {
    return (person.type === 'user');
}
exports.isUser = isUser;
function logPerson(person) {
    var additionalInformation = '';
    if (isAdmin(person)) {
        additionalInformation = person.role;
    }
    if (isUser(person)) {
        additionalInformation = person.occupation;
    }
    console.log(" - ".concat(person.name, ", ").concat(person.age, ", ").concat(additionalInformation));
}
exports.logPerson = logPerson;
for (var i = 0; i < 2; i++) {
    logPerson(exports.persons[i]);
}
