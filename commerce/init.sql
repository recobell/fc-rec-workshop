## Initialze Query for PAKDD e-Commerce User Behavior
#	You should downlaod followings
#		1. site_view_log => http://pakdd2017.recobell.io/site_view_log_small.csv000.gz
#		2. site_order_log => http://pakdd2017.recobell.io/site_order_log_small.csv000.gz
#		3. site_product => http://pakdd2017.recobell.io/site_product_w_img.csv000.gz
#	then un-zip all files, move it to [FILE_DIRECTORY], which you want to keep it

drop table if exists site_view_log;

create table site_view_log (
	server_time timestamp,
	device char(2),
	session_id char(10),
	uid char(7),
	item_id char(7)
);

drop table if exists site_order_log;

create table site_order_log (
	server_time timestamp,
	device char(2),
	session_id char(10),
	uid char(7),
	item_id char(7),
	order_id char(7),
	quantity int
);


drop table if exists site_product;

create table site_product (
	item_id	char(7),
	item_image	varchar(255),
	price	int,
	category1	char(7),
	category2	char(7),
	category3	char(7),
	category4	char(7),
	brarnd	char(7)
);

copy site_view_log
from '[FILE_DIRECTORY]/site_view_log_small.csv000'
CSV;

copy site_order_log
from '[FILE_DIRECTORY]/site_order_log_small.csv000'
CSV;

copy site_product
from '[FILE_DIRECTORY]/site_product_w_img.csv000'
CSV;


select * from site_view_log limit 100;
select * from site_order_log limit 100;
select * from site_product limit 100;