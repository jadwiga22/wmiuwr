var pg = require("pg");

async function GetPerson(pool) {
    try {
        var result = await pool.query("select * from Osoba1");
        result.rows.forEach((r) => {
            console.log(`${r.ID} ${r.ParentName}`);
        });
    } catch (err) {
        console.log(err);
    }
}

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

(async function main() {
    var pool = new pg.Pool({
        host: 'localhost',
        database: 'l09z01',
        user: 'postgres',
        password: 'password'
    });

    
    try {
        var items = await RetrievePerson(pool);
        items.forEach(r => {
            console.log(`${r.id} ${r.name} ${r.surname} ${r.sex} ${r.age} ${r.pesel} `);
        });

        var items2 = await RetrievePerson(pool, "'a'; delete from osoba1; --");
        items2.forEach(r => {
            console.log(`${r.id} ${r.name} ${r.surname} ${r.sex} ${r.age} ${r.pesel} `);
        });

        var items3 = RetrievePerson(pool, "Maria")
            .then(data => {
                data.forEach( d => {
                    console.log(JSON.stringify(d));
                });
            });
        
        var newPersonId = await InsertPerson(pool, {
            name: 'Anna',
            surname: 'Maria', 
            sex: 'K',
            age: '55',
            pesel: '02325476542'
        });

        console.log('\n---------\nid nowego rekordu to: ', newPersonId);

        var items4 = await RetrievePerson(pool);
        items4.forEach(r => {
            console.log(`${r.id} ${r.name} ${r.surname} ${r.sex} ${r.age} ${r.pesel} `);
        });
    }
    catch ( err ) {
        console.log( err );
    }


        
})();
