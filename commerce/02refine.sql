-- refine
drop table if exists view_log;
create table view_log as
select * from site_view_log where server_time > '2016-10-01';
drop table if exists order_log;
create table order_log as
select * from site_order_log where server_time > '2016-10-01';
drop table if exists product;
create table product as select * from site_product;

select * from view_log limit 100;
select * from order_log limit 100;
select * from product limit 100;

drop index if exists i_product_id;
create index i_product_id on product(item_id);