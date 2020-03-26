SELECT id, account_id, total_amt_usd
FROM orders
ORDER BY account_id, total_amt_usd DESC;

SELECT id,account_id,(standard_amt_usd/standard_qty)*100 AS std_paper, 
FROM orders
LIMIT 10;

SELECT name
FROM accounts
WHERE name  LIKE 'C%';
SELECT name
FROM accounts
WHERE name NOT LIKE 'C%';

SELECT name, primary_poc, sales_rep_id
FROM accounts
WHERE name IN ('Walmart', 'Target', 'Nordstrom');

WHERE column >= 6 AND column <= 10
WHERE column BETWEEN 6 AND 10

SELECT *
FROM orders
WHERE standard_qty > 1000 AND poster_qty = 0 AND gloss_qty = 0;

SELECT *
FROM orders
WHERE standard_qty = 0 AND (gloss_qty > 1000 OR poster_qty > 1000);

SELECT *
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%') 
           AND ((primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%') 
           AND primary_poc NOT LIKE '%eana%');
test1
SELECT a.primary_poc, w.occurred_at, w.channel, a.name
FROM web_events w
JOIN accounts a
ON w.account_id = a.id
WHERE a.name = 'Walmart';

SELECT r.name reg, s.name salna, a.name accnam
FROM region r
JOIN sales_reps s
ON r.id = s.region_id
JOIN accounts a
ON s.id=a.sales_rep_id
ORDER BY a.name;

SELECT r.name region, a.name account, 
       o.total_amt_usd/(o.total + 0.01) unit_price
FROM region r
JOIN sales_reps s
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id;

SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest'
ORDER BY a.name;

SELECT r.name region, s.name rep, a.name account
FROM sales_reps s
JOIN region r
ON s.region_id = r.id
JOIN accounts a
ON a.sales_rep_id = s.id
WHERE r.name = 'Midwest' AND s.name LIKE 'S%'
ORDER BY a.name;

SELECT o.occurred_at, a.name, o.total, o.total_amt_usd
FROM accounts a
JOIN orders o
ON o.account_id = a.id
WHERE o.occurred_at BETWEEN '01-01-2015' AND '01-01-2016'
ORDER BY o.occurred_at DESC;

SELECT AVG(standard_qty) mean_standard, AVG(gloss_qty) mean_gloss, 
           AVG(poster_qty) mean_poster, AVG(standard_amt_usd) mean_standard_usd, 
           AVG(gloss_amt_usd) mean_gloss_usd, AVG(poster_amt_usd) mean_poster_usd
FROM orders

SELECT MIN(occurred_at)
FROM web_events;
SELECT MAX(occurred_at)
FROM web_events;

SELECT w.channel, COUNT(*)
FROM web_events w
GROUP BY w.channel

SELECT a.name, MIN(total_amt_usd) smallest_order
FROM accounts a
JOIN orders o
ON a.id = o.account_id
GROUP BY a.name
ORDER BY smallest_order   ;

SELECT DISTINCT id, name
FROM sales_reps;

SELECT COUNT(*) rbh
FROM(SELECT s.name,COUNT(*) number
    FROM demo.sales_reps s
    JOIN demo.accounts a
    ON s.id=a.sales_rep_id
    GROUP BY 1
    HAVING COUNT(*)>=5
    ) ab;

SELECT DATE_TRUNC('day',occurred_at) AS day,
    SUM(o.total_amt_usd) totspent
    FROM demo.orders o
    JOIN demo.accounts a
    ON a.id=o.account_id
    GROUP BY DATE_TRUNC('day',occurred_at)
    ORDER BY DATE_TRUNC('day',occurred_at)
   ;

SELECT DATE_PART('month',occurred_at) AS time,
    COUNT(*) totspent
    FROM demo.orders 
    WHERE occurred_at BETWEEN '2014-01-01' AND '2016-12-31'
    GROUP BY 1
    ORDER BY 2 DESC
    LIMIT 150;

SELECT account_id, CASE WHEN standard_qty = 0 OR standard_qty IS NULL THEN 0
                        ELSE standard_amt_usd/standard_qty END AS unit_price
FROM orders
LIMIT 10;

SELECT s.name, COUNT(*), SUM(o.total_amt_usd) total_spent, 
     CASE WHEN COUNT(*) > 200 OR SUM(o.total_amt_usd) > 750000 THEN 'top'
     WHEN COUNT(*) > 150 OR SUM(o.total_amt_usd) > 500000 THEN 'middle'
     ELSE 'low' END AS sales_rep_level
FROM orders o
JOIN accounts a
ON o.account_id = a.id 
JOIN sales_reps s
ON s.id = a.sales_rep_id
GROUP BY s.name
ORDER BY 3 DESC;

'well formatted Query'
SELECT channel, AVG(event_count) AS afg_event_count
FROM(SELECT DATE_TRUNC('day',occurred_at) AS day,
            channel,COUNT(*) AS event_count
    FROM demo.web_events_full
    GROUP BY 1,2) sub
GROUP BY 1
ORDER BY 2 DESC;

SELECT AVG(standard_qty) avg_std, AVG(gloss_qty) avg_gls, AVG(poster_qty) avg_pst
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = 
     (SELECT DATE_TRUNC('month', MIN(occurred_at)) FROM orders);

SELECT SUM(total_amt_usd)
FROM orders
WHERE DATE_TRUNC('month', occurred_at) = 
      (SELECT DATE_TRUNC('month', MIN(occurred_at)) FROM orders);


/* subqueries 
*/
SELECT t3.rep_name, t3.region_name, t3.total_amt
FROM(SELECT region_name, MAX(total_amt) total_amt
     FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
             FROM demo.sales_reps s
             JOIN demo.accounts a
             ON a.sales_rep_id = s.id
             JOIN demo.orders o
             ON o.account_id = a.id
             JOIN demo.region r
             ON r.id = s.region_id
             GROUP BY 1, 2) t1
     GROUP BY 1) t2
