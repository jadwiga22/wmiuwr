create table Osoba (
	id serial primary key,
	name varchar(150),
	surname varchar(150),
	id_miejsce_pracy int
) ;

create table Miejsce_pracy (
	id serial primary key,
	name varchar(150)
) ;

select * from Osoba;
select * from Miejsce_pracy;

alter table Osoba 
add constraint fk_Osoba_Miejsce_pracy
foreign key(id_miejsce_pracy)
references Miejsce_pracy (id)

insert into miejsce_pracy (name) values ('Sklep');
insert into miejsce_pracy (name) values ('Biblioteka');

--insert into Osoba (name, surname, id_miejsce_pracy) values ('Jan', 'Kowalski', 3);
insert into Osoba (name, surname, id_miejsce_pracy) values ('Jan', 'Kowalski', 1);

select  osoba.id_miejsce_pracy, count(osoba.id_miejsce_pracy) from osoba
group by osoba.id_miejsce_pracy 
