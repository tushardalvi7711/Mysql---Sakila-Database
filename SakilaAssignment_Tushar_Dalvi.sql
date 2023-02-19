Assignment 
---------------------
/* 1. Return the full names (first and last) and address of customers with “SON” in their last name,
 ordered by their first name. */
 
 use sakila
 select customer.first_name, customer.last_name, address.address
 from customer  
 left JOIN address ON customer.address_id=address.address_id 
  where last_name LIKE '%SON%' 
 order by first_name;
 
/* 2. Find all the addresses where the second address is not empty (i.e., contains some text), 
 and return these second addresses sorted.*/
 
 SELECT address from address
 where address2 is NOT NULL
 order by address2;
 
 /* 3. In how many film categories is the average difference 
 between the film replacement cost and the rental rate larger than 17? */

select COUNT(DISTINCT c.category_id)
from film f LEFT JOIN film_category c
ON f.film_id = c.film_id
where (replacement_cost - rental_rate)>17;

/* 4. Find the address district(s) name(s) such that the minimal postal code in the district(s) is 
maximal over all the districts. Make sure your query ignores empty postal codes 
and district names. */

select district,postal_code
from address
where postal_code= (select max(P_code)
from ( select district, min(postal_code) as P_code 
from address 
where postal_code <>''
and district <>''
 group by district) as a);
 
 select * from address 
 
-- 5. List all the actor names with their film names.
select concat(a.first_name,' ',a.last_name) as Actor_name,m.title as film_names
from film_actor f JOIN actor a
 ON (f.actor_id=a.actor_id)
join film m
ON m.film_id = f.film_id;

/* 6. Return the first and last names of actors who played in a film involving a “Crocodile”
 and a “Shark”, along with the release year of the movie, 
sorted by the actors’ last names.*/
select concat(a.first_name,' ',last_name) AS Actor_name , m.release_year
from film m JOIN film_actor f 
ON m.film_id = f.film_id 
JOIN actor a
ON a.actor_id = f.actor_id
where description LIKE '%Crocodile%' AND  description LIKE '%Shark%'
ORDER BY a.last_name ;

-- 7.How many films involve a “Crocodile” and a “Shark”?
SELECT COUNT(film_id) from film  where DESCRIPTION LIKE '%Crocodile%' 
AND DESCRIPTION LIKE '%Shark%';

/* 8. Find the names (first and last) of all the actors and custumers whose first name is 
the same as the first name of the actor with ID 8. Do not return the actor with ID 8 himself. 
Note that you cannot use the name of the actor with ID 8 as a constant (only the ID).
 There is more than one way to solve this question,but you need to provide only one solution. */
 
 select concat(first_name,' ', last_name) As Customer_name  
 from customer 
 where first_name = (select first_name from actor where actor_id = 8)
  
union all
 
select concat(first_name,' ', last_name) As Actor_name   
from actor 
where first_name = (select first_name from actor where actor_id = 8)
AND actor_id<>8;

/* 9. Find all the film categories in which there are between 55 and 65 films. 
Return the names of these categories and the number of films per category,
sorted by the number of films. */

select f.category_id,c.name,count(c.category_id)
from film_category f join  category c
on c.category_id = f.category_id
group by c.category_id
having count(c.category_id ) BETWEEN 55 AND 65
ORDER BY count(c.category_id);

select * from film;
select * from film_category;
select * from category;

select * from address;


/* 10. Create a stored procedure that creates a list of customers that have a rental_id, 
but no payment_id i.e. those customers who have not paid.
Store the names of customers who have not paid to a table named 'DelayedPayment'.
Store the names of customers and the payment amount who have paid to a table 
named 'OntimePayment'. */


create table onetimepayment (
name varchar(100),
amount dec(5,2));

create table delayedpayment(
name varchar(100),
amount dec(5,2));

Delimiter //

create Procedure pay()
Begin  

Declare finished integer Default 0;
Declare x int;

Declare cursor_pay
cursor for 
select distinct(c.customer_id) 
from customer c join rental r
on c.customer_id =r.customer_id;

DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;
        
open cursor_pay;
Getdata:loop
FETCH cursor_pay INTO x;
		IF finished = 1 THEN 
			LEAVE Getdata;
elseif
x in(select p.customer_id
from customer c join payment p
on c.customer_id = p.customer_id)
then
Insert into  onetimepayment(select concat(c.first_name,' ', last_name) ,p.amount
from customer c join payment p
on c.customer_id = p.customer_id
where p.customer_id = x);
else
insert into delayedpayment(select concat(c.first_name,' ', last_name) ,p.amount
from customer c join payment p
on c.customer_id = p.customer_id
where p.customer_id = x);

end if ;

end loop Getdata;
close cursor_pay;

end //

delimiter ;

call pay;

drop procedure pay;

select * from  onetimepayment;
select * from delayedpayment;

 
select * from customer;
select * from payment;
select * from rental;

/*11. Take film_text table from Sakila database, export data to CSV, 
write a load statement to load the data back into a new table.
Remove the extra spaces at the end of every line with an update statement. */

use sakila;

select * from film_text
INTO OUTFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\films'
FIELDS ENCLOSED BY '"' 
TERMINATED BY ';' 
ESCAPED BY '"' 
LINES TERMINATED BY '\r\n';

show variables like'secure_file_priv';


-------------------------------------------------
create table Tushar(
fiml_id smallint Primary key,
tite varchar(255),
description text );

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\films'
INTO TABLE Tushar 
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 0 ROWS;

drop table Tushar;
select * from Tushar;