JOIN (SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
     FROM demo.sales_reps s
     JOIN demo.accounts a
     ON a.sales_rep_id = s.id
     JOIN demo.orders o
     ON o.account_id = a.id
     JOIN demo.region r
     ON r.id = s.region_id
     GROUP BY 1,2
     ORDER BY 3 DESC) t3
ON t3.region_name = t2.region_name AND t3.total_amt = t2.total_amt;
/* subqueries */
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (
      SELECT MAX(total_amt)
      FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
              FROM sales_reps s
              JOIN accounts a
              ON a.sales_rep_id = s.id
              JOIN orders o
              ON o.account_id = a.id
              JOIN region r
              ON r.id = s.region_id
              GROUP BY r.name) sub);

SELECT a.name account_name
FROM demo.accounts a
JOIN demo.orders o
ON o.account_id = a.id
GROUP BY 1
HAVING SUM(o.total)>(
        SELECT total
        FROM(
            SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
            FROM demo.accounts a
            JOIN demo.orders o
            ON o.account_id = a.id
            GROUP BY 1
            ORDER BY 2 DESC
            LIMIT 1) sub );

/*QUESTION: You need to find the average number of events for each channel per day.
Let's try this again using a WITH statement.

Notice, you can pull the inner query:

SELECT DATE_TRUNC('day',occurred_at) AS day, 
       channel, COUNT(*) as events
FROM web_events 
GROUP BY 1,2
This is the part we put in the WITH statement. Notice, we are aliasing the table as events below:

WITH events AS (
          SELECT DATE_TRUNC('day',occurred_at) AS day, 
                        channel, COUNT(*) as events
          FROM web_events 
          GROUP BY 1,2)

*/
WITH events AS (
          SELECT DATE_TRUNC('day',occurred_at) AS day, 
                        channel, COUNT(*) as events
          FROM web_events 
          GROUP BY 1,2)

SELECT channel, AVG(events) AS average_events
FROM events
GROUP BY channel
ORDER BY 2 DESC;

WITH t1 AS (
  SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
   FROM sales_reps s
   JOIN accounts a
   ON a.sales_rep_id = s.id
   JOIN orders o
   ON o.account_id = a.id
   JOIN region r
   ON r.id = s.region_id
   GROUP BY 1,2
   ORDER BY 3 DESC), 
t2 AS (
   SELECT region_name, MAX(total_amt) total_amt
   FROM t1
   GROUP BY 1)

SELECT t1.rep_name, t1.region_name, t1.total_amt
FROM t1
JOIN t2
ON t1.region_name = t2.region_name AND t1.total_amt = t2.total_amt;

WITH t1 AS (
   SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
   FROM sales_reps s
   JOIN accounts a
   ON a.sales_rep_id = s.id
   JOIN orders o
   ON o.account_id = a.id
   JOIN region r
   ON r.id = s.region_id
   GROUP BY r.name), 
t2 AS (
   SELECT MAX(total_amt)
   FROM t1)
SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (SELECT * FROM t2);

