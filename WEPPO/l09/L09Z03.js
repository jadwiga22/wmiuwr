var pg = require("pg");

async function RetrievePerson(pool, name) {
    try {
        var result;
        if( name ) {
            result = await pool.query('select * from osoba1 where name=$1', [name]);
        } else {
            result = await pool.query('select * from osoba1');
        }
        return result.rows;
    } catch (err) {
        console.log(err);
    }
}

async function InsertPerson(pool, person) {
    try {
        if( !person ) {
            return;
        }
        var query = "insert into osoba1 (id, name, surname, sex, age, pesel) values (nextval('sequence23'),$1, $2, $3, $4, $5) returning id";
        var result = await pool.query(query, [person.name, person.surname, person.sex, person.age, person.pesel]);
        return result.rows[0].id;
    } catch (err) {
        console.log( err );
    }
}

async function UpdatePerson(pool, person) {
    if( !person || !person.id ) {
        return;
    }
    try {
        var query = "update osoba1 set name=$2, surname=$3, sex=$4, age=$5, pesel=$6 where id=$1";
        var result = await pool.query(query, [person.id, person.name, person.surname, person.sex, person.age, person.pesel]);
        return result.rowCount;
    } catch (err) {
        console.log( err );
    }
}

async function DeletePerson(pool, personId) {
    try {
        var query = "delete from osoba1 where id=$1";
        var result = await pool.query(query, [personId]);
        return result.rowCount;

    } catch (err) {
        console.log( err );
    }
}

(async function main() {
    var pool = new pg.Pool({
        host: 'localhost',
        database: 'l09z01',
        user: 'postgres',
        password: 'password'
    });

    
    try {
        // var items = await RetrievePerson(pool);
        // items.forEach(r => {
        //     console.log(`${r.id} ${r.name} ${r.surname} ${r.sex} ${r.age} ${r.pesel} `);
        // });

        // var items2 = await RetrievePerson(pool, "'a'; delete from osoba1; --");
        // items2.forEach(r => {
        //     console.log(`${r.id} ${r.name} ${r.surname} ${r.sex} ${r.age} ${r.pesel} `);
        // });

        // var items3 = RetrievePerson(pool, "Maria")
        //     .then(data => {
        //         data.forEach( d => {
        //             console.log(JSON.stringify(d));
        //         });
        //     });
        
        // var newPersonId = await InsertPerson(pool, {
        //     name: 'Anna',
        //     surname: 'Maria', 
        //     sex: 'K',
        //     age: '55',
        //     pesel: '02325476542'
        // });

        // console.log('\n---------\nid nowego rekordu to: ', newPersonId);

        // var items4 = await RetrievePerson(pool);
        // items4.forEach(r => {
        //     console.log(`${r.id} ${r.name} ${r.surname} ${r.sex} ${r.age} ${r.pesel} `);
        // });

        var items5 = await UpdatePerson(pool, {
            id: 11,
            name: 'Michał',
            surname: 'Kostka',
            sex: 'M',
            age: '4',
            pesel: '32787698732'
        });
        console.log('\n----------------\nliczba zmienionych rekordów: ', items5);

        var items6 = await DeletePerson(pool, 21);
        console.log('\n----------------\nliczba zmienionych rekordów: ', items6);

    }
    catch ( err ) {
        console.log( err );
    }


        
})();
