create table ml_movie (
    movie_id	int,
    imdb_id	    int,
    title		varchar(200),
    genres		varchar(1000),
    image_url   varchar(4000),
    primary key(movie_id)
);

create table ml_rating (
    user_id		int,
    movie_id	int,
    rating		float,
    timestamp	bigint,
    primary key(user_id, movie_id)
);

create table ml_tag (
    user_id		int,
    movie_id	int,
    tag			varchar(100),
    timestamp	bigint,
    primary key(user_id, movie_id, tag)
);
