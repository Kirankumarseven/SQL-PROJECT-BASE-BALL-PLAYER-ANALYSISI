-- PART I: SCHOOL ANALYSIS
-- 1. View the schools and school details tables
-- 2. In each decade, how many schools were there that produced players?
-- 3. What are the names of the top 5 schools that produced the most players?
-- 4. For each decade, what were the names of the top 3 schools that produced the most players?
use maven_advanced_sql;

-- SCHOOL ANALYSIS
-- 1. View the schools and school details tables
select * from schools;
select * from school_details;
select * from players;

-- 2. In each decade, how many schools were there that produced players?

select round(yearid,-1) as decade, count(distinct schoolID) as num_schools from schools
group by decade
order by decade;

-- 3. What are the names of the top 5 schools that produced the most players?
with cte_1 as (select  schoolid ,count(distinct playerid) as num_players from schools
				group by schoolid
				order by num_players desc limit 5)
                
select       cte_1.schoolid, sd.name_full,cte_1.num_players from cte_1
left join    school_details sd 
on           cte_1.schoolid = sd.schoolID;

-- without cte 


select sd.name_full, count(distinct playerID)as player_count  from schools s 
left join school_details sd 
on s.schoolid = sd.schoolid
group by s.schoolID
order by player_count desc limit 5;

-- 4. For each decade, what were the names of the top 3 schools that produced the most players?
with cte_1 as (select sd.name_full, round(s.yearid,-1) as decade, count(distinct s.playerID) as num_players  from schools s 
				left join school_details sd 
				on s.schoolid = sd.schoolid
				group by s.schoolid, decade
				order by decade),
cte_2 as (select name_full, decade,num_players,
row_number() over(partition by decade order by num_players desc)as row_num from  cte_1)

select decade, name_full, num_players from cte_2
where row_num <= 3
order by decade desc, row_num;


-- PART II: SALARY ANALYSIS
-- 1. View the salaries table
-- 2. Return the top 20% of teams in terms of average annual spending
-- 3. For each team, show the cumulative sum of spending over the years
-- 4. Return the first year that each team's cumulative spending surpassed 1 billion

-- 1. View the salaries table

select * from salaries;

-- 2. Return the top 20% of teams in terms of average annual spending

with cte_1 as  (select yearid, teamid, sum(salary) as spent from salaries
				group by teamid, yearid
				order by teamid, yearid),
	cte_2 as    (select teamid , avg(spent) as avg_spent,
					ntile(5) over(order by avg(spent) desc) as ranks from cte_1
					group by teamid)
select teamid, round(avg_spent /1000000,1) as milions from cte_2 where ranks = 1;


-- 3. For each team, show the cumulative sum of spending over the years

with cte_1 as (select yearid, teamid, sum(salary) as spent from salaries
				group by yearid, teamid 
				order by teamid, yearid)
select teamid, yearid, 
round(sum(spent) over(partition by teamid order by yearid)/1000000,1) as cum_sum from cte_1;


-- 4. Return the first year that each team's cumulative spending surpassed 1 billion

with cte_1 as (select * from (select yearid, teamid, sum(salary) as spent,
				sum(sum(salary)) over(partition by teamid order by yearid) as cum_sum
                from salaries
				group by yearid, teamid 
				order by teamid, yearid) as billion
                where cum_sum > 1000000000),
	cte_2 as (select *, row_number() over(partition by teamid order by cum_sum) as ranks from cte_1)

select yearid, teamid, round(cum_sum/ 1000000000,2) as billions from cte_2 where ranks = 1;


-- PART III: PLAYER CAREER ANALYSIS
-- 1. View the players table and find the number of players in the table
-- 2. For each player, calculate their age at their first game, their last game, and their career length (all in years). Sort from longest career to shortest career.
-- 3. What team did each player play on for their starting and ending years?
-- 4. How many players started and ended on the same team and also played for over a decade?

-- 1. View the players table and find the number of players in the table
select count(distinct playerID) as num_players from players;

-- 2.For each player, calculate their age at their first game, their last game, and their career length (all in years). 
-- Sort from longest career to shortest career.

with cte_1 as (select distinct playerID, date(concat(birthYear,'-',birthMonth,'-', birthDay)) as birth_day,
				namegiven, debut, finalgame from players),
                
	cte_2 as (select namegiven, TIMESTAMPDIFF( year ,birth_day, debut) as debut_age,
				TIMESTAMPDIFF(year, birth_day , finalgame) as finalgame_age
				from cte_1)
	select namegiven, debut_age, finalgame_age, (finalgame_age- debut_age) as career_length
    from   cte_2
    where   (finalgame_age- debut_age) is not null
    order by  career_length  desc;
    
    
-- 3. What team did each player play on for their starting and ending years?
select * from salaries;

with cte_1 as (
			select distinct playerid, namegiven, year(debut) debut, year(finalGame) final from players),
            
   cte_2 as (select cte_1.playerid,cte_1.namegiven,cte_1.debut, s.teamid ,cte_1.final, s2.teamid as finalteam from cte_1
			inner join salaries s 
			on cte_1.playerid = s.playerid and cte_1.debut = s.yearID
            inner join salaries s2 
            on cte_1.playerid = s2.playerid and cte_1.final = s2.yearID)

select * from cte_2
;

-- 4. How many players started and ended on the same team and also played for over a decade?


with cte_1 as (
			select distinct playerid, namegiven, year(debut) debut, year(finalGame) final from players),
            
   cte_2 as (select cte_1.playerid,cte_1.namegiven,cte_1.debut, s.teamid ,cte_1.final, s2.teamid as finalteam from cte_1
			left join salaries s 
			on cte_1.playerid = s.playerid and cte_1.debut = s.yearID
            left join salaries s2 
            on cte_1.playerid = s2.playerid and cte_1.final = s2.yearID)

