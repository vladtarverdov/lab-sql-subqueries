#1.How many copies of the film Hunchback Impossible exist in the inventory system?
USE sakila;

SELECT f.title, COUNT(i.inventory_id)
FROM sakila.inventory i
LEFT JOIN sakila.film f 
ON i.film_id = f.film_id
GROUP BY f.title
HAVING f.title = 'Hunchback Impossible';

SELECT COUNT(film_id) AS InventoryCounty FROM sakila.inventory
WHERE film_id = (SELECT film_id FROM sakila.film
WHERE title = 'Hunchback Impossible');

#2.List all films whose length is longer than the average of all the films.
SELECT * FROM sakila.film
WHERE length > (SELECT avg(length) FROM sakila.film)
ORDER BY length DESC
LIMIT 25;

#3.Use subqueries to display all actors who appear in the film Alone Trip.
SELECT CONCAT(first_name,' ', last_name) AS ActorName FROM sakila.actor
join film_actor as fc
using(actor_id)
where fc.film_id in ( 
	select film_id
    from  film
    where title = 'Alone Trip'
    )
    group by ActorName;
    

#4.Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
#Identify all movies categorized as family films.
select title 
from film
where film_id in 
(select film_id from film_category
where category_id = 
(select category_id from sakila.category
where name = 'Family'
)
);

/* 5.Get name and email from customers from Canada using subqueries. 
#Do the same with joins. Note that to create a join, 
#you will have to identify the correct tables with their primary keys and foreign keys, 
#that will help you get the relevant information */

#subqueries:
select concat(first_name, ' ', last_name) AS CustomerName, email FROM sakila.customer
where address_id in
(select address_id from address
where city_id in
(select city_id from city
where country_id =
(select country_id from sakila.country
where country = 'Canada'))
    );

#with joins:
select CONCAT(c.first_name, ' ', c.last_name) as Customer_Name, c.email 
from customer c
join address a
	on c.address_id = a.address_id
join sakila.city ci
	on a.city_id = ci.city_id
join sakila.country cn
	on ci.country_id = cn.country_id
where cn.country = 'Canada';

/* 6.Which are films starred by the most prolific actor? 
Most prolific actor is defined as the actor that has acted in the most number of films. 
First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred. */

select title from film
where film_id in (
	select film_id from film_actor
	where actor_id =
		(select actor_id from film_actor
			group by actor_id
			order by COUNT(actor_id) desc
			limit 1
        )
    );

/* 7.Films rented by most profitable customer. 
You can use the customer table and payment table to find the most profitable customer 
 the customer that has made the largest sum of payments */

select title from film
where film_id in
	(select film_id from inventory
	where inventory_id in
		(select inventory_id from sakila.rental
		where customer_id = 
			(select customer_id from sakila.payment
			group by customer_id
			order by SUM(amount) desc
			limit 1
            )
        )
    )
    order by title;

#8.Customers who spent more than the average payments.
SELECT first_name, last_name FROM sakila.customer
WHERE customer_id IN
	(SELECT customer_id FROM sakila.payment
	GROUP BY customer_id
	HAVING SUM(amount) >
		(SELECT AVG(amount) FROM sakila.payment
        )
	)
ORDER BY last_name;