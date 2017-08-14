-- best
-- 1. click best
drop table if exists product_click_best;

create table product_click_best as
select
	item_id,
	cnt score,
	row_number() over (order by cnt desc) rank
from (
	select
		item_id,
		count(distinct session_id) cnt
	from 
		view_log
	group by item_id
) a;


-- 2. order best
drop table if exists product_order_best;

create table product_order_best as
select
	item_id,
	score,
	row_number() over (order by score desc) rank
from (
	select
		a.item_id,
		b.price,
		log(b.price) log_price,
		a.order_cnt,
		log(b.price) * a.order_cnt score
	from (
		select
			item_id,
			count(distinct order_id) order_cnt
		from 
			order_log
		group by item_id
	) a
	inner join product b on a.item_id = b.item_id
) a;


-- 3. best for mall -- aggregating view + 10 order
drop table if exists product_best;

create table product_best as
select
	item_id,
	score,
	row_number() over (order by score desc) rank
from (
	select
		item_id,
		sum(score) score
	from (
		select item_id, score from product_click_best
		union all
		select item_id, 3 * score from product_order_best
	) a
	group by item_id
) a;


-- 4. category1 best from best for mall
drop table if exists category1_best;

create table category1_best as
select 
	category,
	item_id,
	score,
	row_number() over (partition by category order by score desc) rank
from ( 
	select
		b.category1 category,
		a.item_id,
		a.score
	from product_best a
	inner join product b on a.item_id = b.item_id
) a;


-- 5. conversion_rate 를 이용한 best 만들기
drop table if exists view_stats;

create table view_stats as
select
	item_id,
	count(*) as view_cnt
from view_log
group by item_id

drop table if exists product_best_conv;

create table product_best_conv as
select
	item_id,
	view_cnt,
	order_cnt,	
	conv_rate,
	row_number() over (order by conv_rate desc) as rank
from (
	select
		a.item_id,
		view_cnt,
		order_cnt,
		(order_cnt::float/view_cnt::float)::float conv_rate
	from view_stats a
	inner join (
		select
			item_id,
			count(*) as order_cnt
		from order_log
		group by item_id
		having count(*) > 3
	) b on a.item_id = b.item_id
) a;



-- 6. category2 best 만들기
drop table if exists category2_best;

create table category2_best as
select 
	category,
	item_id,
	score,
	row_number() over (partition by category order by score desc) rank
from ( 
	select
		b.category2 category,
		a.item_id,
		a.score
	from product_best a
	inner join product b on a.item_id = b.item_id
) a;




