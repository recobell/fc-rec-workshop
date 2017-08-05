-- refine
drop table if exists view_log;
create table view_log as
select * from site_view_log where server_time > '2016-10-01';
drop table if exists order_log;
create table order_log as
select * from site_order_log where server_time > '2016-10-01';
drop table if exists product;
create table product as select * from site_product;

-- co-occurence
-- tf-idf (log scale)

-- cosine similarity


select * from view_log limit 100;
select * from order_log limit 100;
select * from product limit 100;
drop index if exists i_product_id;
create index i_product_id on product(item_id);


-- coo_rel
drop index if exists i_view_coo_rel;
create index i_view_coo_rel on view_log(uid, session_id, item_id);

drop table if exists coo_rel;
create table coo_rel as
select
	*
from (
	select
		target_item_id,
		cross_sell_item_id,
		score,
		row_number() over (partition by target_item_id order by score desc) rank
	from (
		select
			a.item_id target_item_id,
			b.item_id cross_sell_item_id,
			count(*) score
		from view_log a
		inner join view_log b on a.uid = b.uid and a.session_id = b.session_id
		group by a.item_id, b.item_id
	) a
) a;

drop index if exists i_coo_rel;
create index i_coo_rel on coo_rel(target_item_id, rank);

-- 413b7b7
-- 7d5cb7f
select * from site_product where item_id in ('413b7b7', '7d5cb7f');
select * from coo_rel where target_item_id in ('413b7b7', '7d5cb7f');


-- td-idf
-- 1. idf
drop index if exists i_product_id;
drop index if exists i_product_id;
create index i_tdidf_1 on view_log(session_id);
create index i_tdidf_2 on view_log(item_id, session_id);

select count(distinct session_id) from view_log; -- N
select item_id, count(session_id) df from view_log group by item_id; -- df

drop table if exists item_idf;
create table item_idf as
select
	item_id,
	log((select count(distinct session_id) from view_log)/
		(count(session_id) over (partition by item_id) + 1)) idf
from view_log a;
create index i_idf on item_idf(item_id, idf);

-- 2. tf-idf by session(document)-item(word)
drop table if exists tfidf;
create table tfidf as
select
	a.session_id,
	a.item_id,
	a.cnt*b.idf tfidf
from (
	select session_id, item_id, count(*) cnt from view_log group by session_id, item_id
) a
inner join item_idf b on a.item_id = b.item_id;

drop index if exists i_tfidf;
create index i_tfidf on tfidf(session_id, item_id, tfidf);

-- 3. rel
drop table if exists tfidf_rel;
create table tfidf_rel as
select
	*
from (
	select
		target_item_id,
		cross_sell_item_id,
		score,
		row_number() over (partition by target_item_id order by score desc) rank
	from (
		select
			a.item_id target_item_id,
			b.item_id cross_sell_item_id,
			sum(c.tfidf) score
		from view_log a
		inner join view_log b on a.uid = b.uid and a.session_id = b.session_id
		inner join tfidf c on a.session_id = c.session_id and b.item_id = c.item_id
		group by a.item_id, b.item_id
	) a
) a;


-- coo - cosine
drop table if exists coo_cs;
create table coo_cs as
select 
	item_id,
	session_id,
	count(distinct session_id) / (sum(count(distinct session_id)) over (partition by item_id)) cs
from view_log
group by item_id, session_id;

drop index if exists i_coo_cs;
create index i_coo_cs on coo_cs(session_id, item_id, cs);

-- 3. rel
drop table if exists coo_cs_rel;
create table coo_cs_rel as
select
	*
from (
	select
		target_item_id,
		cross_sell_item_id,
		score,
		row_number() over (partition by target_item_id order by score desc) rank
	from (
		select
			a.item_id target_item_id,
			b.item_id cross_sell_item_id,
			max(a.cs) * max(b.cs) score
		from coo_cs a
		inner join coo_cs b on a.session_id = b.session_id
		group by a.item_id, b.item_id
	) a
) a;

select * from coo_rel where target_item_id = '413b7b7';
select * from tfidf_rel where target_item_id = '413b7b7';
select * from coo_cs_rel where target_item_id = '413b7b7';