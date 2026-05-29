create view crm.clocation as
select 
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    country
from crm.cust_infos i
left join crm.loc l
    on i.cst_key = l.cid;

create view crm.pc as
select 
    prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt,
    cat,
    subcat
from crm.prd_infos p
left join crm.prd_catgry c
    on p.cat_id = c.id;


create view crm.rsales as
select
    s.*,
    c.cst_id,
    c.cst_firstname,
    c.cst_lastname,
    c.cst_marital_status,
    c.cst_gndr,
    c.country,
    p.prd_nm,
    p.prd_cost,
    p.prd_line,
    p.cat,
    p.subcat
from crm.sls_details s
left join crm.clocation c
    on s.sls_cust_id = c.cst_id
left join crm.pc p
    on s.sls_prd_key = p.prd_key;


-- INSIGHT QUERIES 

-- top rated customers based on total sales and quantity

select 
	cst_firstname,
	cst_lastname,
	sum(sls_sales) as total_sales,
	sum(sls_quantity) as total_quantity
from crm.rsales
group by 1,2
order by total_sales desc 
limit 10;


-- regions with top rated customers 
select
	cst_id,
	country,
    cst_firstname,
    cst_lastname,
    sum(sls_sales) as total_sales
from crm.rsales
group by
	cst_id,
	country,
    cst_firstname,
    cst_lastname
order by total_sales desc
limit 10;

-- top selling products based on total sales, quantity

select 
	prd_nm,
	sum(sls_sales) as total_sales,
	sum(sls_quantity) as total_quantity
from crm.rsales
group by prd_nm
order by total_sales desc 
limit 10;

-- best product categories

select 
	cat,
	sum(sls_sales) as total_sales
from crm.rsales 
group by cat
order by total_sales desc;


-- year on year growth

with yearly_sales as (
    select
        extract(year from sls_order_dt) as year,
        sum(sls_sales) as total_sales
    from crm.rsales
    group by extract(year from sls_order_dt)
)
select
    year,
    total_sales,
    lag(total_sales) over (order by year) as lastyear_sales,
  	round((total_sales - lag(total_sales) OVER (ORDER BY year))
     / lag(total_sales) over (order by year) * 100, 2
) as growth
from yearly_sales;


-- regional product performance
select
    country,
    prd_nm,
    sum(sls_sales) as total_sales
from crm.rsales
group by
    country,
    prd_nm
order by total_sales desc
limit 10;


-- highest demanded products
select
    prd_nm,
    sum(sls_quantity) as total_quantity
from crm.rsales
group by prd_nm
order by total_quantity desc;

-- low performing products
select 
	sls_prd_key,
	prd_nm,
	sum(sls_sales) as total_sales
from crm.rsales 
group by sls_prd_key,
		prd_nm
order by total_sales asc
limit 10 ;



	


