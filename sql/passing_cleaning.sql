/*

	Passing Cleaning Steps

*/

----------------------------------------------------------------------------------------------------------------------------------------
/*
	STEP 1: COPY RAW DATA
*/

-- a. Copy Raw Data Table to New Table

SELECT 
	*
INTO 
	NFL.dbo.passing_staging
FROM
	NFL.dbo.passing


-- b. Inspect Results

SELECT
	*
FROM
	NFL.dbo.passing_staging


----------------------------------------------------------------------------------------------------------------------------------------
/*
	STEP 2: DUPLICATE CHECK
*/

-- a. Identify Duplicates --

-- Will be using a CTE and ROW NUMBER window function to search for duplicates

WITH dupchk AS(
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY 
									Player,
									Team,
									Yds,
									Year
							ORDER BY 
								Yds) row_num
	FROM 
		NFL.dbo.passing_staging
)
SELECT 
	*
FROM 
	dupchk
WHERE 
	row_num > 1 
ORDER BY 
	Year

-- 0 Duplicates found

/*
-- b. Delete Duplicates --

WITH dupchk AS(
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY 
									Player,
									Team,
									Yds,
									Year
							ORDER BY 
								Yds) row_num
	FROM 
		passing_staging
)
DELETE 
FROM 
	dupchk
WHERE 
	row_num > 1

-- No duplicates found but here's how to delete if there were
*/


----------------------------------------------------------------------------------------------------------------------------------------
/*

	STEP 3: REMOVE HEADER ROW AND SUMMARY ROW

*/

-- a. Identify How Many Header Rows/Summary Rows Are Present --

-- Upon examination, I noticed that the header row got into the table
-- Since the Header Row made it way, it's safe to assume the Summary Row also got in

SELECT 
	*
FROM 
	NFL.dbo.passing_staging
WHERE 
	Rk = 'Rk'
	OR Player = 'League Average'
ORDER By 
	Year

-- Resulted in 33 header rows & 3 summary rows


-- b. Remove Header Rows --

/*
- Now we will remove the header rows from the table
- Important to do this before standardization or we're going to get an error
*/

DELETE
FROM 
	NFL.dbo.passing_staging
WHERE 
	Rk = 'Rk'
	OR Player = 'League Average'

-- Results should say 36 rows affected


-- c. Inspect Results --

-- Double check if header rows were removed by re-running snippet in part a


----------------------------------------------------------------------------------------------------------------------------------------
/*
	STEP 4: INCONSISTENT VALUES
*/ 

/*
- Going to use Dynamic SQL to search through all the columns for inconsistent 
data types and update them to one single data type 
- Want to address this before standardization to avoid errors
*/

-- a. Identify Columns with Inconsistent Values --

-- Dynamic SQL for Integer Columns

DECLARE @INT_check NVARCHAR(MAX) = '';

SELECT @INT_check +=
    'SELECT ' + COLUMN_NAME + 
    ' FROM NFL.dbo.passing_staging ' +
    'WHERE ' + COLUMN_NAME + ' LIKE ' + '''%.%'''  
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_NAME = 'passing_staging'
    AND (DATA_TYPE = 'nvarchar' OR DATA_TYPE = 'int' OR DATA_TYPE = 'decimals')
	AND COLUMN_NAME IN ('Rk', 'Age', 'G', 'GS', 'Cmp', 'Att', 'Yds', 'TD', 'Int', 
                       'Lng', 'Sk', 'Yds_1', '_4QC', 'GWD', '_1D'); 
EXEC (@INT_check);

/*
- These columns should all be integers (2125, 560)
- Resulted in 3 columns having a mix of Integers and Decimals --> Should only have Integers in these columns
*/

-- Dynamic SQL for Decimal Columns

DECLARE @DEC_check NVARCHAR(MAX) = '';

