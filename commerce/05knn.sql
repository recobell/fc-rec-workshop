
drop table if exists session_item_view;

-- 사용자가 세션에서 어떤 아이템을 몇 번이나 봤는지 구한다.
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
) a;

create index idx_session_item_view_1 on session_item_view(session_id, item_id);

drop table if exists session_view;

-- 사용자가 세션에서 (구분없이) 아이템을 몇번 봤는지 구한다.
create table session_view as
select
	uid,
	session_id,
	count(distinct item_id) item_cnt,
	count(item_id) view_cnt,
	max(server_time) server_time
from view_log
group by uid, session_id;

create index idx_session_view_1 on session_view(item_cnt);
create index idx_session_view_2 on session_view(session_id);

drop table if exists session_item_view_filter;

-- 세션 중에서 아이템을 세번이상 본 세션에 대해서만 어떤 아이템을 몇번 봤는지 구한다.
create table session_item_view_filter as
select
	b.uid,
	b.session_id,
	b.item_id,
	b.view_cnt,
	a.rank
from (
	-- 세션중에서 아이템을 3번이상 본 세션만 뽑는다.
	select
		session_id,
		item_cnt,
		view_cnt,
		server_time,
		dense_rank() over (partition by uid order by server_time desc) rank  -- 여기서 rank는 사용자당 세션의 순서
	from session_view
	where item_cnt >= 3
) a
inner join session_item_view b on a.session_id = b.session_id;

create index idx_session_item_view_filter_1 on session_item_view_filter(item_id);

drop table if exists knn_idf;

-- 아이템별로 idf 값을 구한다.
create table knn_idf as
select
	a.item_id,
	log(b.session_cnt::float / a.session_per_item::float) as idf_score
from 
	(select item_id, count(distinct session_id) session_per_item from session_item_view_filter group by item_id) a,
	(select count(distinct session_id) session_cnt from session_item_view_filter) b	;

create index idx_knn_idf_1 on knn_idf(item_id);

drop table if exists session_item_view_filter_score;

-- 위에서 만든, 3번이상 본 세션이 어떤 아이템을 봤는지에 대해서, 아이템의 idf score 를 붙인다.
create table session_item_view_filter_score as
select
	a.uid,
	a.session_id,
	a.item_id,
	a.view_cnt,
	a.rank,
	b.idf_score
from session_item_view_filter a
left outer join knn_idf b on a.item_id = b.item_id;

create index idx_session_item_view_filter_score_1 on session_item_view_filter_score(item_id);

drop table if exists session_neighbor_occurence;

-- 세션에 대해서 어떤 다른 세션이 비슷한지 구한다.
create table session_neighbor_occurence as
select
	target_uid,
	target_session_id,
	neighbor_session_id,
	neighbor_score
from (
	-- 랭키을 추가한다.
	select 
		target_uid,
		target_session_id,
		neighbor_session_id,
		neighbor_score,
		row_number() over (partition by target_session_id order by neighbor_score desc, neighbor_item_cnt desc) rank
	from (
		-- 필터링 조건을 추가한다.
		select
			a.target_uid,
			a.target_session_id,
			a.neighbor_session_id,
			a.coo_cnt,
			a.neighbor_score,
			c.item_cnt neighbor_item_cnt
		from (
			-- 자신과 비슷한 세션을 찾는다. coo_cnt 가 높을 수록 유사
			select 
				a.uid target_uid,
				a.session_id target_session_id,
				b.session_id neighbor_session_id,
				count(*) coo_cnt,
				sum(b.idf_score) neighbor_score		-- 스코어는 조인되는 세션(도큐먼트)의 idf 합이다.
			from (
				-- 사용자의 가장 최근 세션(rank=1)에 대해서만 관계를 구할예정
				select 
					uid,
					session_id,
					item_id,
					idf_score
				from session_item_view_filter_score
				where rank = 1
			) a
			inner join session_item_view_filter_score b on a.item_id = b.item_id and a.session_id <> b.session_id
			group by a.uid, a.session_id, b.session_id
		) a
		left outer join session_view c on a.neighbor_session_id = c.session_id
		where a.coo_cnt < c.item_cnt 	-- 찾은 세션이 겹치는 아이템보다 많아야하고 -> 그래야 안 나온 상품을 추천가능
			and a.coo_cnt > 3			-- 최소 3개 이상은 겹쳐야한다.

	) a
) a
where rank < 10;		-- kNN 에서 k = 10, 즉 열개의 유사한 세션만 찾는다.

create index idx_session_neighbor_occurence_1 on session_neighbor_occurence(item_id);

drop table if exists session_item_knn;


-- 어떤 사람의, 어떤 세션에 대해서 어떤 아이템이 추천되어야하는지 구한다.
create table session_item_knn as
select
	target_uid,
	target_session_id,
	item_id,
	score
from (
	-- 랭킹달기
	select
		target_uid,
		target_session_id,
		item_id,
		item_neighbor_cnt,
		score,
		row_number() over (partition by target_session_id order by score desc) rank
	from (
		-- 아이템당 스코어를 넣어준다.
		select
			a.target_uid,
			a.target_session_id,
			a.item_id,
			count(*) item_neighbor_cnt,
			sum(a.neighbor_score * c.idf_score)::float score
		from (
			-- 앞에서 구한 occurence 에, 인접 세션에 대한 아이템을 붙여준다. (이게 결국 추천이 되어야하는 아이템)
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
		inner join knn_idf c on a.item_id = c.item_id
		group by a.target_uid, a.target_session_id, a.item_id
	)a
	where item_neighbor_cnt > 3
)a 
where rank < 10;
