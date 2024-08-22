--Beginner level:
/*Q1: Who is the Senior most Employee based on Job title?*/

select first_name, last_name, levels, title from employee
order by levels desc
offset 0 rows
fetch first 1 row only;

/*Q2: Which countries have the most Invoices?*/

select billing_country, count(*) as "Invoice Count" from invoice
group by billing_country
order by count(*) desc;

/*Q3: What are Top 3 values of Total Invoice?*/

select total as "Invoice Total" from invoice
order by total desc
offset 0 rows
fetch first 3 rows only;

/* Q4:Which city has the best customers? We would like to throw a 
promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals.*/

select billing_city, sum(total) as "Invoice Total" from invoice
group by billing_city
order by sum(total) desc
offset 0 rows
fetch first 1 row only;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared 
the best customer. 
Write a query that returns the person who has spent the most money.*/

select c.customer_id, c.first_name,c.last_name, sum(i.total) as "Total Amount Spent" from customer c
inner join invoice i
on c.customer_id=i.customer_id
group by c.customer_id
order by sum(i.total) desc
offset 0 rows
fetch first 1 row only;

--Moderate level:

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

select distinct c.email, c.first_name,c.last_name, g.name from customer c
inner join invoice i 
on c.customer_id=i.customer_id
inner join invoice_line o
on i.invoice_id=o.invoice_id
inner join track t
on t.track_id=o.track_id
inner join genre g
on t.genre_id=g.genre_id
where g.name like 'Rock'
order by c.email asc;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

/*Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the artist name and the total number of tracks (songs performed) 
for the top 10 rock bands based on their performance of rock music.*/

select a.artist_id, a.name, count(t.track_id) from artist a
inner join album b
on a.artist_id=b.artist_id
inner join track t
on b.album_id=t.album_id
inner join genre g
on t.genre_id=g.genre_id
where g.name like 'Rock'
group by a.artist_id
order by count(t.track_id) desc
offset 0 rows
fetch first 10 rows only;

--OR

SELECT a.artist_id, a.name, count(t.track_id) from artist a, album b,track t, genre g
WHERE a.artist_id=b.artist_id AND b.album_id=t.album_id AND t.genre_id=g.genre_id AND g.name like 'Rock'
group by a.artist_id
order by count(t.track_id) desc
offset 0 rows
fetch first 10 rows only;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

select t.name, t.milliseconds from track t
where t.milliseconds>(select avg(t.milliseconds) from track t)
order by t.milliseconds desc;

--Advanced level
/* Q1: Find how much amount spent by each customer on artists?
Write a query to return customer name, artist name and total spent */
with best_selling_artist as 
	(
	select a.artist_id, a.name, sum(il.unit_price*il.quantity) as Total_Amount_Spent from invoice_line il
	inner join track t 
	on il.track_id=t.track_id
	inner join album b
	on b.album_id=t.album_id
	inner join artist a
	on a.artist_id=b.artist_id
	group by 1
	order by 3 desc
	offset 0 rows
	fetch first 1 row only
	)
select c.customer_id, c.first_name, c.last_name, bsa.name,
sum(il.unit_price*il.quantity) as Total_Amount_Spent from customer c 
inner join invoice i
on i.customer_id=c.customer_id
inner join  invoice_line il
on il.invoice_id=i.invoice_id
inner join track t 
on il.track_id=t.track_id
inner join album b
on b.album_id=t.album_id
inner join best_selling_artist bsa
on b.artist_id=bsa.artist_id
group by 1,2,3,4
order by 5 desc;
	
/* Q2: We want to find out the most popular music Genre for each country. 
We determine the most popular genre as the genre with the highest amount of purchases. 
Write a query that returns each country along with the top Genre. For countries where the maximum number 
of purchases is shared return all Genres.*/
with popular_genre as 
(
    select count(il.quantity) as purchases, c.country, g.name, g.genre_id, 
	row_number() over (partition by c.country order by count(il.quantity) desc) as RowNo 
    from invoice_line il 
	inner join invoice i on i.invoice_id = il.invoice_id
	inner join customer c on c.customer_id = i.customer_id
	inner join track t on t.track_id = il.track_id
	inner join genre g on g.genre_id = g.genre_id
	group by 2,3,4
	order by 2 asc, 1 desc
)
select * from popular_genre where RowNo <= 1;

/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
with Customer_with_country as
(
	select c.customer_id, c.first_name, c.last_name,i.billing_country,sum(total) as Total_Spending,
    row_number() over(partition by i.billing_country 
	order by sum(total) desc) as RowNo 
	from invoice i
	inner join customer c on c.customer_id = i.customer_id
	group by 1,2,3,4
	order by 4 asc,5 desc
)
select * from Customer_with_country where RowNo <= 1;


















