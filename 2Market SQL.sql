--insert ad_data table
/*CREATE TABLE ad_data (
	ID BIGSERIAL PRIMARY KEY,
	Bulkmail_ad INTEGER,
	Twitter_ad INTEGER,
	Instagram_ad INTEGER,
	Facebook_ad INTEGER,
	Brochure_ad INTEGER)
	*/
	
--insert data from csv file
/*COPY ad_data
FROM 'C:\Users\fwarn\OneDrive\Documents\LSE Data Analytics\LSE_DA101_Assignment_data\ad_data.csv'
DELIMITER ','
CSV Header
*/

--check table
--SELECT*FROM ad_data

--create table for marketing_data
/*CREATE TABLE marketing_data(
	ID BIGSERIAL PRIMARY KEY,
	Year_Birth INTEGER,
	Education VARCHAR(20),
	Marital_Status CHAR(20),
	Income INTEGER,
	Kidhome INTEGER,
	Teenhome INTEGER,
	Dt_Customer DATE,
	Recency INTEGER,
	AmtLiq INTEGER,
	AmtVege INTEGER,
	AmtNonVeg INTEGER,
	AmtPes INTEGER,
	AmtChocolates INTEGER,
	AmtComm INTEGER,
	NumDeals INTEGER,
	NumWebBuy INTEGER,
	NumWalkinPur INTEGER,
	NumVisits INTEGER,
	Response INTEGER,
	Complain INTEGER,
	Country CHARACTER(5),
	Count_success INTEGER,
	Age INTEGER
	)
	*/
--amend income type as inputed incorrectly (it has decimals so can't be an integer)
/*ALTER TABLE marketing_data
ALTER COLUMN Income type NUMERIC(9,2)
*/

--insert marketing_data_clean csv fil
/*COPY marketing_data
FROM 'C:\Users\fwarn\OneDrive\Documents\LSE Data Analytics\LSE_DA101_Assignment_data\marketing_data_clean.csv'
DELIMITER ','
CSV Header
*/
--total spend per country
SELECT*FROM marketing_data

--total spend per country
SELECT country,
SUM(amtliq+amtvege+amtnonveg+amtpes+amtchocolates+amtcomm) AS total_spend
FROM marketing_data
GROUP BY country
ORDER BY total_spend DESC

---country by category
SELECT country,
SUM(amtliq) AS total_liq,
SUM(amtvege) AS total_veg,
SUM (amtnonveg) AS total_non_veg,
SUM(amtpes) AS total_pes,
SUM(amtchocolates) AS total_choc,
SUM(amtcomm) AS total_comm
FROM marketing_data
GROUP BY country
ORDER BY country
---view in graph visualiser, this shows liquids are the most poopular category in every country

--this shows the highest selling product per country by price
SELECT country,total_liq, total_veg, total_non_veg,total_pes,total_choc,total_comm,
CASE GREATEST(total_liq, total_veg, total_non_veg,total_pes,total_choc,total_comm)
WHEN total_liq THEN 'Liquor' 
WHEN total_veg THEN 'Veg'
WHEN total_non_veg THEN 'Non-Veg'
WHEN total_pes THEN 'Pes'
WHEN total_choc THEN 'Choc'
WHEN total_comm THEN 'Comm'
ELSE NULL
END AS highest_selling_category
FROM (SELECT country,
SUM(amtliq) AS total_liq,
SUM(amtvege) AS total_veg,
SUM (amtnonveg) AS total_non_veg,
SUM(amtpes) AS total_pes,
SUM(amtchocolates) AS total_choc,
SUM(amtcomm) AS total_comm
FROM marketing_data
	 GROUP BY country
	 ORDER BY country)


---products by marital status
SELECT marital_status,
SUM(amtliq) AS total_liq,
SUM(amtvege) AS total_veg,
SUM (amtnonveg) AS total_non_veg,
SUM(amtpes) AS total_pes,
SUM(amtchocolates) AS total_choc,
SUM(amtcomm) AS total_comm
FROM marketing_data
GROUP BY marital_status
ORDER BY marital_status
--liquids are most popular again here

--products based on kids/teens at home
SELECT
(kidhome + teenhome) AS childrenhome,
SUM(amtliq) AS total_liq,
SUM(amtvege) AS total_veg,
SUM (amtnonveg) AS total_non_veg,
SUM(amtpes) AS total_pes,
SUM(amtchocolates) AS total_choc,
SUM(amtcomm) AS total_comm
FROM marketing_data
GROUP BY childrenhome
ORDER BY childrenhome
--people absolutely love liquor


CREATE VIEW twomarketjoin AS (
SELECT * FROM marketing_data
LEFT JOIN ad_data USING(id)
ORDER BY id )

SELECT * FROM twomarketjoin

SELECT country,
sum(twitter_ad) AS twittersum,
sum(instagram_ad)AS instasum,
sum(facebook_ad) AS facebooksum
FROM twomarketjoin
GROUP BY country

--Which social media platform  is the most effective method of advertising in each country? 
CREATE VIEW ad_summary_country AS (
SELECT country, twittersum, instasum,facebooksum,
CASE GREATEST(twittersum, instasum,facebooksum)
WHEN twittersum THEN 'Twitter' 
WHEN instasum THEN 'Instagram'
WHEN facebooksum THEN 'Facebook'
ELSE NULL
END AS best_marketing
FROM (SELECT country,
sum(twitter_ad) AS twittersum,
sum(instagram_ad)AS instasum,
sum(facebook_ad) AS facebooksum
FROM twomarketjoin
	 GROUP BY country
	 ORDER BY country)
)
--Which social media platform is the most effective method of advertising based on marital status?
SELECT marital_status, twittersum, instasum,facebooksum,
CASE GREATEST(twittersum, instasum,facebooksum)
WHEN twittersum THEN 'Twitter' 
WHEN instasum THEN 'Instagram'
WHEN facebooksum THEN 'Facebook'
ELSE NULL
END AS best_marketing
FROM (SELECT marital_status,
sum(twitter_ad) AS twittersum,
sum(instagram_ad)AS instasum,
sum(facebook_ad) AS facebooksum
FROM twomarketjoin
	 GROUP BY marital_status
	 ORDER BY marital_status)
	 

--Which social media platform(s) seem(s) to be the most effective per country? 
--(In this case, assume that purchases were in some way influenced by lead conversions from a campaign).
CREATE VIEW total_sales_country AS (
SELECT country,total_liq, total_veg, total_non_veg,total_pes,total_choc,total_comm,
CASE GREATEST(total_liq, total_veg, total_non_veg,total_pes,total_choc,total_comm)
WHEN total_liq THEN 'Liquor' 
WHEN total_veg THEN 'Veg'
WHEN total_non_veg THEN 'Non-Veg'
WHEN total_pes THEN 'Pes'
WHEN total_choc THEN 'Choc'
WHEN total_comm THEN 'Comm'
ELSE NULL
END AS highest_selling_category
FROM (SELECT country,
SUM(amtliq) AS total_liq,
SUM(amtvege) AS total_veg,
SUM (amtnonveg) AS total_non_veg,
SUM(amtpes) AS total_pes,
SUM(amtchocolates) AS total_choc,
SUM(amtcomm) AS total_comm
FROM marketing_data
	 GROUP BY country
	 ORDER BY country)
	)

SELECT *FROM
total_sales_country
JOIN
ad_summary_country
USING (country)
ORDER BY best_marketing

