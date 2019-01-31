USE sakila;

/*1a. Display the first and last names of all actors from the table actor*/
SELECT first_name, last_name 
	FROM actor;

/*1b. Display the first and last name of each actor in a single column 
in upper case letters. Name the column Actor Name.*/
SELECT CONCAT(UPPER(first_name), " ", UPPER(last_name)) 'Actor Name' 
	FROM actor;

/*2a. You need to find the ID number, first name, and last name of an actor, 
of whom you know only the first name, "Joe." What is one query would you use 
to obtain this information?*/
SELECT actor_id, first_name, last_name 
	FROM actor
    WHERE first_name = "Joe";
    
/*2b. Find all actors whose last name contain the letters GEN*/
SELECT actor_id, first_name, last_name 
	FROM actor
    WHERE UPPER(last_name) LIKE "%GEN%";

/*2c. Find all actors whose last names contain the letters LI. This time, 
order the rows by last name and first name, in that order:*/
SELECT actor_id, first_name, last_name 
	FROM actor
    WHERE UPPER(last_name) LIKE "%LI%"
    ORDER BY last_name, first_name;
    
/*2d. Using IN, display the country_id and country columns of the following countries: 
Afghanistan, Bangladesh, and China*/
SELECT country_id, country 
	FROM country
    WHERE country IN ("Afghanistan", "Bangladesh", "China");
    
/*3a. You want to keep a description of each actor. 
You don't think you will be performing queries on a description, 
so create a column in the table actor named description and use the data type BLOB 
(Make sure to research the type BLOB, as the difference between it and VARCHAR are significant)*/
ALTER TABLE actor
	ADD description BLOB;
    
/*3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
Delete the description column.*/
ALTER TABLE actor
	DROP COLUMN description;
    
/*4a. List the last names of actors, as well as how many actors have that last name*/
SELECT last_name, COUNT(actor_id) 'Actor Count'
	FROM actor
    GROUP BY last_name;

/*4b. List last names of actors and the number of actors who have that last name, 
but only for names that are shared by at least two actors*/
SELECT last_name, COUNT(actor_id) actor_count
	FROM actor
    GROUP BY last_name
    HAVING actor_count >= 2;

/*4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
Write a query to fix the record.*/
UPDATE actor
	SET first_name = "HARPO"
    WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";
    
/*4d. Perhaps we were too hasty in changing GROUCHO to HARPO. 
It turns out that GROUCHO was the correct name after all! In a single query, 
if the first name of the actor is currently HARPO, change it to GROUCHO*/
UPDATE actor
	SET first_name = "GROUCHO"
    WHERE first_name = "HARPO";
    
/*5a. You cannot locate the schema of the address table. Which query would you use to re-create it?*/
SHOW CREATE TABLE address;

/*6a. Use JOIN to display the first and last names, as well as the address, 
of each staff member. Use the tables staff and address*/
SELECT st.first_name, st.last_name, ad.address
	FROM staff st
    JOIN address ad
    ON st.address_id = ad.address_id;
    
/*6b. Use JOIN to display the total amount rung up by each staff member in 
August of 2005. Use tables staff and payment*/
SELECT st.first_name, st.last_name, pmt.payment_amount
	FROM staff st
	JOIN (
		SELECT staff_id, SUM(amount) payment_amount
			FROM payment
            GROUP BY staff_id
		) pmt
	ON st.staff_id = pmt.staff_id;
    
/*6c. List each film and the number of actors who are listed for that film. 
Use tables film_actor and film. Use inner join*/
SELECT fm.title, act.number_actors
	FROM film fm
    JOIN (
		SELECT film_id, COUNT(actor_id) number_actors
			FROM film_actor
            GROUP BY film_id
		) act
	ON fm.film_id = act.film_id;
    
/*6d. How many copies of the film Hunchback Impossible exist in the inventory system?*/
SELECT COUNT(inventory_id) hi_inventory
	FROM inventory
    WHERE film_id = (
		SELECT film_id
			FROM film
            WHERE title = "Hunchback Impossible"
		);

/*6e. Using the tables payment and customer and the JOIN command, 
list the total paid by each customer. List the customers alphabetically by last name*/
SELECT ct.first_name, ct.last_name, pmt.total_paid 'Total Amount Paid'
	FROM customer ct
    LEFT JOIN (
		SELECT customer_id, SUM(amount) total_paid
			FROM payment
            GROUP BY customer_id
		) pmt
	ON ct.customer_id = pmt.customer_id
	ORDER BY ct.last_name;
    
