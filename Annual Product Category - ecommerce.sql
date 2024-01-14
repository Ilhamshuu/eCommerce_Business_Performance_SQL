select * from order_items_dataset limit 1 --ada pricr
select * from order_payments_dataset limit 1 --ada price
select * from orders_dataset limit 1

-- 1. Revenue Per Year
CREATE TABLE total_revenue_per_year AS
SELECT
    year,
    SUM(revenue) AS total_revenue
FROM (
    SELECT
        EXTRACT(YEAR FROM shipping_limit_date) AS year,
        oi.order_id,
        SUM(oi.price + oi.freight_value) AS revenue
    FROM
        order_items_dataset oi
    JOIN
        orders_dataset od ON oi.order_id = od.order_id
    WHERE
        od.order_status = 'delivered'
    GROUP BY 1, 2
) rd
GROUP BY 1;

-- 2. Number of Cancel Order Per Year
CREATE TABlE total_cancel_order_per_year AS
select 
	extract (year from order_purchase_timestamp) as year,
	count(order_id) as total_cancel_order
from orders_dataset
where order_status = 'delivered'
group by 1;

-- 3. Product Category With Highest Revenue Each Year
CREATE TABLE category_highest_revenue AS
SELECT
	year,
	category_highest_revenue,
	rank_cat
FROM (
	SELECT 
		extract (year from o.order_purchase_timestamp) AS year,
		p.product_category_name as category_highest_revenue,
		sum(oi.price + oi.freight_value) as revenue,
		rank() over(partition by extract (year from o.order_purchase_timestamp) 
	ORDER BY 
		SUM(oi.price + oi.freight_value) desc) as rank_cat
	FROM order_items_dataset oi
	JOIN orders_dataset o ON o.order_id = oi.order_id
	JOIN product_dataset p ON p.product_id = oi.product_id
	WHERE o.order_status = 'delivered'
	GROUP BY 1,2
)
where rank_cat = 1

-- 4. Product with Highest Cancel Order Per Year
CREATE TABLE category_highest_cancel_order AS
select
	year,
	category_highest_cancel
from 
	(select
		extract (year from od.order_purchase_timestamp) as year,
		count(od.order_id) as sum_cancel_order,
		pd.product_category_name as category_highest_cancel,
		rank() over (partition by extract (year from od.order_purchase_timestamp) order by count(od.order_id) desc) as rank_canceled
	from orders_dataset od
	join order_items_dataset oi on od.order_id = oi.order_id
	join product_dataset pd on oi.product_id = pd.product_id
	where od.order_status = 'canceled'
	group by 1,3)
where rank_canceled = 1

-- 5. Join all
select
	cr.year,
	cr.category_highest_revenue,
	cl.category_highest_cancel,
	co.total_cancel_order,
	tr.total_revenue
from category_highest_revenue cr
join category_highest_cancel_order cl on cr.year = cl.year
join total_cancel_order_per_year co on cr.year = co.year
join total_revenue_per_year tr on cr.year = tr.year
