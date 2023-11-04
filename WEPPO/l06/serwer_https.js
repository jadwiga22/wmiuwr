var https = require('https');
var fs = require('fs');

(async function () {
    var pfx = await fs.promises.readFile('test.pfx');
    var server = 
        https.createServer(
            {
                pfx: pfx,
                passphrase: 'haslo'
            },
            (req, res) => {
                res.setHeader('Content-type', 'text/html; charset=utf-8');
                res.end(`Hello world! It's ${new Date()}. \n ${req.url}`);
            });

    server.listen(3000);
    console.log('started');
})();

