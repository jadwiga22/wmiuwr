CREATE SEQUENCE sequence23
as int
INCREMENT 1
MINVALUE -2147483648
MAXVALUE 2147483647
START WITH 1;

select nextval('sequence23');

create table osoba1 (
	id int primary key,
	name varchar(150) not null,
	surname varchar(150) not null,
	sex char not null,
	age int not null,	
	pesel char(11) not null
) ;

select * from osoba1;

insert into osoba1 (id, name, surname, sex, age, pesel) 
values (nextval('sequence23'), 'Jan', 'Kowalski', 'M', 21, '12345678910');

insert into osoba1 (id, name, surname, sex, age, pesel) 
values (nextval('sequence23'), 'Maria', 'Nowak', 'K', 25, '22345678910');

insert into osoba1 (id, name, surname, sex, age, pesel) 
values (nextval('sequence23'), 'Maria', 'Nowacka', 'K', 30, '22345738910');

insert into osoba1 (id, name, surname, sex, age, pesel) 
values (nextval('sequence23'), 'Jan', 'Nowak', 'M', 25, '22345679210');

select * from osoba1 ;
select * from osoba1 where name='Jan';
select * from osoba1 where age<30;

update osoba1 set name='Janek', surname='Kowalczyk' where id=11;