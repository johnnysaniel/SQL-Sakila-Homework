Sakila SQL Homework

# 1a. Display the first and last names of all actors from the table `actor`.
select first_name, last_name FROM actor;

# 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
SELECT concat(first_name, ' ', last_name) AS actor_name
FROM actor;

# 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name 
FROM actor
WHERE first_name = "joe";

# 2b. Find all actors whose last name contain the letters `GEN`:
SELECT *
FROM actor
WHERE last_name Like '%GEN%';

# 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
SELECT *
FROM actor
where last_name like '%LI%'
ORDER BY last_name, first_name DESC;

# 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

# 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
ALTER TABLE actor
ADD COLUMN description BLOB AFTER last_name;

# 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
ALTER TABLE actor
drop COLUMN description;

# 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) AS 'Count'
from actor
GROUP BY last_name;

# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS 'Count'
from actor
GROUP BY last_name
HAVING COUNT >= 2;

# 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

HARPO WILLIAMS NOT FOUND IN ACTOR TABLE so I used PENELOPE GUINESS AS AN EXAMPLE

update actor
SET first_name = "GROUCHO"
WHERE first_name = "PENELOPE"
AND last_name = "GUINESS";

# 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
update actor
SET first_name = "PENELOPE"
WHERE first_name = "GROUCHO"
AND last_name = "GUINESS";

# 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
CREATE TABLE address (
  address_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  address VARCHAR(50) NOT NULL,
  address2 VARCHAR(50) DEFAULT NULL,
  district VARCHAR(20) NOT NULL,
  city_id SMALLINT UNSIGNED NOT NULL,
  postal_code VARCHAR(10) DEFAULT NULL,
  phone VARCHAR(20) NOT NULL,
  /*!50705 location GEOMETRY NOT NULL,*/
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (address_id),
  KEY idx_fk_city_id (city_id),
  /*!50705 SPATIAL KEY `idx_location` (location),*/
  CONSTRAINT `fk_address_city` FOREIGN KEY (city_id) REFERENCES city (city_id) ON DELETE RESTRICT ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

# 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:
SELECT s.first_name, s.last_name, s.address_id
FROM staff s
INNER JOIN address a ON s.address_id = a.address_id;

# 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.
SELECT s.first_name, s.last_name, p.payment_date, SUM(p.amount) AS 'Total_Amount'
FROM staff s LEFT JOIN payment p  ON s.staff_id = p.staff_id
WHERE p.payment_date BETWEEN '2005-08-01' AND '2005-08-31'

# 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.
SELECT f.title AS 'Film', COUNT(a.actor_id) AS 'Number of Actors in film'
FROM film f INNER JOIN film_actor a ON f.film_id = a.film_id
GROUP BY f.title;

# 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?
SELECT f.title AS "Movie Title", COUNT(inventory_id) AS "Number of Copies"
FROM film f INNER JOIN inventory i ON f.film_id = i.film_id
WHERE f.title = 'Hunchback Impossible';


# 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.first_name, c.last_name, SUM(p.amount) AS "Total Amount Paid" 
FROM payment p INNER JOIN customer c ON p.customer_id = c.customer_id 
GROUP BY c.last_name;

# 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
SELECT title AS 'Movie Title'
FROM film
WHERE (title LIKE 'K%' OR title LIKE 'Q%') 
AND language_id= (SELECT language_id FROM language WHERE name = 'English')

# 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.
SELECT a.first_name, a.last_name
FROM actor a
WHERE actor_id IN (SELECT i.actor_id FROM film_actor i WHERE i.film_id
				IN (SELECT f.film_id FROM film f WHERE f.title = "Alone Trip"));

# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT c.country, i.first_name, i.last_name, i.email
FROM country c
INNER JOIN customer i
ON c.country_id = i.customer_id
WHERE c.country = 'Canada';

# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.
SELECT f.title, f.category
FROM film_list f
WHERE f.category = 'Family';

# 7e. Display the most frequently rented movies in descending order.
SELECT f.title as 'Movie_Title', COUNT(f.film_id) AS 'Rental_Count'
FROM film f
JOIN inventory i ON (f.film_id = i.film_id)
	JOIN rental r ON (i.inventory_id = r.inventory_id)
		GROUP BY title
        ORDER BY Rental_Count DESC
        LIMIT 100

# 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id as "Store ID", SUM(p.amount) as "Total Amounts"
FROM payment p
INNER JOIN staff s ON p.staff_id = s.staff_id
GROUP BY s.store_id;

# 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, co.country 
FROM store s
INNER JOIN address a ON s.address_id = a.address_id 
	INNER JOIN city c ON a.city_id = c.city_id 
		INNER JOIN country co ON c.country_id = co.country_id;

# 7h. List the top five genres in gross revenue in descending order. (##Hint##: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name AS "Categories", SUM(p.amount) AS "Gross_Revenue" 
FROM category c
JOIN film_category f ON (c.category_id = f.category_id)
	JOIN inventory i ON (f.film_id = i.film_id)
		JOIN rental r ON (i.inventory_id = r.inventory_id)
			JOIN payment p ON (r.rental_id = p.rental_id)
GROUP BY c.name 
ORDER BY Gross_Revenue desc
LIMIT 5;

# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_Five_Genres_by_Gross_revenue AS
    (SELECT 
        c.name AS 'Categories', SUM(p.amount) AS 'Gross_Revenue'
    FROM
        category c
            JOIN
        film_category f ON (c.category_id = f.category_id)
            JOIN
        inventory i ON (f.film_id = i.film_id)
            JOIN
        rental r ON (i.inventory_id = r.inventory_id)
            JOIN
        payment p ON (r.rental_id = p.rental_id)
    GROUP BY c.name
    ORDER BY Gross_Revenue DESC
    LIMIT 5);

# 8b. How would you display the view that you created in 8a?
SELECT *
FROM Top_Five_Genres_by_Gross_revenue;

# 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
DROP VIEW Top_Five_Genres_by_Gross_revenue;