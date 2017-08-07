drop table if exists session_item_view;

create table session_item_view as
select
	uid,
	session_id,
	item_id,
	view_cnt,
	server_time,
	row_number() over (partition by uid order by server_time desc) rank
from (
	select
		uid,
		session_id,
		item_id,
		count(*) view_cnt,
		max(server_time) server_time
	from view_log
	group by uid, session_id, item_id
) a


drop table if exists session_view;

create table session_view as
select
	uid,
	session_id,
	count(distinct item_id) item_cnt,
	count(item_id) view_cnt,
	max(server_time) server_time
from view_log
group by uid, session_id;

drop table if exists session_item_view_filter;

create table session_item_view_filter as
select
	b.uid,
	b.session_id,
	b.item_id,
	b.view_cnt,
	a.rank
from (
	select
		session_id,
		item_cnt,
		view_cnt,
		server_time,
		dense_rank() over (partition by uid order by server_time desc) rank
	from session_view
	where item_cnt >= 3
) a
inner join session_item_view b on a.session_id = b.session_id;

drop table if exists knn_tfidf;

create table knn_tfidf as
select
	a.item_id,
	log(b.session_cnt::float / a.session_per_item::float) as tfidf_score
from 
	(select item_id, count(distinct session_id) session_per_item from session_item_view_filter group by item_id) a,
	(select count(distinct session_id) session_cnt from session_item_view_filter) b	;

drop table if exists session_item_view_filter_score;

create table session_item_view_filter_score as
select
	a.uid,
	a.session_id,
	a.item_id,
	a.view_cnt,
	a.rank,
	b.tfidf_score
from session_item_view_filter a
left outer join knn_tfidf b on a.item_id = b.item_id;

drop table if exists session_neighbor_occurence;

create table session_neighbor_occurence as
select
	target_uid,
	target_session_id,
	neighbor_session_id,
	neighbor_score
from (
	select 
		target_uid,
		target_session_id,
		neighbor_session_id,
		neighbor_score,
		row_number() over (partition by target_session_id order by neighbor_score desc, neighbor_item_cnt desc) rank
	from (
		select
			a.target_uid,
			a.target_session_id,
			a.neighbor_session_id,
			a.coo_cnt,
			a.neighbor_score,
			c.item_cnt neighbor_item_cnt
		from (
			select 
				a.uid target_uid,
				a.session_id target_session_id,
				b.session_id neighbor_session_id,
				count(*) coo_cnt,
				sum(b.tfidf_score) neighbor_score
			from (
				select 
					uid,
					session_id,
					item_id,
					tfidf_score
				from session_item_view_filter_score
				where rank = 1
			) a
			inner join session_item_view_filter_score b on a.item_id = b.item_id and a.session_id <> b.session_id
			group by a.uid, a.session_id, b.session_id
		) a
		left outer join session_view c on a.neighbor_session_id = c.session_id
		where a.coo_cnt < c.item_cnt and a.coo_cnt > 3
	) a
) a
where rank < 10;

drop table if exists session_item_knn;

create table session_item_knn as
select
	target_uid,
	target_session_id,
	item_id,
	score
from (
	select
		target_uid,
		target_session_id,
		item_id,
		item_neighbor_cnt,
		score,
		row_number() over (partition by target_session_id order by score desc) rank
	from (
		select
			a.target_uid,
			a.target_session_id,
			a.item_id,
			count(*) item_neighbor_cnt,
			sum(a.neighbor_score * c.tfidf_score)::float score
		from (
			select
				a.neighbor_session_id,
				a.target_session_id,
				a.target_uid,
				a.neighbor_score,
				b.item_id
			from session_neighbor_occurence a
			inner join session_item_view b on a.neighbor_session_id = b.session_id
		)a
		left outer join session_item_view b on a.target_session_id = b.session_id and a.item_id = b.item_id
		inner join knn_tfidf c on a.item_id = c.item_id
		group by a.target_uid, a.target_session_id, a.item_id
	)a
	where item_neighbor_cnt > 3
)a 
where rank < 10;
