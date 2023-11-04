create table osoba2 (
	id serial primary key,
	name varchar(150) not null,
	surname varchar(150) not null,
	sex char not null,
	age int not null,
	pesel char(11) not null
) ;

select * from osoba2 ;

insert into osoba2 (name, surname, sex, age, pesel) 
values ('Jan', 'Kowalski', 'M', 21, '12345678910');

insert into osoba2 (name, surname, sex, age, pesel) 
values ('Maria', 'Nowak', 'K', 25, '22345678910');

insert into osoba2 (name, surname, sex, age, pesel) 
values ('Maria', 'Nowacka', 'K', 30, '22345738910');

insert into osoba2 (name, surname, sex, age, pesel) 
values ('Jan', 'Nowak', 'M', 25, '22345679210');

select * from osoba2 ;
select * from osoba2 where name='Jan';
select * from osoba2 where age<30;