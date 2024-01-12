
-- 1. MONTHLY ACTIVE USER PER YEAR
-- 1a. Monthly active user
select * from orders_dataset limit 5;

select 
	order_year,
	sum(active_user) as sum_active_user,
	round(avg(active_user), 2) as avg_active_user
from (
	select
		extract(year from od.order_purchase_timestamp) as order_year,
		extract(month from od.order_purchase_timestamp) as order_month,
		count(distinct cd.customer_unique_id) as active_user
	from 
		orders_dataset od
	inner join customers_dataset cd 
		on od.customer_id = cd.customer_id
	group by 1,2
	order by 1,2 asc)
group by 1

-- 1b. Monthly active seller (tambahan)
select
	extract(year from oi.shipping_limit_date) as order_year,
	extract(month from oi.shipping_limit_date) as order_month,
	count(distinct sd.seller_id) as active_seller
from 
	order_items_dataset oi
inner join sellers_dataset sd 
	on oi.seller_id = sd.seller_id
group by 1,2
order by 1,2 asc; 

-- 2. NUMBER OF NEW CUSTOMER
select 
	extract(year from first_order) as "year",
	count(customer_unique_id) as sum_new_customer
from (
	select
		cd.customer_unique_id,
		min(od.order_purchase_timestamp) as first_order
	from orders_dataset od
	inner join customers_dataset cd 
		on cd.customer_id = od.customer_id
	group by 1 )
group by 1
order by 1 asc
	
-- 3. NUMBER OF REPEAT ORDER CUSTOMER PER YEAR
select 
	year,
	sum(number_order) as sum_customer_repeat_order
from (
	select
		extract (year from od.order_purchase_timestamp) as "year",
		cd.customer_unique_id, 
		count(1) as number_order
	from orders_dataset od
	inner join customers_dataset cd
		on cd.customer_id = od.customer_id
	group by 1, 2
	having count(1) > 1 )
group by 1
order by 1 asc;

-- 4. AVERAGE NUMBER OF ORDER BY CUSTOMERS EACH YEAR
select 
	year,
	round(avg(number_order), 2) as customer_avg_order
from (
	select
		cd.customer_unique_id,
		extract(year from od.order_purchase_timestamp) as "year",
		count(od.order_id) as number_order
	from orders_dataset od
	inner join customers_dataset cd
		on cd.customer_id = od.customer_id
	group by 1, 2)
group by 1;

-- JOIN ALL TABLE
with 
	active_user_table
	as ( 
	select 
		order_year,
		sum(active_user) as sum_active_user,
		round(avg(active_user), 2) as avg_active_user
	from (
		select
			extract(year from od.order_purchase_timestamp) as order_year,
			extract(month from od.order_purchase_timestamp) as order_month,
			count(distinct cd.customer_unique_id) as active_user
		from 
			orders_dataset od
		inner join customers_dataset cd 
			on od.customer_id = cd.customer_id
		group by 1,2
		order by 1,2 asc)
	group by 1),
	
	new_cust_table
	as (
		select 
			extract(year from first_order) as "year",
			count(customer_unique_id) as sum_new_customer
		from (
			select
				cd.customer_unique_id,
				min(od.order_purchase_timestamp) as first_order
			from orders_dataset od
			inner join customers_dataset cd 
				on cd.customer_id = od.customer_id
			group by 1 )
		group by 1
		order by 1 asc),
		
	repeat_order_cust_table
	as (
		select 
		year,
		sum(number_order) as sum_customer_repeat_order
		from (
			select
				extract (year from od.order_purchase_timestamp) as "year",
				cd.customer_unique_id, 
				count(1) as number_order
			from orders_dataset od
			inner join customers_dataset cd
				on cd.customer_id = od.customer_id
			group by 1, 2
			having count(1) > 1 )
		group by 1
		order by 1 asc),
		
	cust_avg_order_table 
	as (
		select 
		year,
		round(avg(number_order), 2) as customer_avg_order
		from (
			select
				cd.customer_unique_id,
				extract(year from od.order_purchase_timestamp) as "year",
				count(od.order_id) as number_order
			from orders_dataset od
			inner join customers_dataset cd
				on cd.customer_id = od.customer_id
			group by 1, 2)
		group by 1)
		
select 
	cao.year,
	cao.customer_avg_order,
	roc.sum_customer_repeat_order,
	nc.sum_new_customer,
	au.sum_active_user,
	au.avg_active_user
from cust_avg_order_table cao
inner join repeat_order_cust_table roc on cao.year = roc.year
inner join new_cust_table nc on cao.year = nc.year
inner join active_user_table au on cao.year = au.order_year

	
		
	