SELECT @DEC_check +=
	'SELECT ' + COLUMN_NAME + 
	' FROM NFL.dbo.passing_staging  ' +
	'WHERE ' + COLUMN_NAME + ' NOT LIKE ' + '''%.%'''  
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_NAME = 'passing_staging'
    AND (DATA_TYPE = 'nvarchar' OR DATA_TYPE = 'int' OR DATA_TYPE = 'decimal')
	AND COLUMN_NAME IN ('Cmp1', 'TD1', 'Int1', 'Y_A', 'AY_A', 'Y_C', 'Y_G', 
                        'Rate', 'Sk1', 'NY_A', 'ANY_A', 'Succ', 'QBR');
EXEC (@DEC_check);

-- These columns should all be decimals (216.0, 45.5)
-- No results

/*
- Only 3 columns have a mix of Decimals and Integers: Lng, Sk, Yds_1
- These 3 columns should only have Integers so we will update them
*/


-- b. Update Inconsistent Values --

DECLARE @ToINT NVARCHAR(MAX) = '';

SELECT @ToINT +=
	'UPDATE NFL.dbo.passing_staging 
	SET ' + COLUMN_NAME + ' = CAST(CAST(' + COLUMN_NAME + ' AS DECIMAL(10, 1)) AS INT);'
FROM
	INFORMATION_SCHEMA.COLUMNS
WHERE 
	TABLE_NAME = 'passing_staging' 
    AND (DATA_TYPE = 'nvarchar' OR DATA_TYPE = 'int' OR DATA_TYPE = 'decimal')
	AND COLUMN_NAME IN ('Lng', 'Sk', 'Yds_1');

EXEC (@ToINT)


-- c. Inspect Results 

-- Double check your results by re-running snippet in part a
-- All the columns should have consistent values across all columns


----------------------------------------------------------------------------------------------------------------------------------------
/*
	STEP 5: STANDARDIZATION
*/


-- a. Identify Columns for Standardization --


-- We already know that all the columns but the 'Year' column are type nvarchar, aw we changed them to this format when we uploaded our data
-- Here is how to check again:

EXEC sp_columns passing_staging

/* 
- All but one column are data type nvarchar, meaning they are all in string format. 
- We need to update the columns to either Intger (int) or Decimal (decimal) format
*/


-- b. Standardize Columns --


DECLARE @standardization NVARCHAR(MAX) = '';

-- INTEGER Columns
SELECT @Standardization +=
    'ALTER TABLE NFL.dbo.passing_staging 
	ALTER COLUMN ' + COLUMN_NAME + ' INT; ' + 
    'UPDATE passing_staging 
	SET ' + COLUMN_NAME + ' = CAST(CAST(' + COLUMN_NAME + ' AS DECIMAL(10, 1)) AS INT);'
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE 
    TABLE_NAME = 'passing_staging' 
    AND (DATA_TYPE = 'nvarchar' OR DATA_TYPE = 'int')
    AND COLUMN_NAME IN ('Rk', 'Age', 'G', 'GS', 'Cmp', 'Att', 'Yds', 'TD', 'Int', 'Lng', 
                        'Sk', 'Yds_1', '_4QC', 'GWD', '_1D');

-- DECIMAL Columns
SELECT @standardization +=
    'ALTER TABLE NFL.dbo.passing_staging 
	ALTER COLUMN ' + COLUMN_NAME + ' DECIMAL(10,2); ' + 
    'UPDATE passing_staging 
	SET ' + COLUMN_NAME + ' = CAST(' + COLUMN_NAME + ' AS DECIMAL(10,2));'
FROM
    INFORMATION_SCHEMA.COLUMNS
WHERE
    TABLE_NAME = 'passing_staging'
    AND (DATA_TYPE = 'nvarchar' OR DATA_TYPE = 'decimal')
    AND COLUMN_NAME IN ('Cmp1', 'TD1', 'Int1', 'Y_A', 'AY_A', 'Y_C', 'Y_G', 
                        'Rate', 'Sk1', 'NY_A', 'ANY_A', 'Succ', 'QBR');

EXEC(@standardization);


-- c. Inspect Results --

/*
- Double check your results by re-running snippet in part a
- Each column should have their correct data type
*/


----------------------------------------------------------------------------------------------------------------------------------------
/*
	STEP 6: REMOVE NON-QB ENTRIES
*/

-- REMOVE NON-QUARTERBACK ROWS --


