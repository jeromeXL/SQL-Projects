-- COMP3311 22T3 Assignment 1
--
-- Fill in the gaps ("...") below with your code
-- You can add any auxiliary views/function that you like
-- The code in this file *MUST* load into an empty database in one pass
-- It will be tested as follows:
-- createdb test; psql test -f ass1.dump; psql test -f ass1.sql
-- Make sure it can load without error under these conditions


-- Q1: new breweries in Sydney in 2020

create or replace view Q1(brewery,suburb) as
select b.name, l.town 
from breweries b 
inner join locations l on b.located_in = l.id
where b.founded = 2020 and l.metro = 'Sydney'
;

-- Q2: beers whose name is same as their style

create or replace view Q2(beer,brewery) as
select b1.name, b2.name
from beers b1
inner join styles s on b1.style = s.id
inner join brewed_by b3 on b1.id = b3.beer
inner join breweries b2 on b3.brewery = b2.id
where b1.name = s.name
;

-- Helper View for Breweries in California
create or replace view breweries_california as
select b2.id, b2.name, b2.founded, b2.located_in 
from breweries b2
inner join locations l on b2.located_in = l.id
where l.region = 'California'
;

-- Q3: original Californian craft brewery

create or replace view Q3(brewery,founded)as
select b2.name, b2.founded 
from breweries_california b2
where b2.founded = (select min(founded) from breweries_california)
;

-- Helper View for IPA beers 
create or replace view IPA_beers as
select b1.id, b1.name, b1.style
from beers b1
inner join styles s on b1.style = s.id
where s.name ilike '%IPA%'
;

-- Q4: all IPA variations, and how many times each occurs

create or replace view Q4(style,count) as
select s.name, count(s.name)
from styles s
inner join IPA_beers b1 on s.id = b1.style
group by s.name
;

-- Q5: all Californian breweries, showing precise location

create or replace view Q5(brewery,location) as
select b2.name, COALESCE(l.town, l.metro)
from breweries_california b2
inner join locations l on l.id = b2.located_in
;

-- Helper View for barrel-aged beers 
create or replace view barrel_aged_beers as
select b1.id, b1.name, b1.abv
from beers b1
where (b1.notes ilike '%barrel%')
and (b1.notes ilike '%aged%')
;

-- Q6: strongest barrel-aged beer

create or replace view Q6(beer,brewery,abv) as
select b1.name as beer, b2.name as brewery, b1.abv
from barrel_aged_beers b1
inner join brewed_by b3 on b1.id = b3.beer
inner join breweries b2 on b2.id = b3.brewery
where b1.abv = (select max(abv) from barrel_aged_beers)
;

-- Helper view for hop
create or replace view hop_ingredients as
select i.name, count(i.name)
from ingredients i
inner join contains c on i.id = c.ingredient
inner join beers b1 on b1.id = c.beer
where i.itype = 'hop'
group by i.name
;

-- Q7: most popular hop

create or replace view Q7(hop) as
select i.name
from hop_ingredients i
where i.count = (select max(count) from hop_ingredients)
;

-- Helper view for breweries that brew common beers
create or replace view brews_common_beers as
select b2.id
from breweries b2
inner join brewed_by b3 on b2.id = b3.brewery
inner join beers b1 on b1.id = b3.beer
inner join styles s on b1.style = s.id 
where s.name like '%IPA%'
or s.name like '%Lager%'
or s.name like '%Stout%'
;

-- Q8: breweries that don't make IPA or Lager or Stout (any variation thereof)

create or replace view Q8(brewery) as
select b2.name
from breweries b2
where b2.id not in (select * from brews_common_beers)
;

-- Helper View for Hazy IPA beers 
create or replace view hazy_IPA_beers as
select b1.id, b1.name, s.name as style
from beers b1
inner join styles s on b1.style = s.id 
where s.name = 'Hazy IPA'
;

-- Helper View for Grains in Hazy IPA beers
create or replace view grain_hazyIPA as
select i.id, i.name, count(i.id)
from ingredients i
inner join contains c on c.ingredient = i.id
inner join hazy_IPA_beers b1 on c.beer = b1.id 
where i.itype = 'grain'
group by i.id
;

-- Q9: most commonly used grain in Hazy IPAs

create or replace view Q9(grain) as
select i.name
from grain_hazyIPA i
where i.count = (select max(count) from grain_hazyIPA)
;

-- Helper View for Ingredients used 
create or replace view ingredients_used as
select distinct c.ingredient
from contains c
;

-- Q10: ingredients not used in any beer

create or replace view Q10(unused) as
select i.name
from ingredients i
where i.id not in (select * from ingredients_used)
;


-- Helper View for Beers and Countries 
create or replace view beers_from_country as 
select b1.id, b1.abv, l.country
from beers b1
inner join brewed_by b3 on b1.id = b3.beer
inner join breweries b2 on b2.id = b3.brewery
inner join locations l on l.id = b2.located_in
;

-- Q11: min/max abv for a given country

drop type if exists ABVrange cascade;
create type ABVrange as (minABV float, maxABV float);

create or replace function 
	Q11(_country text) returns ABVrange 
as $$
declare
	a ABVrange;
begin 
	for a in 
		select coalesce(min(abv)::numeric(4,1), 0) as minABV, coalesce(max(abv)::numeric(4,1), 0) as maxABV
		from beers_from_country b1
		where b1.country = _country
	loop
		return a;
	end loop;		
end;
$$ language plpgsql;


-- Helper view for beer data
create or replace view beer_data as 
select b1.name as beer, b2.name as brewery, i.name as ingredient, i.itype 
from beers b1 
inner join brewed_by b3 on b3.beer = b1.id 
inner join breweries b2 on b3.brewery = b2.id 
inner join contains c on c.beer = b1.id 
inner join ingredients i on c.ingredient = i.id 
;

-- Q12: details of beers

drop type if exists BeerData cascade;
create type BeerData as (beer text, brewer text, info text);

create or replace function
	Q12(partial_name text) returns setof BeerData
as $$
declare 
	bd BeerData;
begin 
	for bd in 
		select b.beer as beer, b.brewery as brewer, b.ingredient as info
		from beer_data b
		where b.beer ~ partial_name
	loop
		return next bd;
	end loop; 
end;
$$ language plpgsql;
