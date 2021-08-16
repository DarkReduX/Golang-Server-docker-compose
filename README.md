# Golang-Server-docker-compose
# Contains
* Zookeper
* Kafka
* [Consumer](https://github.com/DarkReduX/kafka-consume-http-server-Golang)
* [Server](https://github.com/DarkReduX/HTTP-Server-Golang)
# Settings
To run http-server u need to configure environment variables:
* MONGO_URI - Mongo-database connection, this database contains 2 collections (entities, users)
* POSTGRES_URI/POSTGRES_LOCAL_URI - PostgreSQL connections of local and remote database, contains 2 tables (entities, users), to init them use this script
* REDIS_URI - Redis database connection string
* REDIS_USERNAME - Redis username
* REDIS_PASSWORD - Redis username password
``` SQL
create table users (username varchar(30) PRIMARY KEY, password varchar(30), token varchar(256) null);
Insert into Users (username, password, token) 
values ('admin','admin','eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2MjgwNjk5NTIuNjA4NTE2LCJzdWIiOiJhZG1pbiJ9.4Z-6tW4gJT4QqogDR6Y-A9gBummz-fnO0GXTQRGHwvQ');

create table entities (uuid varchar(128) Primary key, name varchar(30), size integer)
insert into entities (uuid, name, size) 
values ('5', 'ball', 32), ('1', 'box', 42)
```
* POSTGRES_USER - postgreSQL user for connection with database
* POSTGRES_PASSWORD - postgreSQL user's password
* POSTGRES_DB - database name
# File code

``` yaml
version: '2.1'

services:

  zookeeper:
    image: confluentinc/cp-zookeeper:latest
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    ports:
      - 22181:2181
    networks:
      - local

  kafka:
    image: confluentinc/cp-kafka:latest
    depends_on:
      - zookeeper
    ports:
      - 29092:29092
    healthcheck:
      test: curl -sS http://kafka:9092 || exit 1
      interval: 5s
      timeout: 10s
      retries: 5
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:9092,PLAINTEXT_HOST://localhost:29092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
    networks:
      - local

  serverconsumer:
    image: serverconsumer:latest
    depends_on:
      kafka:
        condition: service_started
      httpserver:
        condition: service_started
      zookeeper:
        condition: service_started
    ports:
      - 29091:29091
    environment:
      MONGO_URI: mongodb+srv://dbuser:dbuser@serverdb.k1qo7.mongodb.net/myFirstDatabase?retryWrites=true&w=majority
      POSTGRES_URI: postgres://jzdpzbxo:VRpZC6MeToLiY5_hDa0-lNj5VRJAZfSi@ella.db.elephantsql.com/jzdpzbxo
      POSTGRES_LOCAL_URI: host=database user=postgres password=a!11111111 dbname=postgres sslmode=disable
      KAFKA_ADDR: kafka:9092
    networks:
      - local

  httpserver:
    image: httpserver:latest
    depends_on:
      kafka:
        condition: service_started
      zookeeper:
        condition: service_started
      database:
        condition: service_healthy
    ports:
      - 1323:1323
    environment:
      POSTGRES_LOCAL_URI: host=database user=postgres password=a!11111111 dbname=postgres sslmode=disable
      MONGO_URI: mongodb+srv://dbuser:dbuser@serverdb.k1qo7.mongodb.net/myFirstDatabase?retryWrites=true&w=majority
      POSTGRES_URI: postgres://jzdpzbxo:VRpZC6MeToLiY5_hDa0-lNj5VRJAZfSi@ella.db.elephantsql.com/jzdpzbxo
      REDIS_URI: redis-18387.c14.us-east-1-2.ec2.cloud.redislabs.com:18387
      REDIS_USERNAME: DarkReduX
      REDIS_PASSWORD: qqqqqQ_1
      KAFKA_ADDR: kafka:9092
    networks:
      - local

  database:
    image: "postgres" # use latest official postgres version
    volumes:
      - ./postgres-data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready"]
      interval: 5s
      timeout: 10s
      retries: 5
    environment:
      POSTGRES_HOST: database
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: a!11111111
      POSTGRES_DB: postgres
    networks:
      - local

networks:
  local:
    driver: bridge
```
