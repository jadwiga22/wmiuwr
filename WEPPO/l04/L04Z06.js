var readline = require("readline");
var fs = require("fs");

const rl = readline.createInterface({
  input: fs.createReadStream("logs.txt"),
  crlfDelay: Infinity
});


var NumberOfLogs = {};
rl.on('line', (line) => {
  let p = line.split(" ")[1];
  if (NumberOfLogs[p] !== undefined) {
    NumberOfLogs[p] += 1;
  } else {
    NumberOfLogs[p] = 1;
  }
}).on('close', () => {
  var ArrayOfLogs = [];
  // console.log(NumberOfLogs);
  for (var cl in NumberOfLogs) {
    ArrayOfLogs.push([cl, NumberOfLogs[cl]]);
  }
  ArrayOfLogs.sort((a, b) => {
    return (b[1] - a[1]);
  });
  for(var i = 0; i < 3; i++) {
      console.log( ArrayOfLogs[i][0] + " " + ArrayOfLogs[i][1] );
  }
});
