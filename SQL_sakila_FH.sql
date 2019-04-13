USE sakila;

-- 1a Display the first and last names of all actors from the table actor. --
SELECT first_name, last_name FROM actor;

-- 1b Display the first and last name of each actor in a single column in upper case letters.--
SELECT UCASE(CONCAT(first_name, ', ', last_name)) AS Actorname
FROM actor;

-- 2a You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe."
SELECT * FROM actor
WHERE first_name = 'Joe';

-- 2b Find all actors whose last name contain the letters GEN
SELECT * FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c Find all actors whose last names contain the letters LI. 
-- This time, order the rows by last name and first name, in that order:
SELECT * FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d Using IN, display the country_id and country columns 
-- countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country FROM country
WHERE country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a create a column in the table actor named description and use the data type BLOB
ALTER TABLE actor
ADD description BLOB;

-- 3b Delete the description column from actor table.
ALTER TABLE actor
DROP COLUMN description;

-- 4a List the last names of actors, as well as how many actors have that last name
SELECT last_name, COUNT(first_name) AS Total_Person from actor
GROUP BY last_name;

-- 4b List the last names of actors, as well as how many actors have that last name
-- and at least two persons
SELECT last_name, COUNT(first_name) AS Total_Person from actor
GROUP BY last_name
HAVING COUNT(first_name)>1;

-- 4c The actor HARPO WILLIAMS was accidentally entered in the actor table 
-- as GROUCHO WILLIAMS
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' and last_name = 'WILLIAMS';

-- 4d It turns out that GROUCHO was the correct name and then we need to change it
UPDATE actor
SET first_name = 'GROUCHO'
WHERE actor_id = 172;

-- 5a You cannot locate the schema of the address table. 
-- Which query would you use to re-create it?
CREATE TABLE new_address AS 
SELECT * FROM address;

-- 6a Use JOIN to display the first and last names, 
-- as well as the address, of each staff member.
SELECT S.first_name,S.last_name,A.address,A.address2,A.district,A.city_id,A.postal_code
FROM staff AS S
INNER JOIN address AS A
ON S.address_id = A.address_id;

-- 6b Use JOIN to display the total amount rung up by each staff member in August of 2005.
SELECT CONCAT(S.first_name,', ',S.last_name) AS staff_name,SUM(P.amount) AS Total_amount
FROM staff AS S
INNER JOIN payment AS P
ON S.staff_id = P.staff_id
WHERE P.payment_date between '2005-08-01' and '2005-08-31 23:59:59'
GROUP BY CONCAT(S.first_name,', ',S.last_name);

-- 6c List each film and the number of actors who are listed for that film
SELECT F.film_id,F.title,COUNT(FA.actor_id) AS Total_actor
FROM film AS F
INNER JOIN film_actor AS FA
ON F.film_id = FA.film_id
GROUP BY F.film_id;

-- 6d How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT F.title,COUNT(I.film_id) AS Total_inventory
FROM film AS F
INNER JOIN inventory AS I
ON F.film_id = I.film_id
where title = 'Hunchback Impossible';

-- 6e list the total paid by each customer. 
-- List the customers alphabetically by last name:
SELECT C.customer_id,C.first_name,C.last_name,SUM(P.amount) AS Total_Paid
FROM customer AS C
INNER JOIN payment AS P
ON C.customer_id = P.customer_id
GROUP BY C.customer_id
ORDER BY C.last_name;

-- 7a Use subqueries to display the titles of movies starting 
-- with the letters K and Q whose language is English.
SELECT * FROM film
WHERE language_id IN (SELECT language_id FROM language WHERE name = 'ENGLISH') 
and (title like 'K%' or title like 'Q%');

-- 7b Use subqueries to display all actors who appear in the film Alone Trip.
SELECT F.title,FA.actor_id,A.first_name,A.last_name
FROM film AS F
INNER JOIN film_actor AS FA
ON F.film_id = FA.film_id
INNER JOIN actor AS A
ON A.actor_id = FA.actor_id
WHERE F.title = 'ALONE TRIP';

-- 7c Need the names and email addresses of all Canadian customers.
SELECT CONCAT(C.first_name,', ',C.last_name) AS Customer_name, C.email, CT.country
FROM customer AS C
INNER JOIN address AS A
ON C.address_id = A.address_id
INNER JOIN city AS CI
ON A.city_id = CI.city_id
INNER JOIN country AS CT
ON CI.country_id = CT.country_id
WHERE CT.country = 'Canada';

-- 7d Identify all movies categorized as family films
SELECT F.title, F.description,F.release_year, C.name AS Movie_Category
FROM film AS F
INNER JOIN film_category AS FC
ON F.film_id = FC.film_id
INNER JOIN category AS C
ON FC.category_id = C.category_id
WHERE C.name = 'Family';

-- 7e Display the most frequently rented movies in descending order
SELECT F.film_id,F.title,F.description,F.release_year, COUNT(F.film_id) AS Total_rental_count
FROM film AS F
INNER JOIN inventory AS I
ON F.film_id = I.film_id
INNER JOIN rental AS R
ON I.inventory_id = R.inventory_id
INNER JOIN customer AS C
ON R.customer_id = C.customer_id
GROUP BY film_id
ORDER BY COUNT(F.film_id) DESC;

-- 7f and 7g Display for each store its store ID, city, country, and its earning.
SELECT S.store_id, C.city, CT.country, SUM(P.amount) AS Total_Earning
FROM payment AS P
INNER JOIN staff AS ST
ON P.staff_id = ST.staff_id
INNER JOIN store AS S
ON ST.store_id = S.store_id
INNER JOIN address AS A
ON S.address_id = A.address_id
INNER JOIN city AS C
ON A.city_id = C.city_id
INNER JOIN country AS CT
ON C.country_id = CT.country_id
GROUP BY S.store_id;

-- 7h  List the top five genres in gross revenue in descending order.
SELECT C.category_id, C.name, SUM(P.amount) AS Total_Earning
FROM payment AS P
INNER JOIN rental AS R
ON P.rental_id = R.rental_id
INNER JOIN inventory AS I
ON R.inventory_id = I.inventory_id
INNER JOIN film_category AS FC
ON I.film_id = FC.film_id
INNER JOIN category AS C
ON FC.category_id = C.category_id
GROUP BY C.category_id
ORDER BY SUM(P.amount) DESC
LIMIT 5;

-- 8a Create a view of 7h.
CREATE VIEW top_five_genres AS
SELECT C.category_id, C.name, SUM(P.amount) AS Total_Earning
FROM payment AS P
INNER JOIN rental AS R
ON P.rental_id = R.rental_id
INNER JOIN inventory AS I
ON R.inventory_id = I.inventory_id
INNER JOIN film_category AS FC
ON I.film_id = FC.film_id
INNER JOIN category AS C
ON FC.category_id = C.category_id
GROUP BY C.category_id
ORDER BY SUM(P.amount) DESC
LIMIT 5;

-- 8b How would you display the view that you created in 8a?
SELECT * FROM top_five_genres;

-- 8c You find that you no longer need the view top_five_genres.
DROP VIEW top_five_genres;