/*LEFT & RIGHT Quizzes
In the accounts table, there is a column holding the website for each company. The last three digits specify what type of web address they are using. A list of extensions (and pricing) is provided here. Pull these extensions and provide how many of each website type exist in the accounts table.


There is much debate about how much the name (or even the first letter of a company name) matters. Use the accounts table to pull the first letter of each company name to see the distribution of company names that begin with each letter (or number).


Use the accounts table and a CASE statement to create two groups: one group of company names that start with a number and a second group of those company names that start with a letter. What proportion of company names start with a letter?


Consider vowels as a, e, i, o, and u. What proportion of company names start with a vowel, and what percent start with anything else?*/
SELECT RIGHT(website, 3) AS domain, COUNT(*) num_companies
FROM accounts
GROUP BY 1
ORDER BY 2 DESC;
/*There are 350 company names that start with a letter and 1 that starts with a number. This gives a ratio of 350/351 that are company names that start with a letter or 99.7%.
*/
SELECT SUM(num) nums, SUM(letter) letters
FROM (SELECT name, CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                       THEN 1 ELSE 0 END AS num, 
         CASE WHEN LEFT(UPPER(name), 1) IN ('0','1','2','3','4','5','6','7','8','9') 
                       THEN 0 ELSE 1 END AS letter
      FROM accounts) t1;


/*Quizzes POSITION & STRPOS
You will need to use what you have learned about LEFT & RIGHT, as well as what you know about POSITION or STRPOS to do the following quizzes.

Use the accounts table to create first and last name columns that hold the first and last names for the primary_poc.*/
SELECT /*first_name,last_name,*/primary_poc,
POSITION(' ' IN primary_poc) AS pos,
LEFT(primary_poc,STRPOS(primary_poc,' ')) AS first_name,
RIGHT(primary_poc,LENGTH(primary_poc)-STRPOS(primary_poc,' ')) AS Last_name
FROM demo.accounts

WITH sep AS (    SELECT name,
      LEFT(name,POSITION(' ' IN name)-1 ) AS first_name,
      RIGHT(name,LENGTH(name)-POSITION(' ' IN name) ) AS Last_name
      FROM demo.sales_reps)
      
SELECT sep.name,sep.first_name,sep.last_name,
CONCAT(sep.first_name,'_',sep.last_name) AS full_name
sep.first_name||'_'||sep.last_name AS full_name_sum
FROM sep
/*You may have noticed that in the previous solution some of the company names include spaces, which will certainly not work in an email address. See if you can create an email address that will work by removing all of the spaces in the account name, but otherwise your solution should be just as in question 1. Some helpful documentation is here.
*/
WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, CONCAT(first_name, '.', last_name, '@', REPLACE(name, ' ', ''), '.com')
FROM  t1;
/*We would also like to create an initial password, which they will change after their first log in. The first password will be the first letter of the primary_poc's first name (lowercase), then the last letter of their first name (lowercase), the first letter of their last name (lowercase), the last letter of their last name (lowercase), the number of letters in their first name, the number of letters in their last name, and then the name of the company they are working with, all capitalized with no spaces.*/
WITH t1 AS (
 SELECT LEFT(primary_poc,     STRPOS(primary_poc, ' ') -1 ) first_name,  RIGHT(primary_poc, LENGTH(primary_poc) - STRPOS(primary_poc, ' ')) last_name, name
 FROM accounts)
SELECT first_name, last_name, 
CONCAT(first_name, '.', last_name, '@', name, '.com') AS email, LEFT(LOWER(first_name), 1) || RIGHT(LOWER(first_name), 1) || LEFT(LOWER(last_name), 1) || RIGHT(LOWER(last_name), 1) || LENGTH(first_name) || LENGTH(last_name) || REPLACE(UPPER(name), ' ', '') AS pass_word
FROM t1;
/* substr(string, from [, count])	text	Extract substring (same as substring(string from from for count))	substr('alphabet', 3, 2)	ph */
SELECT date orig_date, (SUBSTR(date, 7, 4) || '-' || LEFT(date, 2) || '-' || SUBSTR(date, 4, 2)) new_date
FROM sf_crime_data;

FINAl TEST 
WITH s1 AS(
     SELECT c.CustomerId Customer ,c.FirstName FirstName, c.LastName LastName,c.Country 
     Country,  SUM(i.Total) AS TotalSpent
     FROM Invoice i
     JOIN Customer c
     ON i.CustomerId=c.CustomerId
     GROUP BY 1)
,
s2 AS (
     SELECT Country, MAX(TotalSpent) Max_TotalSpent
     FROM s1 
     GROUP BY 1) 

 SELECT s1.Customer, s1.FirstName, s1.LastName,s1.Country,s1.TotalSpent
 FROM s1
JOIN s2
ON s1.Country=s2.Country AND s1.TotalSpent=s2.Max_TotalSpent
ORDER BY 4




SELECT c.Email ,c.FirstName, c.LastName, G.Name
FROM Invoice i
JOIN Customer c
ON i.CustomerId=c.CustomerId
JOIN InvoiceLine il
ON i.InvoiceId=il.InvoiceId
JOIN Track t
ON il.TrackId =t.TrackId
JOIN Genre G
ON t.GenreId=G.GenreId
WHERE G.Name='Rock'
ORDER BY 1 ;

