USE music_bd;

CREATE TABLE employee(
employee_id VARCHAR(50) PRIMARY KEY,
last_name CHAR(50),
first_name CHAR(50),
title VARCHAR(50),
reports_to VARCHAR(30),
levels VARCHAR(10),
birthdate DATE,
hire_date DATE,
address VARCHAR(120),
city VARCHAR(50),
state VARCHAR(50),
country VARCHAR(30),
postal_code VARCHAR(30),
phone VARCHAR(30),
fax VARCHAR(30),
email VARCHAR(30));


CREATE TABLE customer(
customer_id INT PRIMARY KEY,
first_name CHAR(30),
last_name CHAR(100),
company VARCHAR(100),
address VARCHAR(100),
city VARCHAR(100),
state VARCHAR(10),
country VARCHAR(30),
postal_code varchar(30),
phone Varchar(100),
fax varchar(100),
email VARCHAR(30),
support_rep_id INT);

CREATE TABLE invoice(
invoice_id INT PRIMARY KEY,
customer_id INT,
invoice_date TIMESTAMP,
billing_address VARCHAR(120),
billing_city VARCHAR(30),
billing_state VARCHAR(30),
billing_country VARCHAR(30),
billing_postal VARCHAR(50),
total FLOAT8);

CREATE TABLE invoice_line(
invoice_line_id int PRIMARY KEY,
invoice_id VARCHAR(30),
track_id VARCHAR(30),
unit_price VARCHAR(30),
quantity INT);

CREATE TABLE track(
track_id VARCHAR(50) PRIMARY KEY,
name VARCHAR(50),
album_id VARCHAR(30),
media_type_id VARCHAR(30),
genre_id VARCHAR(30),
composer VARCHAR(200),
milliseconds Varchar(20),
bytes INT,
unit_price INT);


CREATE TABLE playlist(
playlist_id INT PRIMARY KEY,
name  VARCHAR(50));

CREATE TABLE playlist_track(
playlist_id VARCHAR(50),
track_id VARCHAR(50));

CREATE TABLE artist(
artist_id INT PRIMARY KEY,
name  VARCHAR(100)); 

CREATE TABLE album(
album_id INT NOT NULL PRIMARY KEY,
title VARCHAR(100),
artist_id INT);

CREATE TABLE media_type(
media_type_id INT PRIMARY KEY,
name VARCHAR(30));

CREATE TABLE genre(
genre_id INT PRIMARY KEY,
name VARCHAR(50));

SELECT * FROM genre;
SELECT * FROM media_type;
SELECT * FROM album;
SELECT * FROM artist;
SELECT * FROM playlist_track;
SELECT * FROM playlist;
SELECT * FROM track;
SELECT * FROM invoice_line;
SELECT * FROM invoice;
SELECT * FROM customer;
SELECT * FROM employee;

/* Set 1 */

/* Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1;


/* Which countries have the most Invoices? */

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC;


/* What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC;


/* Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;


/* Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT c.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer c
JOIN invoice iv ON c.customer_id = iv.customer_id
GROUP BY c.customer_id
ORDER BY total_spending DESC
LIMIT 1;


/* Set 2 */

/* Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

-- Method 1 

SELECT DISTINCT email,first_name, last_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line iv ON iv.invoice_id = iv.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track t
	JOIN genre g ON t.genre_id = g.genre_id
	WHERE g.name LIKE 'Rock'
)
ORDER BY email;

-- Method 2 

SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, g.name AS Name
FROM customer c
JOIN invoice i ON i.customer_id = c.customer_id
JOIN invoice_line iv ON iv.invoice_id = i.invoice_id
JOIN track t ON t.track_id = iv.track_id
JOIN genre g ON g.genre_id = t.genre_id
WHERE g.name LIKE 'Rock'
ORDER BY email;


/* Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT ar.artist_id, ar.name,COUNT(ar.artist_id) AS number_of_songs
FROM track t
JOIN album a ON a.album_id = t.album_id
JOIN artist ar ON ar.artist_id = a.artist_id
JOIN genre g ON g.genre_id = t.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY ar.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;


/* Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name,milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC;


/* Set 3 */

/* Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

WITH best_selling_artist AS (
	SELECT ar.artist_id AS artist_id, ar.name AS artist_name, SUM(iv.unit_price*iv.quantity) AS total_sales
	FROM invoice_line iv
	JOIN track t ON t.track_id = iv.track_id
	JOIN album a ON a.album_id = t.album_id
	JOIN artist ar ON ar.artist_id = a.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(iv.unit_price*iv.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line iv ON iv.invoice_id = i.invoice_id
JOIN track t ON t.track_id = iv.track_id
JOIN album a ON a.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = a.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


/* We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

-- Method 1: Using CTE

WITH popular_genre AS 
(
    SELECT COUNT(iv.quantity) AS purchases, c.country, g.name, g.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(iv.quantity) DESC) AS RowNo 
    FROM invoice_line iv
	JOIN invoice i ON i.invoice_id = iv.invoice_id
	JOIN customer c ON c.customer_id = i.customer_id
	JOIN track t ON t.track_id = iv.track_id
	JOIN genre g ON g.genre_id = t.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;


-- Method 2: Using Recursive 

WITH RECURSIVE
	sales_per_country AS(
		SELECT COUNT(*) AS purchases_per_genre, c.country, g.name, g.genre_id
		FROM invoice_line iv
		JOIN invoice i ON i.invoice_id = iv.invoice_id
		JOIN customer c ON c.customer_id = i.customer_id
		JOIN track t ON t.track_id = iv.track_id
		JOIN genre g ON g.genre_id = t.genre_id
		GROUP BY 2,3,4
		ORDER BY 2
	),
	max_genre_per_country AS (SELECT MAX(purchases_per_genre) AS max_genre_number, country
		FROM sales_per_country
		GROUP BY 2
		ORDER BY 2)

SELECT sales_per_country.* 
FROM sales_per_country
JOIN max_genre_per_country ON sales_per_country.country = max_genre_per_country.country
WHERE sales_per_country.purchases_per_genre = max_genre_per_country.max_genre_number;


/* Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

-- Method 1: using CTE 

WITH Customter_with_country AS (
		SELECT c.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice i
		JOIN customer c ON c.customer_id = i.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1;


-- Method 2: Using Recursive 

WITH RECURSIVE 
	customter_with_country AS (
		SELECT c.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending
		FROM invoice i
		JOIN customer c ON c.customer_id = i.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country cc
JOIN country_max_spending ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 2;