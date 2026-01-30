use e2;

drop table if exists timesheet;
drop table if exists client;
drop table if exists project;
drop table if exists employee;
drop table if exists rate;


create table employee(
id_employee int identity(1,1) not null,
employee_name varchar(10),
magic varchar(10)
);

alter table employee add constraint pk_id_employee primary key clustered (id_employee);

insert into employee (employee_name, magic) values ('Sean','gannet');
insert into employee (employee_name, magic) values ('Alex','lapin');
insert into employee (employee_name, magic) values ('Paddy','seagull');

create table client(
id_client int identity(1,1) not null,
client_name varchar(30),
active char(1)
)

--insert into client (client_name) values ('Vitalis');
--insert into client (client_name) values ('AVHS');
insert into client (client_name) values ('Engine No.2');
insert into client (client_name) values ('Child Cancer Foundation NZ');
--insert into client (client_name) values ('Reconciliation Queensland');


create table project(
id_project int identity(1,1) not null,
id_client varchar(20),
project varchar(50),
subproject varchar(50),
active char(1)
);

alter table project add constraint pk_id_project primary key clustered (id_project);



create table rate (
id_rate int identity(1,1) not null,
rate int,
rate_desc varchar(255)
)

alter table rate add constraint pk_id_rate primary key clustered (id_rate);

insert into rate (rate, rate_desc) values (250, 'Programme Manager');
insert into rate (rate, rate_desc) values (150, 'Project Manager');
insert into rate (rate, rate_desc) values (80, 'Project Admin');
insert into rate (rate, rate_desc) values (250, 'Snr Solution Architect');
insert into rate (rate, rate_desc) values (200, 'Solution Architect');
insert into rate (rate, rate_desc) values (150, 'Technical Lead');
insert into rate (rate, rate_desc) values (120, 'Technical Consultant');
insert into rate (rate, rate_desc) values (120, 'Developer');
insert into rate (rate, rate_desc) values (100, 'Tester');

create table timesheet (
id_timesheet int identity(1,1) not null,
id_employee int not null,
id_project int not null,
id_rate int not null,
shift_date date,
start_time datetime,
end_time datetime,
create_time datetime,
update_time datetime,
notes varchar(255)
);

alter table timesheet add constraint pk_id_timesheet primary key clustered (id_timesheet);

alter table timesheet add constraint fk_id_employee foreign key (id_employee)
	references employee(id_employee) on delete cascade on update cascade;

alter table timesheet add constraint fk_id_project foreign key (id_project)
	references project(id_project) on delete cascade on update cascade;

alter table timesheet add constraint fk_id_rate foreign key (id_rate)
	references rate(id_rate) on delete cascade on update cascade;


select * from timesheet