/*7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
As an unintended consequence, films starting with the letters K and Q 
have also soared in popularity. Use subqueries to display the titles of movies 
starting with the letters K and Q whose language is English.*/
SELECT title
	FROM film
    WHERE (title LIKE "K%" OR title LIKE "Q%")
		AND language_id IN (
			SELECT language_id
				FROM laNguage
                WHERE name="English"
			);
    
/*7b. Use subqueries to display all actors who appear in the film Alone Trip*/
SELECT first_name, last_name
	FROM actor
    WHERE actor_id IN (
		SELECT actor_id
			FROM film_actor
            WHERE film_id IN (
				SELECT film_id
					FROM film
                    WHERE title = "Alone Trip"
				)
		);


/*7c. You want to run an email marketing campaign in Canada, 
for which you will need the names and email addresses of all Canadian customers. 
Use joins to retrieve this information.*/
SELECT cust.first_name, cust.last_name, cust.email
	FROM customer cust
    JOIN address addr
		ON cust.adDress_id = addr.address_id
	JOIN city ct
		ON addr.city_id = ct.city_id
	JOIN country cou
		ON cou.country_id = ct.country_id AND cou.country = "Canada";
        

/*7d. Sales have been lagging among young families, 
and you wish to target all family movies for a promotion. 
Identify all movies categorized as family films.*/
SELECT fm.film_id, fm.title 
	FROM film fm
	JOIN film_category fg
		ON fm.film_id = fg.film_id
	JOIN category cat
		ON cat.category_id = fg.category_id AND cat.name = "Family";
        

/*7e. Display the most frequently rented movies in descending order*/
SELECT fmrt.title, COUNT(fmrt.rental_id) AS rental_count
FROM (
	SELECT fm.title, rt.rental_id
		FROM film fm
		JOIN inventory inv
			ON fm.film_id = inv.film_id
		JOIN rental rt
			ON inv.inventOry_id = rt.inventory_id
	) fmrt
    GROUP BY fmrt.title
    ORDER BY rental_count DESC;

/*7f. Write a query to display how much business, in dollars, each store brought in.*/
SELECT strt.store_id, SUM(strt.amount) AS total_amount
FROM (
	SELECT inv.store_id, pmt.amount
		FROM inventory inv
		JOIN rental rt
			ON inv.inventory_id = rt.inventory_id
		JOIN payment pmt
			ON rt.rental_id = pmt.rental_id
	) strt
    GROUP BY strt.store_id;
    
/*7g. Write a query to display for each store its store ID, city, and country.*/
SELECT st.store_id, ct.city, co.country
	FROM store st
	JOIN address ad
		ON st.address_id = ad.address_id
	JOIN city ct
		ON ad.city_id = ct.city_id
	JOIN country co
		ON ct.country_id = co.country_id;
    
/*7h. List the top five genres in gross revenue in descending order. 
(Hint: you may need to use the following tables: category, film_category, 
inventory, payment, and rental.)*/
SELECT ct.name, SUM(pmt.amount) revenue
	FROM category ct
		JOIN film_category fc
			ON ct.category_id = fc.category_id
		JOIN inventory inv
			ON fc.film_id = inv.film_id
		JOIN rental rt
			ON inv.inventory_id = rt.inventory_id
		JOIN payment pmt
			ON rt.rental_id = pmt.rental_id
	GROUP BY ct.name
    ORDER BY revenue LIMIT 5;


/*8a. In your new role as an executive, you would like to have an easy way of 
viewing the Top five genres by gross revenue. Use the solution from the problem 
above to create a view. If you haven't solved 7h, you can substitute another query to create a view.*/
CREATE VIEW top_five_genres AS 
(SELECT ct.name, SUM(pmt.amount) revenue
	FROM category ct
		JOIN film_category fc
			ON ct.category_id = fc.category_id
		JOIN inventory inv
			ON fc.film_id = inv.film_id
		JOIN rental rt
			ON inv.inventory_id = rt.inventory_id
		JOIN payment pmt
			ON rt.rental_id = pmt.rental_id
	GROUP BY ct.name
    ORDER BY revenue LIMIT 5
);

/*8b. How would you display the view that you created in 8a?*/
SELECT * FROM top_five_genres;

/*8c. You find that you no longer need the view top_five_genres. 
Write a query to delete it.*/
DROP VIEW top_five_genres;