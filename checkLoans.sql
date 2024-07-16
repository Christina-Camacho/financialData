
drop table if exists #trans
select top 1000 account_id     
	,[date]
    ,[type]
    ,[operation]
    ,[amount]
    ,[balance]
    ,[k_symbol]
    ,[bank]
    ,[account] 
into #trans
from trans
where k_symbol = 'loans'
order by account_id

drop table if exists #loantemp
select account_id 
	,[birth_date]
	,[gender]
	,[AuthorizationType]
	,[disp_id]
	,[cardType]
	,[age_group]
	,[joint_account]
	,[loan_flag]
	,[district_id]
	,[district name]
	,[region]
	,[noOfInhabitants]
	,[binNoOfInhabitants]
	,[unemploymentRate95]
	,[unemploymentRate96]
	,[unemploymentRateDiff]
	,[avgSalary]
	,[binAvgSalary]
	,[NoOfCrime95]
	,[NoOfCrime96]
	,[binNoOfCrime95]
	,[binNoOfCrime96]
	,[noEnterpreneursPer1000]
	,[noOfCities]
	,[<499]
	,[500-1999]
	,[2000-9999]
	,[>10000]
	,[ratioInhabitants]
	,[loanDate]
	,[loanAmount]
	,[loanDuration]
	,[loanPayments]
	,[loanStatus]
into #loantemp
FROM [financial].[dbo].[demographic]   
where loan_flag = 1
order by account_id

select count(loanStatus), loanStatus 
from #loantemp 
group by loanStatus

select * from #trans order by account_id

select sum(amount) as amount, sum(balance) as balance from #trans where account_id = 2

select * from #loantemp where account_id = 2