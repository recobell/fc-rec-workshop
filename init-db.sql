-- Connect to your local database using the following command
--$ psql postgres

create user fcuser with password 'fcuser123';

create database fcrec;

grant all privileges on database fcrec to fcuser;
