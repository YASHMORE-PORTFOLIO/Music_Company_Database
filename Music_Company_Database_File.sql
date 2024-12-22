-- Ques.1 Who is the senior most employee based on Hire Date?

SELECT * 
FROM Employee
ORDER BY hire_date ASC
LIMIT 1;

-- Ques.2 Which countries have the most Invoices?

SELECT count(billing_country) as number_of_invoices , billing_country as country 
FROM invoice 
GROUP BY billing_country
ORDER BY number_of_invoices DESC;

-- Ques.3 What are the top 3 values of total invoice?

SELECT total 
FROM invoice 
ORDER BY total DESC 
LIMIT 3;

-- Ques.4 Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals 

SELECT billing_city as City_Name, SUM(total) as Total_Invoice
FROM invoice
GROUP BY City_Name
ORDER BY Total_Invoice DESC
LIMIT 1;

-- Ques.5 Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query that returns the person who has spent the most money.

SELECT c.first_name as First_Name, c.last_name as Last_Name, c.customer_id as Customer_ID, SUM(i.total) as Total_Amount 
FROM customer as c JOIN invoice as i 
ON c.customer_id = i.customer_id 
GROUP BY c.customer_id, c.first_name, c.last_name 
ORDER BY Total_Amount DESC 
LIMIT 1;

-- Ques.6 Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A.

SELECT Distinct email, first_name, last_name 
FROM customer 
Where customer_id IN 
(SELECT iv.customer_id FROM invoice as iv JOIN invoice_line as ivl ON iv.invoice_id = ivl.invoice_id WHERE ivl.track_id IN (SELECT track.track_id FROM track JOIN genre ON track.genre_id = genre.genre_id WHERE genre.name = 'Rock')) 
ORDER BY email ASC;

-- Ques.7 Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands.

SELECT artist.name, artist.artist_id, COUNT(artist.artist_id) as Total_Track_Count
FROM track JOIN album2 ON track.album_id = album2.album_id JOIN artist ON artist.artist_id = album2.artist_id JOIN genre ON genre.genre_id = track.genre_id WHERE genre.name = 'ROCK' GROUP BY artist.name, artist.artist_id
ORDER BY Total_Track_Count DESC
LIMIT 10;

-- Ques.8 Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

SELECT name, milliseconds
FROM track 
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;

-- Ques.9 Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent.

SELECT customer.customer_id AS Customer_ID, first_name AS First_Name, last_name AS Last_Name, artist.name AS Artist_Name, rOUND(SUM(invoice_line.unit_price * invoice_line.quantity), 2) as Total_Amount_Spent
FROM customer 
JOIN invoice ON customer.customer_id = invoice.customer_id 
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON track.track_id = invoice_line.track_id
JOIN album2 ON album2.album_id = track.album_id
JOIN artist ON artist.artist_id = album2.artist_id
GROUP BY Customer_ID, First_Name, Last_Name, Artist_Name ORDER BY Total_Amount_Spent DESC;

-- Ques.10 We want to find out the most popular music Genre for each country.
		-- We determine the most popular genre as the genre with the highest amount of purchases.
		-- Write a query that returns each country along with the top Genre.
		-- For countries where the maximum number of purchases is shared, return all Genres.

WITH famous_genre AS
(  
SELECT customer.country AS Country, genre.genre_id AS Genre_ID, genre.name AS Genre, COUNT(invoice_line.quantity) AS Total_Purchase,
ROW_NUMBER() OVER (PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo
FROM invoice
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN customer ON customer.country = invoice.billing_country
JOIN track ON invoice_line.track_id = track.track_id
JOIN genre ON track.genre_id = genre.genre_id
GROUP BY customer.country, genre.genre_id, genre.name
ORDER BY Total_Purchase DESC
)
SELECT Country, Genre, Genre_ID, Total_Purchase FROM famous_genre WHERE RowNo <= 1;
        
-- Ques.11 Write a query that determines the customer that has spent the most on music for each country.
		-- Write a query that returns the country along with the top customer and how much they spent.
		-- For countries where the top amount spent is shared, provide all customers who spent this amount.
        
WITH MAX_COUNTRY_AMOUNT AS
(        
SELECT customer.first_name AS First_Name, customer.last_name AS Last_Name, customer.customer_id AS Customer_ID, invoice.billing_country AS Country, ROUND(SUM(invoice.total), 2) AS Total_Amount_Spent,
ROW_NUMBER() OVER (PARTITION BY invoice.billing_country ORDER BY COUNT(invoice.total) DESC) AS RowNo
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY First_Name, Last_Name, Customer_ID, invoice.billing_country
ORDER BY Total_Amount_Spent DESC
)
SELECT First_Name, Last_Name, Customer_ID, Country, Total_Amount_Spent FROM MAX_COUNTRY_AMOUNT WHERE RowNo <=1;