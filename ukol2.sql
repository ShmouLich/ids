drop table vyucuje cascade constraints;
drop table prerekvizita cascade constraints;
drop table zapsal_si cascade constraints;
drop table povinny_predmet cascade constraints;
drop table predmet cascade constraints;
drop table student cascade constraints;
drop table stud_program cascade constraints;
drop table neakademicky_pracovnik cascade constraints;
drop table ucitel cascade constraints;
drop table ucebna cascade constraints;
drop table fakulta cascade constraints;
drop table ustav cascade constraints;

create table fakulta (
    zkratka varchar(16) not null primary key,
    nazev varchar(255) not null,
    mesto varchar(255) not null,
    ulice varchar(255) not null,
    cislo_domu int not null check (cislo_domu > 0),
    psc int not null check (psc >= 10000 and psc < 80000)
);

create table ucebna (
    cislo int primary key not null,
    budova varchar(1) not null check (regexp_like(budova, '^[a-zA-Z]$', 'i')),
    rozvrh varchar(255) check(regexp_like(rozvrh, '^po:[a-zA-Z,];ut:[a-zA-Z,];st:[a-zA-Z,];ct:[a-zA-Z,];pa:[a-zA-Z,];$', 'i'))
);

create table ustav (
    id int not null primary key,
    nazev varchar(255) not null,
    mesto varchar(255) not null,
    ulice varchar(255) not null,
    cislo_domu int not null check (cislo_domu > 0),
    psc int not null check (psc >= 10000 and psc < 80000),
    zkratka_fakulty varchar(16) not null,
    foreign key (zkratka_fakulty) references fakulta(zkratka)
);

-- generalizaci jsme vyřešili vytvořením tabulek pro podtypy i s atributy nadtypů
drop sequence ucitel_seq;
create sequence ucitel_seq start with 1;

create table ucitel (
    id int default ucitel_seq.nextval primary key,
    jmeno varchar(255) not null,
    prijmeni varchar(255) not null,
    email varchar(255) not null check(regexp_like(email, '^[a-z]+[a-z0-9.]*@[a-z0-9.-]+\.[a-z]+$', 'i')),
    telefon int check(telefon >= 100000000 and telefon <= 999999999),
    kancelar varchar(4) not null check(regexp_like(kancelar, '^[A-Z][0-9]{3}$', 'i')),
    id_ustav int not null,
    foreign key (id_ustav) references ustav(id)
);

drop sequence prac_seq;
create sequence prac_seq start with 1;

create table neakademicky_pracovnik (
    id int default prac_seq.nextval primary key,
    jmeno varchar(255) not null,
    prijmeni varchar(255) not null,
    email varchar(255) not null check(regexp_like(email, '^[a-z]+[a-z0-9.]*@[a-z0-9.-]+\.[a-z]+$', 'i')),
    telefon int check(telefon >= 100000000 and telefon <= 999999999),
    pozice varchar(255) not null check(lower(pozice) in ('technický pracovník', 'administrativní pracovník', 'externí pracovník', 'pan juříček')),
    id_ustav int not null,
    cislo_ucebny int,
    foreign key (id_ustav) references ustav(id),
    foreign key (cislo_ucebny) references ucebna(cislo)
);

drop sequence predmet_seq;
create sequence predmet_seq start with 1;

create table predmet (
    kod int default predmet_seq.nextval primary key,
    nazev varchar(255) not null,
    kred_hodnota int not null check(kred_hodnota >= 0),
    cislo_ucebny int not null,
    id_ustavu int not null,
    id_vedouciho int not null,
    foreign key (cislo_ucebny) references ucebna(cislo),
    foreign key (id_ustavu) references ustav(id),
    foreign key (id_vedouciho) references ucitel(id)
);

drop sequence program_seq;
create sequence program_seq start with 1;

create table stud_program (
    cislo int default program_seq.nextval  primary key,
    nazev varchar(255) not null,
    delka int check(delka>=2) not null,
    stupen varchar(255) not null check(lower(stupen) in ('bc', 'mgr', 'phd')),
    zkratka_fakulty varchar(16) not null,
    foreign key (zkratka_fakulty) references fakulta(zkratka)
);

create table povinny_predmet (
    kod_predmetu int,
    cislo_programu int,
    primary key (kod_predmetu, cislo_programu),
    foreign key (kod_predmetu) references predmet(kod),
    foreign key (cislo_programu) references stud_program(cislo)
);