-- a. Identify Rows that are not Quaterbacks (Passers) --

-- This table contains data for anyone who made a pass attempt so will see data for non-quaterbacks
-- For this dataset, we only want data for quarterbacks

SELECT
	*
FROM 
	NFL.dbo.passing_staging
WHERE
	Pos != 'QB'

-- Result: 1574 rows

-- Now that we have identified the rows, we can delete them 


-- b. Remove Non-Quarterback Rows --

DELETE
FROM
	NFL.dbo.passing_staging
WHERE
	Pos != 'QB' 


-- c. Inspect Results --

-- Double check your results by re-running snippet in part a


----------------------------------------------------------------------------------------------------------------------------------------
/*
	STEP 7: TRADED PLAYERS STATS
*/

-- a. Search 2TM Players (Traded Players)

SELECT
	Player,
	Team,
	Year
FROM
	NFL.dbo.passing_staging
WHERE
	Team = '2TM'

-- Found 31 rows of Players who were traded during the season
-- This means they have multiple stats/rows for a single year


-- b. Query Traded Players Stats for Each Year

WITH traded_count AS (
	SELECT
		*
		, ROW_NUMBER () OVER(PARTITION BY Player, Year ORDER BY Team, Year) as row_num
		, COUNT(*) OVER(PARTITION BY Player, Year) as entry_count
	FROM
		NFL.dbo.passing_staging
)
SELECT
	Player,
	Team,
	Year,
	row_num, 
	entry_count
FROM
	traded_count
WHERE
	entry_count > 1
ORDER BY
	Year DESC

 -- Found that some QBs had 3 entries for a given, as predicted but some had 2.
-- The Qb's with only 2 most likely means that they didn't play for one of their teams so that have no stats


-- c. Remove Individual Team Stats for Traded Passers

WITH traded_count AS (
    SELECT 
        Player, 
        Team, 
        Year, 
        COUNT(*) OVER (PARTITION BY Player, Year) AS entry_count
    FROM 
		NFL.dbo.passing_staging
)
DELETE 
	ps
FROM 
	NFL.dbo.passing_staging ps
JOIN traded_count tc
    ON ps.Player = tc.Player 
	AND ps.Year = tc.Year
WHERE 
	tc.entry_count > 1 
	AND ps.Team <> '2TM';

-- 56 rows deleted
 
-- d. Inspect Results

-- Re-run script from part b to see if the passer stats for the different teams were deleted
-- For this table, we only want the combined passer stats where Team = '2TM'


----------------------------------------------------------------------------------------------------------------------------------------
/*
	STEP 8: SPLIT QBrec COLUMN
*/

-- a. Add New Columns for Wins, Losses, & Ties --

ALTER TABLE 
	passing_staging
ADD 
	Wins INT,
	Losses INT,
	Ties INT


-- b. Extract Values from QBRec Column --

UPDATE 
	passing_staging
SET 
	Wins = CAST(SUBSTRING(QBRec, 
							1, 
							CHARINDEX('-', QBRec) - 1)
				AS INT),
	Losses = CAST(SUBSTRING(QBRec, 
							CHARINDEX('-', QBRec) + 1, 
							CHARINDEX('-', QBRec, CHARINDEX('-', QBRec) + 1) - CHARINDEX('-', QBRec) - 1) AS INT),
	Ties = CAST(SUBSTRING(QBRec, 
							CHARINDEX('-', QBRec, CHARINDEX('-', QBRec) + 1) + 1, 
							LEN(QBRec) - CHARINDEX('-', QBRec, CHARINDEX('-', QBRec) + 1)) AS INT);


-- c. Inspect Results --

SELECT
	*
FROM
	passing_staging


----------------------------------------------------------------------------------------------------------------------------------------
/*
	STEP 9: NULL VALUES
*/

-- a. Identify NULL Values --

-- COUNT the entries of NULL Values 

DECLARE @null_count_per_year NVARCHAR(MAX) = '';