select playerid, (final - debut)as decade, teamid, finalteam  from cte_2
where teamid = finalteam and (final - debut) >= 10;
;


-- 2.For each player, calculate their age at their first game, their last game, and their career length (all in years). 
-- Sort from longest career to shortest career.

select nameGiven, 
timestampdiff(year, cast(concat(birthyear,'-', birthmonth,'-', birthday) as date), debut) as debut_age,
timestampdiff(year, cast(concat(birthyear,'-', birthmonth,'-', birthday) as date), finalgame) as finalgame,
timestampdiff(year, cast(concat(birthyear,'-', birthmonth,'-', birthday) as date), finalgame) - 
timestampdiff(year, cast(concat(birthyear,'-', birthmonth,'-', birthday) as date), debut) as career_length
from players
order by career_length desc;

-- 3. What team did each player play on for their starting and ending years?


select  p.nameGiven, year(p.debut) starting_year, s.teamid, year(p.finalGame) as final_year,
	  s2.teamid from  players p
inner join salaries s
				on s.playerid = p.playerid and year(p.debut) = s.yearID
inner join salaries s2
				on s2.playerid = p.playerid and year(p.finalGame) = s2.yearID;


-- 4. How many players started and ended on the same team and also played for over a decade?

select  p.nameGiven, year(p.debut) starting_year, s.teamid, year(p.finalGame) as final_year,
	  s2.teamid as final_team from  players p
inner join salaries s
				on s.playerid = p.playerid and year(p.debut) = s.yearID
inner join salaries s2
				on s2.playerid = p.playerid and year(p.finalGame) = s2.yearID

where s.teamid =  s2.teamid and (year(p.finalGame) - year(p.debut)) > 10;


-- PART IV: PLAYER COMPARISON ANALYSIS
-- 1. View the players table
-- 2. Which players have the same birthday?
-- 3. Create a summary table that shows for each team, what percent of players bat right, left and both
-- 4. How have average height and weight at debut game changed over the years, and what's the decade-over-decade difference?

-- 1. View the players table

select * from players;

-- 2. Which players have the same birthday?

with cte_1 as (select playerid, namegiven, birthyear, birthmonth,birthday
					from players),
                    
	 cte_2 as (select cte_1.playerid, cte_1.nameGiven as name1,
				cast(concat(cte_1.birthyear,'-',cte_1.birthmonth,'-',cte_1.birthday) as Date) birthday_1, 
				cast(concat(p.birthyear,'-',p.birthmonth,'-',p.birthday) as Date) birthday_2, 
               p.nameGiven from cte_1
				inner join players p 
				on cte_1.birthyear = p.birthYear and
				  cte_1.birthMonth = p.birthMonth and 
				  cte_1.birthDay = p.birthDay and 
				  cte_1.playerid <> p.playerid)

select distinct name1, namegiven, birthday_1, birthday_2 from cte_2
where (year(birthday_1) between 1980 and 1990) and name1 > namegiven
order by birthday_1
; 

-- 3. Create a summary table that shows for each team, what percent of players bat right, left and both
with cte_1 as (select s.teamid, p.bats from players p 
				left join salaries s 
				on p.playerid = s.playerid),
cte_2 as (select teamid,
		sum(case when bats = 'R' then 1 end) as Right_hand,
		sum(case when bats = 'L' then 1 end) as Left_hand,
		sum(case when bats = 'B' then 1 end) as Both_ 
		from cte_1
		group by teamid)
        
select *, (right_hand/sum(Right_hand + Left_hand + Both_)*100) as pct_right,
		  (Left_hand/sum(Right_hand + Left_hand + Both_)*100) as pct_left,
          (Both_/sum(Right_hand + Left_hand + Both_)*100) as pct_both from cte_2
group by teamid
order by teamid
;


-- 4. How have average height and weight at debut game changed over the years, 
--  and what's the decade-over-decade difference?


select year(debut) debut_, avg(height), avg(weight), 
avg(height) - lag(avg(height),1,0) over(order by year(debut)) as diff_over_years,
avg(height) - lag(avg(height),9,0) over(order by year(debut)) as decade_diff_over_years
from players
group by debut_;

-- 2. Which players have the same birthday?

with cte_1 as (select cast(concat(birthyear,'-',birthmonth,'-',birthday) as date) as birthdate,
namegiven
 from players)
 
select birthdate, group_concat(namegiven separator ', ') as same_birth_days from cte_1
where  year(birthdate)  between 1980 and 1990
group by birthdate
order by birthdate
;


-- 3. Create a summary table that shows for each team, what percent of players bat right, left and both

select 	s.teamid, count(s.playerid) num_players, 
        round(sum(case when p.bats = 'R' then 1 else 0 end)/count(s.playerid) *100,1)  as bats_right,
        round(sum(case when p.bats = 'L' then 1 else 0 end)/count(s.playerid)*100,1)   as bats_left,
        round(sum(case when p.bats = 'B' then 1 else 0 end)/count(s.playerid) *100,1)  as bats_both
from 	salaries s left join players p 
		on s.playerid = p.playerid 
        group by s.teamid;
        


-- 4. How have average height and weight at debut game changed over the years, 
--  and what's the decade-over-decade difference?

select floor(year(debut)/10)*10 as decade,
avg(height) - lag(avg(height),1,0) over(order by floor(year(debut)/10)*10 ) as height_diff,
avg(weight) - lag(avg(weight),1,0) over(order by floor(year(debut)/10)*10 ) as weight_diff
from players
group by decade
having decade is not null
order by decade
;