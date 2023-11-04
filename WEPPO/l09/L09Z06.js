var pg = require('pg');

function RandInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

// async function InitializeDB(pool, SIZE) {
//     try {
//         var names = ['Jan', 'Marek', 'Adam', 'Mateusz', 'Grzegorz', 'Michał', 'Franciszek', 'Artur', 'Janusz', 'Horacy'];
//         var surnames = ['Kowalski', 'Nowak', 'Nowacki', 'Kowalczyk', 'Nowicki', 'Nowy', 'Stary', 'Czytalski', 'Maksymalny', 'Minimalny'];
//         var query = 'insert into osoba (name, surname, age) values ($1, $2, $3)';
//         for(var i = 0; i < SIZE; i++) {
//             var name = names[RandInt(0,9)];
//             var surname = surnames[RandInt(0,9)];
//             var age = RandInt(20,60);
//             var result = await pool.query(query, [name, surname, age]);
//         }
//     } catch (err) {
//         console.log( err );
//     }
      
// }

async function Select(pool, name) {
    try {
        var query = 'select * from osoba where name=$1';
        var result = await pool.query(query, [name]);
        return result.rows;

    } catch (err) {
        console.log( err );
    }
}


(async function main() {
    var pool = new pg.Pool({
        host: 'localhost',
        database: 'l09z06',
        user: 'postgres',
        password: 'password'
    });

    
    try {
        // await InitializeDB(pool, 2000000);
        // console.log( "here" );

        console.time('Select execution time');
        var res = await Select(pool, 'Jan');
        console.timeEnd('Select execution time');
        var rowsCount = 0;
        res.forEach(r => {
            rowsCount++;
        });
        console.log(rowsCount);

    }
    catch ( err ) {
        console.log( err );
    }


        
})();