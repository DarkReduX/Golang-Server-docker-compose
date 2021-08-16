# Golang-Server-docker-compose
# Contains
* Zookeper
* Kafka
* [Consumer](https://github.com/DarkReduX/kafka-consume-http-server-Golang)
* [Server](https://github.com/DarkReduX/HTTP-Server-Golang)
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
      KAFKA_ADDR: kafka:9092
      POSTGRES_LOCAL_URI: host=database user=postgres password=a!11111111 dbname=postgres sslmode=disable
      P_VAL: qqqqqQ_1 # change
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
      KAFKA_ADDR: kafka:9092
      P_VAL: qqqqqQ_1 # change
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
