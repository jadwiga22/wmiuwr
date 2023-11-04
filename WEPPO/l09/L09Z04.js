var pg = require("pg");

async function BusinessProcess(pool, person, workplace) {
    try {
        if( !person || !workplace ) {
            return;
        }
        var queryWorkplace = "insert into miejsce_pracy (name) values ($1) returning id";
        var resultWorkplace = await pool.query(queryWorkplace, [workplace.name]);
        var idWorkplace = resultWorkplace.rows[0].id;
        var queryPerson = "insert into osoba (name, surname, id_miejsce_pracy) values ($1, $2, $3) returning id";
        var resultPerson = await pool.query(queryPerson, [person.name, person.surname, idWorkplace]);
        return resultPerson.rows[0].id;
    } catch (err) {
        console.log( err );
    }
}

async function StatsWorkplaces(pool) {
    try {
        var result = await pool.query('select  osoba.id_miejsce_pracy, count(osoba.id_miejsce_pracy) from osoba group by osoba.id_miejsce_pracy');
        return result.rows;
    } catch (err) {
        console.log( err );
    }
}

(async function main() {
    var pool = new pg.Pool({
        host: 'localhost',
        database: 'l09z04',
        user: 'postgres',
        password: 'password'
    });

    
    try {
        var newPersonId = await BusinessProcess(pool, {name: 'Janek', surname: 'Kowalczyk'}, {name: 'Sklep123'});
        console.log('id nowej osoby to ', newPersonId);

        var stats = await StatsWorkplaces(pool);
        stats.forEach(r => {
            console.log(JSON.stringify(r));
        });

    }
    catch ( err ) {
        console.log( err );
    }


        
})();
