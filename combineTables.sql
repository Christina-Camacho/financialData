------------------------------------------------------
-- ADD CLIENT_ID TO THE LOAN TABLE 
-- FLAGGING JOINT ACCOUNTS
------------------------------------------------------
DROP TABLE IF EXISTS #accountID;
SELECT t1.account_id AS idAccount
     , t2.account_id AS idDisp
     , t3.account_id AS idLoan
     , client_id
INTO #accountID
FROM account AS t1
FULL OUTER JOIN disp AS t2 ON t1.account_id = t2.account_id
FULL OUTER JOIN loan AS t3 ON t1.account_id = t3.account_id
GROUP BY t1.account_id, t2.account_id, t3.account_id, client_id
ORDER BY t1.account_id;

------------------------------------------------------
DROP TABLE IF EXISTS #jointFlag;

WITH JointAccounts AS (
    SELECT idAccount
    FROM #accountID
    GROUP BY idAccount
    HAVING COUNT(DISTINCT client_id) > 1
)
SELECT a.idAccount
     , a.idDisp
     , a.idLoan
     , a.client_id
     , CASE 
           WHEN ja.idAccount IS NOT NULL THEN 1 
           ELSE 0 
       END AS jointAccountFlag
INTO #jointFlag
FROM #accountID a
LEFT JOIN JointAccounts ja ON a.idAccount = ja.idAccount
ORDER BY a.idAccount, a.client_id;

------------------------------------------------------
-- BIN AGES
-- ADDING BINS TO THE #JOINTFLAG TABLE
------------------------------------------------------
DROP TABLE IF EXISTS #AgeCalculation;
CREATE TABLE #AgeCalculation (
    birthdate DATE
  , age_in_1997 INT
);

------------------------------------------------------
-- GET AGES
DROP TABLE IF EXISTS #age;
SELECT *
     , DATEDIFF(YEAR, birth_date, '1997-12-31') AS age_in_1997
INTO #age
FROM client;

------------------------------------------------------
-- CREATE AGE GROUPS
DROP TABLE IF EXISTS #BinAges;
SELECT *
     , CASE 
           WHEN age_in_1997 < 18 THEN 'Under 18'
           WHEN age_in_1997 BETWEEN 18 AND 24 THEN '18-24'
           WHEN age_in_1997 BETWEEN 25 AND 34 THEN '25-34'
           WHEN age_in_1997 BETWEEN 35 AND 44 THEN '35-44'
           WHEN age_in_1997 BETWEEN 45 AND 54 THEN '45-54'
           WHEN age_in_1997 BETWEEN 55 AND 64 THEN '55-64'
           WHEN age_in_1997 >= 65 THEN '65 or over'
       END AS age_group
INTO #BinAges
FROM #age;

------------------------------------------------------
-- Join to the original table
DROP TABLE IF EXISTS #joinTb1;
SELECT t1.client_id
     , t5.account_id
     , t1.birth_date
     , t1.gender
     , t5.[type] AS AuthorizationType
     , t5.[disp_id]
     , t6.type AS cardType
     , t2.age_group
     , jointAccountFlag AS joint_account
     , CASE WHEN idLoan IS NOT NULL THEN 1 ELSE 0 END AS loan_flag
	 , t1.district_id
     , t4.[district name]
     , t4.region
     , noOfInhabitants
     , binNoOfInhabitants
     , unemploymentRate95
     , unemploymentRate96
     , unemploymentRate96 - unemploymentRate95 AS unemploymentRateDiff
     , avgSalary
     , binAvgSalary
     , NoOfCrime95
     , NoOfCrime96
     , binNoOfCrime95
     , binNoOfCrime96
     , [noEnterpreneursPer1000]
     , noOfCities
     , [<499]
     , [500-1999]
     , [2000-9999]
     , [>10000]
     , ratioInhabitants
	, t7.[date] as loanDate
    , t7.[amount] as loanAmount
    , t7.[duration] as loanDuration
    , t7.[payments] as loanPayments
    , t7.[loanStatus] as loanStatus

INTO #joinTb1
FROM client t1
LEFT OUTER JOIN #BinAges t2 ON t1.client_id = t2.client_id
LEFT OUTER JOIN #jointFlag t3 ON t1.client_id = t3.client_id
LEFT OUTER JOIN districtWBins t4 ON t1.district_id = t4.district_id
LEFT OUTER JOIN disp t5 ON t1.client_id = t5.client_id
LEFT OUTER JOIN card t6 ON t5.disp_id = t6.disp_id
LEFT OUTER JOIN loan t7 on t3.idAccount = t7.account_id
ORDER BY client_id;

------------------------------------------------------
-- Load the final select table into the database as 'demographic'
DROP TABLE IF EXISTS demographic;
SELECT * 
INTO demographic
FROM #joinTb1;

---- Verify the data
SELECT  * FROM demographic order by account_id desc;

------------------------------------------------------
-- Create Pivoted Loan Status Table
------------------------------------------------------
DROP TABLE IF EXISTS LoanStatus
SELECT 
    account_id,
    client_id,
    loanDate,
    loanAmount,
    loanDuration,
    loanPayments,
    (CASE WHEN loanStatus = 'A' THEN 1 ELSE 0 END) AS LoanStatus_A,
    (CASE WHEN loanStatus = 'B' THEN 1 ELSE 0 END) AS LoanStatus_B,
    (CASE WHEN loanStatus = 'C' THEN 1 ELSE 0 END) AS LoanStatus_C,
    (CASE WHEN loanStatus = 'D' THEN 1 ELSE 0 END) AS LoanStatus_D
	,loanAmount - loanPayments as diff
	, round (100-((loanAmount - loanPayments)/loanAmount*100),0) as perLeft
INTO
    LoanStatus
FROM 
    demographic
Where loan_flag = 1;
