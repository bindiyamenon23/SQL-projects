--  --  Which actors have the first name 'Scarlett'
select first_name,actor_id
from actor
where first_name="Scarlett";

--  --  Which actors have the last name 'Johansson'

select last_name,actor_id
from actor
where last_name="Johansson";

--  --  How many distinct actors last names are there?

select count(distinct last_name) from actor;

--  --  Which last names are not repeated?
select count(*) from (select last_name, count(last_name)
from actor
group by last_name
having count(last_name)=1) t;

--  --  Which last names appear more than once?
select last_name, count(last_name)
from actor
group by last_name
having count(last_name)>1;

--  --  Which actor has appeared in the most films?
select actor_id,count(film_id) count from film_actor group by actor_id order by count desc limit 1;

--  --  Is 'Academy Dinosaur' available for rent from Store 1?
select * from inventory where store_id=1 and film_id=(
select film_id from film where title='Academy Dinosaur');



--  --  Step 1: which copies are at Store 1?
select distinct film_id , inventory_id from inventory where store_id=1;

--  --  Step 2: pick an inventory_id to rent:

--  --  Insert a record to represent Mary Smith renting 'Academy Dinosaur' from Mike Hillyer at Store 1 today .
select customer_id from customer where first_name="Mary" and last_name="Smith";
select film_id from film where title='Academy Dinosaur';
select staff_id from staff where first_name="Mike" and last_name="Hillyer";
insert into rental(rental_date,inventory_id,customer_id,staff_id) values (now(),1,1,1);

--  --  When is 'Academy Dinosaur' due?
select * from rental where inventory_id=1;
--  --  Step 1: what is the rental duration?
select rental_duration from film where title='Academy Dinosaur';

--  --  Step 2: which rental are we referring to -- the last one.

select rental_id from rental order by rental_id desc limit 1;

--  --  Step 3: add the rental duration to the rental date.

update rental
set return_date=rental_date+interval (select rental_duration from film where title='Academy Dinosaur') day
where rental_id=16050;

--  --  What is that average running time of all the films in the sakila DB?

select avg(length) from film;

--  --  What is the average running time of films by category?

select c.name,avg(f.length)
from film f join film_text ft using(title)
join film_category fc on ft.film_id=fc.film_id
join category c on fc.category_id=c.category_id
group by fc.category_id;


--  -- Which film categories are long?

select c.name,avg(f.length)
from film f join film_text ft using(title)
join film_category fc on ft.film_id=fc.film_id
join category c on fc.category_id=c.category_id
group by fc.category_id
having avg(f.length)>(select avg(length) from film);

-- -- What are the names of all the languages in the database (sorted alphabetically)?

select distinct name from language order by name;

-- -- Return the full names (first and last) of actors with “SON” in their last name, ordered by their firstname.

select concat(first_name," ",last_name) from actor where last_name like "%son%" order by first_name;

-- -- Find all the addresses where the second address is not empty (i.e., contains some text), and return
-- -- these second addresses sorted.

select address2 from address
where length(address2)>0
order by address2;

-- -- Find all the film categories in which there are between 55 and 65 films. Return the names of these
-- -- categories and the number of films per category, sorted by the number of films.

select fc.category_id,c.name,count(fc.film_id) 
from film_category fc join category c 
using(category_id)
group by fc.category_id 
having count(fc.film_id) between 55 and 65
order by count(fc.film_id);

-- -- In how many film categories is the average difference between the film replacement cost and the
-- -- rental rate larger than 17?

select * from category;
select * from film_category;

select  cat_id,cat_name,(avg_replacement_cost-avg_rental_cost) avg_difference from (
select c.category_id cat_id, c.name cat_name, avg(rental_rate) avg_rental_cost, avg(replacement_cost) avg_replacement_cost
from film f join film_category fc on f.film_id=fc.film_id
join category c on fc.category_id=c.category_id
group by c.category_id, c.name) table1
where (avg_replacement_cost-avg_rental_cost)>17;

-- -- Add a middle_name column to the table actor. 
-- -- Position it between first_name and last_name. Hint: you will need to specify the data type.

alter table actor add column middle_name varchar(20);
alter table actor modify column middle_name varchar(20) after first_name;

select * from actor;

-- -- Change the data type of the middle_name column to blobs.

alter table actor modify column middle_name blob;

-- -- Now delete the middle_name column.

alter table actor drop column middle_name;

-- --  List the last names of actors, as well as how many actors have that last name.

select last_name,count(last_name) from actor group by last_name;

-- -- List last names of actors and the number of actors who have that last name, but only for names that are shared 
-- -- by at least two actors

select last_name,count(last_name) from actor group by last_name having count(last_name)>1;

-- -- You cannot locate the schema of the address table. Which query would you use to re-create it?

show create table actor;

-- -- Use JOIN to display the first and last names, 
-- -- as well as the address, of each staff member. Use the tables staff and address.

select first_name,last_name,s.address_id,a.address
from staff s join address a using(address_id);

-- -- List each film and the number of actors who are listed for that film. Use tables film_actor and film. 

select fa.film_id,f.title,count(fa.actor_id)
from film_actor fa join film f using(film_id)
group by fa.film_id,f.title;

-- -- How many copies of the film Hunchback Impossible exist in the inventory system

select count(film_id) from inventory where film_id=(select film_id from film where title="Hunchback Impossible");

-- -- Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- -- List the customers alphabetically by last name:

select c.customer_id,c.first_name,c.last_name,sum(p.amount)
from customer c join payment p using(customer_id)
group by c.customer_id,c.first_name,c.last_name
order by c.last_name;

-- -- Use subqueries to display all actors who appear in the film Alone Trip.

select fa.actor_id,a.first_name,a.last_name
from film_actor fa join actor a using(actor_id)
where fa.film_id=(select film_id from film where title="Alone Trip");

-- -- You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers.
-- --  Use joins to retrieve this information.


select cus.first_name,cus.last_name,cus.email,coun.country
from customer cus join address a using(address_id)
join city c on a.city_id=c.city_id
join country coun on c.country_id=coun.country_id
where coun.country="Canada";

-- -- Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- -- Identify all movies categorized as family films.

select f.film_id,f.title
from film f join film_category fc using(film_id)
where fc.category_id=(select category_id from category where name="Family");

-- -- Write a query to display the number of transactions at each store.

select i.store_id,count(i.store_id)
from inventory i join rental r on r.inventory_id=i.inventory_id
group by i.store_id;

-- -- Write a query to display how much business, in dollars, each store brought in.

select sid,sum(total_amount_per_film) from (
select i.store_id sid,i.film_id fid,count(i.film_id)*f.rental_rate total_amount_per_film
from inventory i join rental r on r.inventory_id=i.inventory_id
join film f on i.film_id=f.film_id
group by sid,fid) table1
group by sid;

-- --  Write a query to display for each store its store ID, city, and country.

select s.store_id,c.city,coun.country
from store s join address a using(address_id)
join city c using(city_id)
join country coun using(country_id);


-- -- create a view
create view v1 as
select * from film limit 5;

select * from v1;

drop view  v1;