SELECT @null_count_per_year += 
	'SELECT Year, ''' + COLUMN_NAME + ''' AS NULLCol, 
	COUNT(*) AS NULL_count 
	FROM passing_staging 
	WHERE ' + COLUMN_NAME + ' IS NULL 
	GROUP BY ' + COLUMN_NAME + ', Year UNION ALL '
FROM
	INFORMATION_SCHEMA.COLUMNS
WHERE
	TABLE_NAME = 'passing_staging'
	AND (DATA_TYPE = 'int' OR DATA_TYPE = 'decimal' or DATA_TYPE = 'nvarchar')
	AND COLUMN_NAME IN ('Player', 'Team', 'Pos', 'Rk', 'Age', 'G', 'GS', 'Cmp', 'Att', 'Yds', 'TD', 'Int', 'Lng', 
                        'Sk', 'Yds_1', '_4QC', 'GWD', '_1D', 'Cmp1', 'TD1', 'Int1', 'Y_A', 'AY_A', 'Y_C',
						'Y_G', 'Rate', 'Sk1', 'NY_A', 'ANY_A', 'Succ', 'QBR', 'Wins', 'Losses', 'Ties')
SET @null_count_per_year = LEFT(@null_count_per_year, LEN(@null_count_per_year) - LEN(' UNION ALL '));

SET @null_count_per_year = @null_count_per_year + ' ORDER BY Year DESC, NULL_count DESC; '

EXEC (@null_count_per_year);

-- This will let us look at all the NULLS for each year to see if there are any columns with an irregular amount of NULLS


-- b. Replace All NULLs with 0s --

DECLARE @transform_null NVARCHAR(MAX) = '';

SELECT @transform_null += 
	'UPDATE 
		passing_staging
	SET ' + 
		COLUMN_NAME + ' = CASE 
			WHEN ' + COLUMN_NAME + ' IS NULL THEN 0
			ELSE ' + COLUMN_NAME + 
		' END;'
FROM
	INFORMATION_SCHEMA.COLUMNS
WHERE
	TABLE_NAME = 'passing_staging'
	AND (DATA_TYPE = 'int' OR DATA_TYPE = 'decimal' or DATA_TYPE = 'nvarchar')
	AND COLUMN_NAME IN ('G', 'GS', 'Cmp', 'Att', 'Yds', 'TD', 'Int', 'Lng', 
                        'Sk', 'Yds_1', '_4QC', 'GWD', '_1D', 'Cmp1', 'TD1', 'Int1', 'Y_A', 'AY_A', 'Y_C',
						'Y_G', 'Rate', 'Sk1', 'NY_A', 'ANY_A', 'Succ', 'QBR', 'Wins', 'Losses', 'Ties')

PRINT @transform_null

EXEC (@transform_null)

-- 3164 rows affected
-- Should be no more NULL Values in the table


-- c. Inspect Results --

-- Re-run script from part a to see if there are still NULLS


----------------------------------------------------------------------------------------------------------------------------------------
/*
	STEP 10: DROP COLUMNS
*/

-- a. Drop Columns --

-- Going to drop all are unnecessary columns

ALTER TABLE
	NFL.dbo.passing_staging
DROP COLUMN
	Rk
	, QBrec
	, Awards


-- b. Inspect Results --

SELECT 
	*
FROM 
	NFL.dbo.passing_staging
ORDER BY 
	Year DESC, Yds DESC 


----------------------------------------------------------------------------------------------------------------------------------------
/*
	STEP 11: ADD NEW RANK COLUMN
*/

-- a. Add Rank Column to table --

-- Old Rank column became unfunctionable since we deleted non QB data so let's make a new one

ALTER TABLE 
	NFL.dbo.passing_staging
ADD 
	Rank Int;


-- b. Rank QBs by Passing Yards --

WITH RankedPassers AS (
    SELECT 
        Player, 
        Yds, 
        Year, 
        ROW_NUMBER() OVER (PARTITION BY Year ORDER BY Yds DESC) AS rnk
    FROM 
        NFL.dbo.passing_staging
)
UPDATE 
	c
SET 
	Rank = rnk
FROM 
	NFL.dbo.passing_staging c
JOIN 
	RankedPassers r
ON 
	c.Player = r.Player
    AND c.Yds = r.Yds
    AND c.Year = r.Year;


-- c. Check Results --

SELECT 
	*
FROM 
	NFL.dbo.passing_staging
ORDER BY 
	Year DESC, Yds DESC 


----------------------------------------------------------------------------------------------------------------------------------------
/*
	STEP 12: VALIDATE EMPTY ROWS
*/

-- a. Inspect Known Empty Rows --

/*
- 3 columns (QBR, Succ, _1D) should be empty as data collection didn't start till a certain year
	- QBR: 2006
	- Succ & _1D: 1994
- These 3 should be empty/0 before the specifies year
*/

SELECT
	Player, 
	Year,
	QBR, 
	Succ, 
	_1D
FROM
	passing_staging
WHERE
	QBR > 0
	AND (YEAR < 1994 OR YEAR < 2006)
ORDER BY 
	YEAR DESC

-- QBR had 2 rows with values in 2003
-- Need to replace with 0


-- b. Update QBR Values --

UPDATE 
	passing_staging
SET 
	QBR = 0
WHERE 
	YEAR = 2003
	AND QBR != 0


-- c. Inspect Results --

SELECT
	*
FROM
	passing_staging
WHERE
	Year = 2003
	AND QBR != 0


----------------------------------------------------------------------------------------------------------------------------------------
/*
	STEP 13: CHANGE TEAM ABBREVIATIONS

- The website from where data came from uses different team abbreviation then what the NFL uses

*/

-- a. Query All Team Abbreviations --

SELECT 
	DISTINCT Team
FROM
	NFL.dbo.passing_staging


-- b. Update Team Abbreviations

UPDATE 
	NFL.dbo.passing_staging
SET 
	Team = CASE
		WHEN Team = 'KAN' THEN 'KC'
		WHEN Team = 'SFO' THEN 'SF'
		WHEN Team = 'SDG' THEN 'SD'
		WHEN Team = 'NWE' THEN 'NE'
		WHEN Team = 'LVR' THEN 'LV'
		WHEN Team = 'GNB' THEN 'GB'
		WHEN Team = 'NOR' THEN 'NO'
		WHEN Team = 'TAM' THEN 'TB'
		WHEN Team = 'RAM' THEN 'LAR'
		ELSE Team
	END;


-- c. Inspect Results

-- Re-run part a to see if the Team names were changed


----------------------------------------------------------------------------------------------------------------------------------------
/* 
	STEP 14: RENAME COLUMNS

-There are columns that have shortend & confusing names and thus will be confusing for the viewer so they will be updated
to be more descriptive and

*/

-- a. Method 1 --

sp_rename 'pass_staging.G', 'Games_Played', 'COLUMN';
sp_rename 'pass_staging.GS', 'Games_Started', 'COLUMN';
sp_rename 'pass_staging.Cmp', 'Completions', 'COLUMN';
sp_rename 'pass_staging.Att', 'Passing_Attempts', 'COLUMN';
sp_rename 'pass_staging.Cmp1', 'Completion_Percentage', 'COLUMN';
sp_rename 'pass_staging.Yds', 'Passing_Yards', 'COLUMN';
sp_rename 'pass_staging.TD1', 'TD_Percentage', 'COLUMN';
sp_rename 'pass_staging.Int', 'Interceptions', 'COLUMN';
sp_rename 'pass_staging.Int1', 'Interception_Percentage', 'COLUMN';
sp_rename 'pass_staging.Lng', 'Longest_Pass', 'COLUMN';
sp_rename 'pass_staging.Y_A', 'Yards_Per_Attempt', 'COLUMN';
sp_rename 'pass_staging.AY_A', 'Average_Yards_Per_Attempt', 'COLUMN';
sp_rename 'pass_staging.Y_C', 'Yards_Per_Completion', 'COLUMN';
sp_rename 'pass_staging.Y_G', 'Yards_Per_Game', 'COLUMN';
sp_rename 'pass_staging.Rate', 'Passer_Rating', 'COLUMN';
sp_rename 'pass_staging.Sk', 'Sacks', 'COLUMN';
sp_rename 'pass_staging.Yds_1', 'Sacking_Yards', 'COLUMN';
sp_rename 'pass_staging.Sk1', 'Sack_Percentage', 'COLUMN';
sp_rename 'pass_staging.NY_A', 'Net_Yards_Per_Attempt', 'COLUMN';
sp_rename 'pass_staging.ANY_A', 'Adjusted_Net_Yards_Per_Attempt', 'COLUMN';
sp_rename 'pass_staging._4QC', 'Fourth_Q_Comeback', 'COLUMN';
sp_rename 'pass_staging._1D', 'Passing_1st_Down', 'COLUMN';
sp_rename 'pass_staging.Succ', 'Passing_Success_Rate', 'COLUMN';
sp_rename 'pass_staging.QBR', 'QB_Rating', 'COLUMN';


-- b. Method 2 --

DECLARE @TableName SYSNAME = 'passing_staging';

-- Create a table of old and new names.
DECLARE @ColumnRenames TABLE (
    OldName SYSNAME,
    NewName SYSNAME
);

-- Populate the table with your old and new column names.
INSERT INTO @ColumnRenames (OldName, NewName) VALUES
('G', 'Games_Played'),
('GS', 'Games_Started'),
('Cmp', 'Completions'),
('Att', 'Passing_Attempts'),
('Cmp1', 'Completion_Percentage'),
('Yds', 'Passing_Yards'),
('TD1', 'TD_Percentage'),
('Int', 'Interceptions'),
('Int1', 'Interception_Percentage'),
('Lng', 'Longest_Pass'),
('Y_A', 'Yards_Per_Attempt'),
('AY_A', 'Average_Yards_Per_Attempt'),
('Y_C', 'Yards_Per_Completion'),
('Y_G', 'Yards_Per_Game'),
('Rate', 'Passer_Rating'),
('Sk', 'Sacks'),
('Yds_1', 'Sacking_Yards'),
('Sk1', 'Sack_Percentage'),
('NY_A', 'Net_Yards_Per_Attempt'),
('ANY_A', 'Adjusted_Net_Yards_Per_Attempt'),
('_4QC', 'Fourth_Q_Comeback'),
('_1D', 'Passing_1st_Downs'),
('Succ', 'Passing_Success_Rate'),
('QBR', 'QB_Rating');

-- Generate and execute the sp_rename statements dynamically.
DECLARE @SQL NVARCHAR(MAX);
SET @SQL = N''; -- Initialize the variable

SELECT @SQL = @SQL + 
              'EXEC sp_rename ''' + @TableName + '.' + OldName + ''', ''' + NewName + ''', ''COLUMN'';' + CHAR(13)
FROM @ColumnRenames;

PRINT @SQL;

EXEC sp_executesql @SQL;


-- c. Inspect Results --

SELECT 
	*
FROM 
	passing_staging
ORDER BY 
	Year DESC, Rank


----------------------------------------------------------------------------------------------------------------------------------------
/*
	STEP 15: REORDER COLUMNS 	
*/

-- a. Reorder Columns and Save Into New Table --

SELECT 
	Player
	,Age
	,Team
	,Completions
	,Passing_Attempts
	,Completion_Percentage
	,Rank
	,Passing_Yards
	,Longest_Pass
	,Yards_Per_Attempt
	,Average_Yards_Per_Attempt
	,Yards_Per_Completion
	,Yards_Per_Game
	,TD
	,TD_Percentage
	,Interceptions
	,Interception_Percentage
	,Net_Yards_Per_Attempt
	,Adjusted_Net_Yards_Per_Attempt
	,Games_Played
	,Games_Started
	,Wins
	,Losses
	,Ties
	,Sacks
	,Sacking_Yards
	,Sack_Percentage
	,Passing_1st_Downs
	,Fourth_Q_Comeback
	,GWD
	,Passing_Success_Rate
	,Passer_Rating
	,QB_Rating
	,Year
INTO
	passing_clean
FROM
	passing_staging


-- b. Inspect Results --

SELECT
	*
FROM
	passing_clean
ORDER BY
	Year DESC,
	Rank


----------------------------------------------------------------------------------------------------------------------------------------







