create table Osoba (
	osoba_id serial primary key,
	osoba_name varchar(150),
	osoba_surname varchar(150)
) ;

create table Miejsce_pracy (
	miejsce_pracy_id serial primary key,
	miejsce_pracy_name varchar(150)
) ;

select * from Osoba;
select * from Miejsce_pracy;

create table OsobaMiejsce_pracy (
	osobamiejsce_pracy_id serial primary key,
	osobamiejsce_pracy_id_osoba int,
	osobamiejsce_pracy_id_miejsce_pracy int	
)

select * from OsobaMiejsce_pracy;

alter table osobamiejsce_pracy 
add constraint fk_OsobaMiejsce_pracy_Osoba
foreign key(osobamiejsce_pracy_id_osoba)
references Osoba (osoba_id)

alter table osobamiejsce_pracy 
add constraint fk_OsobaMiejsce_pracy_Miejsce_pracy
foreign key(osobamiejsce_pracy_id_miejsce_pracy)
references Miejsce_pracy (miejsce_pracy_id)

insert into Osoba (osoba_name, osoba_surname) values ('Jan', 'Kowalski');
insert into Osoba (osoba_name, osoba_surname) values ('Janek', 'Kowalczyk');
insert into Osoba (osoba_name, osoba_surname) values ('Maria', 'Nowak');
insert into Osoba (osoba_name, osoba_surname) values ('Anna', 'Kowalska');

insert into miejsce_pracy (miejsce_pracy_name) values ('Sklep');
insert into miejsce_pracy (miejsce_pracy_name) values ('Biblioteka');
insert into miejsce_pracy (miejsce_pracy_name) values ('Uniwersytet');

insert into osobamiejsce_pracy (osobamiejsce_pracy_id_osoba, osobamiejsce_pracy_id_miejsce_pracy) values (1, 1);
insert into osobamiejsce_pracy (osobamiejsce_pracy_id_osoba, osobamiejsce_pracy_id_miejsce_pracy) values (1, 2);
insert into osobamiejsce_pracy (osobamiejsce_pracy_id_osoba, osobamiejsce_pracy_id_miejsce_pracy) values (1, 3);
insert into osobamiejsce_pracy (osobamiejsce_pracy_id_osoba, osobamiejsce_pracy_id_miejsce_pracy) values (2, 1);
insert into osobamiejsce_pracy (osobamiejsce_pracy_id_osoba, osobamiejsce_pracy_id_miejsce_pracy) values (2, 2);
insert into osobamiejsce_pracy (osobamiejsce_pracy_id_osoba, osobamiejsce_pracy_id_miejsce_pracy) values (3, 3);

select osoba_name, osoba_surname, miejsce_pracy_name from osoba 
	join osobamiejsce_pracy on osoba.osoba_id = osobamiejsce_pracy.osobamiejsce_pracy_id_osoba
join miejsce_pracy on miejsce_pracy.miejsce_pracy_id = osobamiejsce_pracy_id_miejsce_pracy ;