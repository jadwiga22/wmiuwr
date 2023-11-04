var pg = require("pg");

async function BusinessProcess(pool, person, workplace) {
    try {
        if( !person || !workplace ) {
            return;
        }
        var queryWorkplace = "insert into miejsce_pracy (miejsce_pracy_name) values ($1) returning miejsce_pracy_id";
        var resultWorkplace = await pool.query(queryWorkplace, [workplace.name]);
        var idWorkplace = resultWorkplace.rows[0].miejsce_pracy_id;
        var queryPerson = "insert into osoba (osoba_name, osoba_surname) values ($1, $2) returning osoba_id";
        var resultPerson = await pool.query(queryPerson, [person.name, person.surname]);
        var idPerson = resultPerson.rows[0].osoba_id;
        var queryPersonWorkplace = "insert into osobamiejsce_pracy (osobamiejsce_pracy_id_osoba, osobamiejsce_pracy_id_miejsce_pracy) values ($1, $2) returning osobamiejsce_pracy_id";
        var result = await pool.query(queryPersonWorkplace, [idPerson, idWorkplace]);
        return result.rows[0].osobamiejsce_pracy_id;
    } catch (err) {
        console.log( err );
    }
}

async function StatsWorkplaces(pool) {
    try {
        var result = await pool.query('select osoba_name, osoba_surname, miejsce_pracy_name from osoba join osobamiejsce_pracy on osoba.osoba_id = osobamiejsce_pracy.osobamiejsce_pracy_id_osoba join miejsce_pracy on miejsce_pracy.miejsce_pracy_id = osobamiejsce_pracy_id_miejsce_pracy ;');
        return result.rows;
    } catch (err) {
        console.log( err );
    }
}

(async function main() {
    var pool = new pg.Pool({
        host: 'localhost',
        database: 'l09z05',
        user: 'postgres',
        password: 'password'
    });

    
    try {
        var newPersonWorkplaceId = await BusinessProcess(pool, {name: 'Janek', surname: 'Kowalczyk'}, {name: 'Sklep123'});
        console.log('id nowej pracy to ', newPersonWorkplaceId);

        var stats = await StatsWorkplaces(pool);
        stats.forEach(r => {
            console.log(JSON.stringify(r));
        });

    }
    catch ( err ) {
        console.log( err );
    }


        
})();