drop sequence student_seq;
create sequence student_seq start with 1;

create table student (
    cislo int default student_seq.nextval primary key,
    rc varchar(10) not null check(
        (                                             --má 9 nebo 10 znaků
            regexp_like(rc, '^[0-9]{9}$', 'i')
            or regexp_like(rc, '^[0-9]{10}$', 'i')
        )
        and not regexp_like(rc, '[0]{3}$', 'i')       --nekončí na 000
        and (mod(to_number(rc), 11) = 0)              --je dělitelný 11
        and (                                         --měsíc je validní
            regexp_like(rc, '^[0-9]{2}[0][1-9]', 'i')
            or regexp_like(rc, '^[0-9]{2}[1][0-2]', 'i')
            or regexp_like(rc, '^[0-9]{2}[5][1-9]', 'i')
            or regexp_like(rc, '^[0-9]{2}[6][0-2]', 'i')
        )
        and (                                         --den je validní
            regexp_like(rc, '^[0-9]{4}[0][1-9]', 'i')
            or regexp_like(rc, '^[0-9]{4}[1-2][0-9]', 'i')
            or regexp_like(rc, '^[0-9]{4}[3][0-1]', 'i')
        )
    ),
    jmeno varchar(255) not null,
    prijmeni varchar(255) not null,
    mesto varchar(255) not null,
    ulice varchar(255) not null,
    cislo_domu int not null check (cislo_domu > 0),
    psc int not null check (psc >= 10000 and psc < 80000),
    cislo_programu int not null,
    foreign key (cislo_programu) references stud_program(cislo)
);

create table zapsal_si (
    znamka varchar(1) check(regexp_like(znamka, '[A-F]', 'i')),
    akademicky_rok varchar(9) check(regexp_like(akademicky_rok, '^[0-9]{4}/[0-9]{4}$')),
    kod_predmetu int,
    cislo_studenta int,
    primary key (kod_predmetu, cislo_studenta),
    foreign key (kod_predmetu) references predmet(kod),
    foreign key (cislo_studenta) references student(cislo)
);

create table prerekvizita (
    kod_predmetu int,
    kod_prerekvizity int,
    primary key (kod_predmetu, kod_prerekvizity),
    foreign key (kod_predmetu) references predmet(kod),
    foreign key (kod_prerekvizity) references predmet(kod)
);

create table vyucuje (
    id_ucitele int,
    kod_predmetu int,
    primary key (id_ucitele, kod_predmetu),
    foreign key (id_ucitele) references ucitel(id),
    foreign key (kod_predmetu) references predmet(kod)
);

---- inserty
insert into fakulta(zkratka, nazev, mesto, ulice, cislo_domu, psc)
values ('FIT', 'fakulta informačních technologií', 'Brno', 'Božetěchova', 1, 60200);

insert into fakulta(zkratka, nazev, mesto, ulice, cislo_domu, psc)
values ('FP', 'fakulta podnikatelská', 'Brno', 'Kolejní', 2906, 61200);

insert into fakulta(zkratka, nazev, mesto, ulice, cislo_domu, psc)
values ('FSI', 'fakulta strojního inženýrství', 'Brno', 'Technická', 2896, 61669);

------
insert into ustav(id, nazev, mesto, ulice, cislo_domu, psc, zkratka_fakulty)
values (1010, 'ústav inteligentních systémů', 'Brno', 'Božetěchova', 2, 60200, 'FIT');

insert into ustav(id, nazev, mesto, ulice, cislo_domu, psc, zkratka_fakulty)
values (1020, 'ústav informatiky', 'Brno', 'Kolejní', 3005, 61200, 'FP');

insert into ustav(id, nazev, mesto, ulice, cislo_domu, psc, zkratka_fakulty)
values (1030, 'ústav konstruování', 'Brno', 'Technická', 432, 61669, 'FSI');

------
insert into neakademicky_pracovnik(jmeno, prijmeni, email, telefon, pozice, id_ustav)
values ('Jana', 'Nováková', 'jana.novakova@vutbr.cz', 909667765, 'administrativní pracovník', 1020);

insert into neakademicky_pracovnik(jmeno, prijmeni, email, telefon, pozice, id_ustav)
values ('Eva', 'Fridrichová', 'eva.fridrichova@vutbr.cz', 909543765, 'technický pracovník', 1030);

