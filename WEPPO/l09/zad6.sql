create table osoba (
	id serial primary key,
	name varchar(150),
	surname varchar(150),
	age int
)

select * from osoba
limit 10;

select count(*) from osoba; 

select * from osoba where name like 'J%';


drop index idx_osoba_name;
create index idx_osoba_name
on osoba (name);