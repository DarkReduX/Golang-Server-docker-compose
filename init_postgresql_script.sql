create table users (username varchar(30) PRIMARY KEY, password varchar(30), token varchar(256) null);
Insert into Users (username, password, token) 
values ('admin','admin','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2MjgwNjk5NTIuNjA4NTE2LCJzdWIiOiJhZG1pbiJ9.4Z-6tW4gJT4QqogDR6Y-A9gBummz-fnO0GXTQRGHwvQ');

create table entities (uuid varchar(128) Primary key, name varchar(30), size integer)
insert into entities (uuid, name, size) 
values ('5', 'ball', 32), ('1', 'box', 42)
