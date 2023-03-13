-- COMP3311 21T3 Ass2 ... extra database definitions
-- add any views or functions you need into this file
-- note: it must load without error into a freshly created Movies database
-- you must submit this file even if you add nothing to it

create or replace view getPeopleWithName(id) as
select p1.id 
from people p1
where p1.name = 'Michael Davis'
order by id
;

create or replace view getPeopleWhoDirect() as 
select distinct p1.name
from people p1 
inner join principals p2 on p1.id = p2.person
where p1.name = 'Michael Davis'
and p2.job = 'director'
order by id
;

create or replace view Q1(movie, year_produced) as
select m.title, m.year
from movies m 
inner join principals p2 on p2.movie = m.id
inner join people p1 on p2.person = p1.id
where p2.job = 'director' 
and p1.name = 'James Cameron'
;

create or replace view Q2(countries) as
select c.name
from countries c
inner join releasedin r on r.country = c.code
inner join movies m on r.movie = m.id
where m.title = 'A Christmas to Remember'
and m.year = 2016
order by c.name
;

create or replace view Q3(count, genre) as 
select count(g.genre), g.genre
from moviegenres g
inner join movies m on g.movie = m.id
where m.year = 2020
group by g.genre
order by count(g.genre) desc
fetch first 10 rows with ties
;

create or replace view Q4(acting_role, movie, year_produced) as
select p3.role, m.title, m.year
from movies m 
inner join principals p2 on p2.movie = m.id
inner join people p1 on p2.person = p1.id
inner join playsrole p3 on p3.inmovie = p2.id
where p1.name = 'Chris Hemsworth'
and (p2.job = 'actor' or p2.job = 'actress' or p2.job = 'self')
order by m.year asc
;

create or replace view Q5(movie, person, film_role, acting_role) as 
select m.title, p1.name, p2.job, p3.role
from movies m
inner join principals p2 on p2.movie = m.id
inner join people p1 on p2.person = p1.id
inner join playsrole p3 on p3.inmovie = p2.id
where m.title ilike '%avatar%'
;
