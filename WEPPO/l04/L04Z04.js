// czy da się uruchomić to w konsoli, a nie w terminalu? 

process.stdin.on("data", name => {
    name = name.toString();
    console.log(`Witaj ${name}`);
    process.exit();
})