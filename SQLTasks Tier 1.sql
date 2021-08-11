/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name 
FROM `Facilities` 
WHERE membercost >0


/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT(*) 
FROM `Facilities` 
WHERE membercost = 0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT
	facid, name, membercost, monthlymaintenance

FROM `Facilities` 
WHERE membercost <> 0 AND membercost < 0.2*monthlymaintenance


/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * 
FROM `Facilities` 
WHERE facid IN (1,5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT 
	name, monthlymaintenance, 
	(CASE WHEN monthlymaintenance > 100 THEN 'expensive'
		ELSE 'cheap' END ) AS type

FROM `Facilities` 


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT 
	firstname, surname 

FROM Members 
WHERE joindate = 
	(SELECT MAX(joindate)
     FROM Members)

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT
	name AS Facility, Member_name

FROM
(
  ( SELECT 
   DISTINCT memid, facid 
    
    FROM Bookings
    WHERE facid IN (0,1) AND memid <> 0
	) AS tennis_bookings 

INNER JOIN Facilities as f1
ON tennis_bookings.facid = f1.facid

INNER JOIN (
    SELECT memid, CONCAT(firstname, " ", surname) AS Member_Name
    FROM Members
    WHERE memid <> 0
	) as m1
ON tennis_bookings.memid = m1.memid

) 

ORDER BY Member_name, name


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT 
	f1.name AS Facility,
	(CASE WHEN b1.memid <> 0 THEN CONCAT(m1.firstname," ", m1.surname) 
         ELSE m1.surname END) AS Member_name,
	(CASE WHEN b1.memid <> 0 THEN b1.slots*f1.membercost 
         ELSE b1.slots*guestcost END) AS booking_cost

FROM Bookings as b1
INNER JOIN Facilities as f1
ON b1.facid = f1.facid
INNER JOIN Members as m1 
ON b1.memid = m1.memid

WHERE b1.starttime LIKE '2012-09-14%'
ORDER BY booking_cost DESC
LIMIT 12


/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT
	Facility, Member_name, booking_cost

FROM
(
SELECT 
	f1.name AS Facility,
	(CASE WHEN b1.memid <> 0 THEN CONCAT(m1.firstname," ", m1.surname) 
         ELSE m1.surname END) AS Member_name,
	(CASE WHEN b1.memid <> 0 THEN b1.slots*f1.membercost 
         ELSE b1.slots*guestcost END) AS booking_cost

FROM Bookings as b1
INNER JOIN Facilities as f1
ON b1.facid = f1.facid
INNER JOIN Members as m1 
ON b1.memid = m1.memid

WHERE b1.starttime LIKE '2012-09-14%'
) AS revenue_2012_09_14

WHERE booking_cost > 30
ORDER BY booking_cost DESC


/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

    query1 = "\
    SELECT Facility, Total_Revenue \
    FROM (\
            SELECT name as Facility, Sum(Cost) as Total_Revenue \
            FROM (\
                SELECT\
                    b1.bookid, b1.facid, f1.name, \
                    (CASE WHEN memid = 0 THEN b1.slots*f1.guestcost \
                    ELSE b1.slots*f1.membercost END) AS cost \
                FROM Bookings AS b1 \
                INNER JOIN Facilities as f1 \
                ON b1.facid = f1.facid \
                ) AS bookings_cost \
          GROUP BY name \
          ) AS Rev_by_facility \
    WHERE Total_Revenue < 1000 \
    ORDER BY Total_Revenue DESC"
    
/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

    query1 = "\
    SELECT surname, firstname, m2.Full_Name AS Recommended_By \
    FROM Members \
    LEFT JOIN \
            ( \
            SELECT \
            memid, \
            (CASE WHEN memid <> 0 THEN firstname || ' ' || surname \
            ELSE ' ' END) AS Full_Name \
            FROM Members \
            ) AS m2 \
    ON Members.recommendedby = m2.memid \
    WHERE Members.memid <> 0 \
    ORDER BY surname, firstname"
    

/* Q12: Find the facilities with their usage by member, but not guests */

    query1 = "\
    SELECT Facility, Member_name \
    FROM \
    (\
        SELECT \
        DISTINCT b1.facid ||'_'||b1.memid as Fac_Mem, \
        f1.name AS Facility, \
        m1.firstname||' '||m1.surname AS Member_name, \
        m1.memid \
        FROM Bookings as b1 \
        INNER JOIN Facilities as f1 \
        ON b1.facid = f1.facid \
        INNER JOIN Members as m1 \
        ON b1.memid = m1.memid \
        WHERE b1.memid <> 0 \
        ) As Facility_usage \
    ORDER BY Facility, Member_name"



/* Q13: Find the facilities usage by month, but not guests */

    query1 = """ 
        SELECT f1.facid AS Facility_ID, 
                f1.name AS Facility_Name, 
                strftime('%m', b1.starttime) AS month, 
                SUM(b1.slots) AS slots_used_by_members 
        FROM Bookings AS b1 
        INNER JOIN Facilities AS f1 
        ON b1.facid = f1.facid 
        WHERE b1.memid != 0 
        GROUP BY Facility_ID, month
        """

