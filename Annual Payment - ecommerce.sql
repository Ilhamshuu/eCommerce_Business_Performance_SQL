select * from order_payments_dataset limit 5
select distinct * from orders_dataset limit 5

-- 1. the number of uses of each type of payment all time
select
	payment_type,
	count(payment_type) as num_used
from order_payments_dataset
group by 1
order by 2 desc;

-- 2. payment used per year
WITH payment AS (
select
	extract (year from od.order_purchase_timestamp) as year,
	opd.payment_type,
	count(opd.payment_type) as num_used
from order_payments_dataset opd
join orders_dataset od on od.order_id = opd.order_id
group by 1, 2
)

select *,
	case when year_2016 = 0 then null
	else round(((year_2017 - year_2016) / year_2016), 2)
	end as pct_change_2016_2017,
	case when year_2017 = 0 then null
	else round(((year_2018 - year_2017) / year_2017), 2)
	end as pct_change_2017_2018
from (
select 
  payment_type,
  sum(case when year = '2016' then num_used else 0 end) as year_2016,
  sum(case when year = '2017' then num_used else 0 end) as year_2017,
  sum(case when year = '2018' then num_used else 0 end) as year_2018
from payment 
group by 1) subq
order by 5 desc