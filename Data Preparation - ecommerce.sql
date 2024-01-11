--create customer dataset
create table if not exists public.customers_dataset(
	customer_id varchar,
	customer_unique_id varchar,
	customer_zip_code_prefix numeric,
	customer_city varchar,
	customer_state varchar
);

--create geolocation dataset
create table if not exists public.geolocation_dataset(
	geolocation_zip_code_prefix numeric,
	geolocation_lat double precision,
	geolocation_lng double precision,
	geolocation_city varchar,
	geolocation_state varchar
);

--create order_items_dataset
create table if not exists public.order_items_dataset(
	order_id varchar,
	order_item_id numeric,
	product_id varchar,
	seller_id varchar,
	shipping_limit_date timestamp with time zone,
	price double precision,
	freight_value double precision
);

--create table order_payments_dataset
create table if not exists public.order_payments_dataset(
	order_id varchar,
	payment_sequential numeric,
	payment_type varchar,
	payment_installments numeric,
	payment_value double precision
);

--create table order_reviews_dataset
create table if not exists public.order_reviews_dataset(
	review_id varchar,
	order_id varchar,
	review_score numeric,
	review_comment_title varchar,
	review_comment_message varchar,
	review_creation_date timestamp without time zone,
	review_answer_timestamp timestamp without time zone);

--create table orders_dataset
create table if not exists public.orders_dataset(
	order_id varchar,
    customer_id varchar,
    order_status varchar,
    order_purchase_timestamp timestamp without time zone,
    order_approved_at timestamp without time zone,
    order_delivered_carrier_date timestamp without time zone,
    order_delivered_customer_date timestamp without time zone,
    order_estimated_delivery_date timestamp without time zone
);

--create table product dataset
CREATE TABLE IF NOT EXISTS public.product_dataset
(
    "Number" numeric,
    product_id varchar,
    product_category_name varchar,
    product_name_lenght double precision,
    product_description_lenght double precision,
    product_photos_qty double precision,
    product_weight_g double precision,
    product_length_cm double precision,
    product_height_cm double precision,
    product_width_cm double precision);
	
--create table sellers dataset
CREATE TABLE IF NOT EXISTS public.sellers_dataset
(
    seller_id character varying,
    seller_zip_code_prefix numeric,
    seller_city character varying,
    seller_state character varying);
	
-- SETTING PRIMARY KEY
alter table product_dataset add constraint pk_products primary key (product_id);
alter table sellers_dataset add constraint pk_seller primary key (seller_id);
alter table orders_dataset add constraint pk_order primary key (order_id);
alter table geolocation_dataset add constraint pk_geloloc_prefix primary key (geolocation_zip_code_prefix);
alter table customers_dataset add constraint pk_customer primary key (customer_id);

-- SETTING FOREIGN KEY
alter table customers_dataset add foreign key (customer_zip_code_prefix) references geolocation_dataset;
alter table orders_dataset add foreign key (customer_id) references customers_dataset;
alter table order_items_dataset add foreign key (order_id) references orders_dataset;
alter table order_items_dataset add foreign key (seller_id) references sellers_dataset;
alter table order_items_dataset add foreign key (product_id) references product_dataset;
alter table sellers_dataset add foreign key (seller_zip_code_prefix) references geolocation_dataset;
alter table order_payments_dataset add foreign key (order_id) references orders_dataset;
alter table order_reviews_dataset add foreign key (order_id) references orders_dataset; 
