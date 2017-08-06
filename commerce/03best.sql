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