insert into neakademicky_pracovnik(jmeno, prijmeni, email, telefon, pozice, id_ustav)
values ('Zdeněk', 'Juříček', 'pan.juricek@vutbr.cz', 432543765, 'Pan Juříček', 1010);

------
insert into ucitel(jmeno, prijmeni, email, telefon, kancelar, id_ustav)
values ('Jiří', 'Yeetovec', 'jirka.yeet@vutbr.cz', 909876876, 'C101', 1020);

insert into ucitel(jmeno, prijmeni, email, telefon, kancelar, id_ustav)
values ('Petr', 'Fuchs', 'petr.fuchs@vutbr.cz', 909543876, 'H101', 1030);

insert into ucitel(jmeno, prijmeni, email, telefon, kancelar, id_ustav)
values ('Dana', 'Hliněná', 'dana.hlinena@vutbr.cz', 906876876, 'L036', 1010);

------
insert into ucebna(cislo, budova, rozvrh)
values(100, 'A', 'po:izp,idm;ut:ilg,iel;st:ios,ius;ct:ima,ijc;pa:ivs,inc');

insert into ucebna(cislo, budova, rozvrh)
values(110, 'B', 'po:tin,izg;ut:;st:ifj,iss;ct:ids;pa:ics,inp');

insert into ucebna(cislo, budova, rozvrh)
values(120, 'C', 'po:;ut:ipt;st:itt,ipk;ct:izu;pa:iza,izlo');

------
insert into predmet(nazev, kred_hodnota, cislo_ucebny, id_ustavu, id_vedouciho)
values ('databázové systémy', 5, 100, 1010, 1);

insert into predmet(nazev, kred_hodnota, cislo_ucebny, id_ustavu, id_vedouciho)
values ('rétorika', 10, 110, 1020, 2);

insert into predmet(nazev, kred_hodnota, cislo_ucebny, id_ustavu, id_vedouciho)
values ('jazyk C', 1000, 120, 1030, 3);

------
insert into stud_program(nazev, delka, stupen, zkratka_fakulty)
values ('informační technologie', 3, 'bc', 'FIT');

insert into stud_program(nazev, delka, stupen, zkratka_fakulty)
values ('strojní inženýrství', 2, 'mgr', 'FSI');

insert into stud_program(nazev, delka, stupen, zkratka_fakulty)
values ('profesionální podnikání', 4, 'phd', 'FP');

------
insert into student(rc, jmeno, prijmeni, mesto, ulice, cislo_domu, psc, cislo_programu)
values ('0008225140', 'Jan', 'Bodlák', 'Brno', 'Kolejní', 423, 45325, 1);

insert into student(rc, jmeno, prijmeni, mesto, ulice, cislo_domu, psc, cislo_programu)
values ('0156084126', 'Božetěcha', 'Božetěchová', 'Praha', 'Václavské náměstí', 1, 10000, 2);

insert into student(rc, jmeno, prijmeni, mesto, ulice, cislo_domu, psc, cislo_programu)
values ('0156084137', 'Bořek', 'Stavitel', 'Liberec', 'Chrastava', 420, 42069, 3);

------
insert into zapsal_si(znamka, akademicky_rok, kod_predmetu, cislo_studenta)
values ('E', '2020/2021', 1, 1);

insert into zapsal_si(znamka, akademicky_rok, kod_predmetu, cislo_studenta)
values ('A', '2018/2019', 2, 2);

insert into zapsal_si(znamka, akademicky_rok, kod_predmetu, cislo_studenta)
values ('F', '2019/2020', 3, 3);

------
insert into povinny_predmet(kod_predmetu, cislo_programu)
values (1, 1);

insert into povinny_predmet(kod_predmetu, cislo_programu)
values (2, 2);

insert into povinny_predmet(kod_predmetu, cislo_programu)
values (3, 3);

------
insert into prerekvizita(kod_predmetu, kod_prerekvizity)
values (1, 2);

insert into prerekvizita(kod_predmetu, kod_prerekvizity)
values (1, 3);

insert into prerekvizita(kod_predmetu, kod_prerekvizity)
values (2, 3);

------
insert into vyucuje(id_ucitele, kod_predmetu)
values(1, 1);

insert into vyucuje(id_ucitele, kod_predmetu)
values(2, 2);

insert into vyucuje(id_ucitele, kod_predmetu)
values(3, 3);