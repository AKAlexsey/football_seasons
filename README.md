# FootballSeasons

# Table of content

- [Introduction](#introduction)
- [Up and running](#up-and-running)
- [Docker compose](#docker-compose)
- [Performance testing](#performance-testing)
- [API documentation](#api-documentation)
  * [Request ALL games](#request-all-games)
    + [API with Mnesia caching](#api-with-mnesia-caching)
      - [JSON response demonstration](#json-response-demonstration)
      - [Protobuf response demonstration](#protobuf-response-demonstration)
    + [API with Postgres database](#api-with-postgres-database)
      - [JSON response demonstration](#json-response-demonstration-1)
    + [Performance testing](#performance-testing-1)
      - [Measure Postgres API throughput](#measure-postgres-api-throughput)
      - [Measure Mnesia API throughput](#measure-mnesia-api-throughput)
      - [Compare JSON and Protobuf traffic measurements](#compare-json-and-protobuf-traffic-measurements)
    + [Performance testing conclusion](#performance-testing-conclusion)
  * [Technical API for providing `protobuf` protocol deserialization](#technical-api-for-providing-protobuf-protocol-deserialization)
  * [Search games by division and season](#search-games-by-division-and-season)
    + [Search API with Mnesia caching](#search-api-with-mnesia-caching)
      - [JSON response demonstration](#json-response-demonstration-2)
      - [Protobuf response demonstration](#protobuf-response-demonstration-1)
      - [Logs and load testing](#logs-and-load-testing)
    + [Search API with Postgres caching](#search-api-with-postgres-caching)
      - [Logs and load testing. Comparison with Mnesia version.](#logs-and-load-testing-comparison-with-mnesia-version)
* [Technical exercise](#technical-exercise)
  + [Instructions](#instructions)
  + [Requirements](#requirements)
  + [Features](#features)
  + [Data.csv fields description](#datacsv-fields-description)

## Introduction

Hello. I decided to write introduction to show you what is important in that project. To clarify what was my points,
goals and problems during solving this exercise.

It was interesting exercise. And thanks for freedom. I used it to show:
1. Code quality
2. TDD
3. Providing high performance skills
4. Performance testing skills
And of course all this project itself is big story about me as professional.

I think I am "Upper Middle is about to Senior" level. Like to use Elixir and it's functional paradigm.
This project I tried to show as many as i can. 

[Exercise description](#technical-exercise) this is common task description.

Code quality is very important thing i use for it credo `mix credo --strict` and auto formatting `mix format --check-formatted`.
This is minimum necessary steps those still increase code readability and programming experience.

As for TDD this project coverage is `mix test --cover` -> 54.15% . It's not big value, but it's just 
test project. Tests is suitable for long term code. Those will be modified many times in the future. 
For exercise purposes high test coverage is not so necessary. In production i write tests for most of functional.
Moreover tests saved my time many times. For now tests written for business logic. There is lack of tests for 
requests(API requests) but this disadvantage compensates by performance tests located in `performance_testing`
I will talk about that later. 

Also i wanted to show you approach those i used on one of my past projects to design agile 
high performant API. Application have two endpoints. First - Phoenix router `FootballSeasonsWeb.Router`.
Second - Plug router `FootballSeasonsWeb.ApiRouter`.
Phoenix router - provide Admin page.
Plug router - high loaded API requests.
Admin page - use as data source Postgres.
API - use as data source Mnesia.

This architecture allow us:

1. Manage project using Admin page
2. Design complex API requests by using Mnesia query language
3. Provide high performance API with short delays (To measure it i used Load testing)
4. Separate business logic from technical tasks

Besides that I designed solution for automate caching data from postgres to Mnesia.
All of code located in `/lib/football_seasons/caching/*` and `/lib/football_seasons/observers/*`
And just implementation in `lib/football_seasons/seasons/game.ex`.

```
defmodule FootballSeasons.Seasons.Game do
  @moduledoc false

  use Ecto.Schema
  use Observable, :notifier

  <...>
  observations do
    action(:insert, [CacheRecordObserver])
    action(:update, [CacheRecordObserver])
    action(:delete, [CacheRecordObserver])
  end
end
```

Elegant solution of eternal `Cache invalidation` problem. Cache automatically receive data on any CRUD operation.

Also i think that it's important to measure during engineering process. That's why i included performance testing.
Common data is inside [Performance testing](#performance-testing) section. Also API documentation contains
tests and measurements [description](#performance-testing-1).

One of points in exercise is "Document HTTP API". I decided just add description inside [this](#api-documentation) file.
Also separately API documentation is inside `FootballSeasonsWeb.ApiRouter` documentation. Just `mix deps.get && mix docs`
and look at `ApiRouter` documentation.

Also i decided to create completely ready application with authorization.
Basically authorization is not so strict. You can register and instantly login. No email verification.
But it exist.

All work related to:

```
4. Create a Dockerfile for the application
5. Create a Docker Compose file for the application with 1 HAProxy instance load balancing
```

Requirements. Is described in [Docker section](#docker-compose). This part was most difficult for me. 
Because i haven't got experience with it. But finally i have implemented solution that i am really proud of.
In short - i put Elixir releases into docker. It's best practice way to implement containers. So i hope this
point i have done successfully.

It was interesting task. Thanks you. I have got many pleasure doing that. And study something new. And i hope 
you also gonna like it.

Please contact:
    Email:    struan.dirk.29@gmail.com
    LinkedIn: https://www.linkedin.com/in/alexey-kurdyukov/
    Github:   https://github.com/CarefreeSlacker

## Up and running

Requires `elixir 1.8.2` and `erlang 21.1.1`. Necessary versions described in .tool-versions file in root folder.
If you have asdf just `asdf install` from root folder. And wait ... 

# Table of content
  
- [Introduction](#introduction)
- [Contact](#contact)
- [Up and running](#up-and-running)
- [Docker compose](#docker-compose)
- [Performance testing](#performance-testing)
- [API documentation](#api-documentation)
  * [Request ALL games](#request-all-games)
    + [API with Mnesia caching](#api-with-mnesia-caching)
      - [JSON response demonstration](#json-response-demonstration)
      - [Protobuf response demonstration](#protobuf-response-demonstration)
    + [API with Postgres database](#api-with-postgres-database)
      - [JSON response demonstration](#json-response-demonstration-1)
    + [Performance testing](#performance-testing-1)
      - [Measure Postgres API throughput](#measure-postgres-api-throughput)
      - [Measure Mnesia API throughput](#measure-mnesia-api-throughput)
      - [Compare JSON and Protobuf traffic measurements](#compare-json-and-protobuf-traffic-measurements)
    + [Performance testing conclusion](#performance-testing-conclusion)
  * [Technical API for providing `protobuf` protocol deserialization](#technical-api-for-providing-protobuf-protocol-deserialization)
  * [Search games by division and season](#search-games-by-division-and-season)
    + [Search API with Mnesia caching](#search-api-with-mnesia-caching)
      - [JSON response demonstration](#json-response-demonstration-2)
      - [Protobuf response demonstration](#protobuf-response-demonstration-1)
      - [Logs and load testing](#logs-and-load-testing)
    + [Search API with Postgres caching](#search-api-with-postgres-caching)
      - [Logs and load testing. Comparison with Mnesia version.](#logs-and-load-testing-comparison-with-mnesia-version)
* [Technical exercise](#technical-exercise)
  + [Instructions](#instructions)
  + [Requirements](#requirements)
  + [Features](#features)
  + [Data.csv fields description](#datacsv-fields-description)

## Introduction

Hello. I decided to write introduction to show you what is important in that project. To clarify what was my points,
goals and problems during solving this exercise.

It was interesting exercise. And thanks for freedom. I used it to show:
1. Code quality
2. TDD
3. Providing high performance skills
4. Performance testing skills
And of course all this project itself is big story about me as professional.

I think I am "Upper Middle is about to Senior" level. Like to use Elixir and it's functional paradigm.
This project I tried to show as many as i can. 

[Exercise description](#technical-exercise) this is common task description.

Code quality is very important thing i use for it credo `mix credo --strict` and auto formatting `mix format --check-formatted`.
This is minimum necessary steps those still increase code readability and programming experience.

As for TDD this project coverage is `mix test --cover` -> 54.15% . It's not big value, but it's just 
test project. Tests is suitable for long term code. Those will be modified many times in the future. 
For exercise purposes high test coverage is not so necessary. In production i write tests for most of functional.
Moreover tests saved my time many times. For now tests written for business logic. There is lack of tests for 
requests(API requests) but this disadvantage compensates by performance tests located in `performance_testing`
I will talk about that later. 

Also i wanted to show you approach those i used on one of my past projects to design agile 
high performant API. Application have two endpoints. First - Phoenix router `FootballSeasonsWeb.Router`.
Second - Plug router `FootballSeasonsWeb.ApiRouter`.
Phoenix router - provide Admin page.
Plug router - high loaded API requests.
Admin page - use as data source Postgres.
API - use as data source Mnesia.

This architecture allow us:

1. Manage project using Admin page
2. Design complex API requests by using Mnesia query language
3. Provide high performance API with short delays (To measure it i used Load testing)
4. Separate business logic from technical tasks

Besides that I designed solution for automate caching data from postgres to Mnesia.
All of code located in `/lib/football_seasons/caching/*` and `/lib/football_seasons/observers/*`
And just implementation in `lib/football_seasons/seasons/game.ex`.

```
defmodule FootballSeasons.Seasons.Game do
  @moduledoc false

  use Ecto.Schema
  use Observable, :notifier

  <...>
  observations do
    action(:insert, [CacheRecordObserver])
    action(:update, [CacheRecordObserver])
    action(:delete, [CacheRecordObserver])
  end
end
```

Elegant solution of eternal `Cache invalidation` problem. Cache automatically receive data on any CRUD operation.

Also i think that it's important to measure during engineering process. That's why i included performance testing.
Common data is inside [Performance testing](#performance-testing) section. Also API documentation contains
tests and measurements [description](#performance-testing-1).

One of points in exercise is "Document HTTP API". I decided just add description inside [this](#api-documentation) file.
Also separately API documentation is inside `FootballSeasonsWeb.ApiRouter` documentation. Just `mix deps.get && mix docs`
and look at `ApiRouter` documentation.

Also i decided to create completely ready application with authorization.
Basically authorization is not so strict. You can register and instantly login. No email verification.
But it exist.

All work related to:

```
4. Create a Dockerfile for the application
5. Create a Docker Compose file for the application with 1 HAProxy instance load balancing
```

Requirements. Is described in [Docker section](#docker-compose). This part was most difficult for me. 
Because i haven't got experience with it. But finally i have implemented solution that i am really proud of.
In short - i put Elixir releases into docker. It's best practice way to implement containers. So i hope this
point i have done successfully.

It was interesting task. Thanks you. I have got many pleasure doing that. And study something new. And i hope 
you also gonna like it.

## Contact

Please contact:
    Email:    struan.dirk.29@gmail.com
    LinkedIn: https://www.linkedin.com/in/alexey-kurdyukov/
    Github:   https://github.com/CarefreeSlacker

## Up and running

Requires `elixir 1.8.2` and `erlang 21.1.1`. Necessary versions described in .tool-versions file in root folder.
If you have asdf just `asdf install` from root folder. And wait ... 

To start your Phoenix server:

  * Install necessary elixir and erlang versions
  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Create mnesia schema  `mix reset_mnesia_schema`
  * Create database `mix ecto.reset`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Project might not to start still. Because i wrote this documentation on my machine. Might be some 
system packages also required. I tested on Ubuntu 18.4, Core i7, 16 Gb RAM. I am developer. My computer 
is full of some software. So might be i missed some step at installation. If it gonna happen 
I sure you could find solution easily. In other case please [contact](#contact) me. 

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser. Project is empty. But you can
fill it from index page `/games` page by uploading CSV file. Football games statistic 
file in `/priv/Data/Data.csv`.

## Docker

I decided to put project inside container as release. Because it's best practice to build
releases of elixir project in production. Creating container is inside `Dockerfile`. 

Cluster implemented with docker compose. It's configuration is inside `docker-compose.yml`
To run it just `docker-compose build && docker-compose up` from the root of the project.
Sometimes assets does not compile from first build. Than repeat. Everything must works. Tested.

For cluster there was needed Haproxy. So docker image and configuration located in `/haproxy/` folder.  

## Performance testing

I have decided to implement high performant API. To provide it i put data about all games into Mnesia table.   
Most of code related to this purpose located in `/football_seasons/lib/football_seasons/caching/`.    
Each record in Mnesia contains game statistics and cached JSON and Protobuf versions those return
to API clients.    
API requests handled by plug router `FootballSeasonsWeb.ApiRouter`.    
To compare high performant and usual version of API i added `/api/db_seasons` where data gets from DB.    
Basically most of the time during processing does not spent into requesting to database.    
The most time and resources consuming is `Jason.encode!()`.    
Anyway cached version is ~60 times faster.    
To make sure you can run performance tests. 

**Algorithm**
1. First please install k6 https://docs.k6.io/docs/installation
2. From the root run tests for simple API `k6 run --duration 30s --rps 2000 --vus 300 performance_testing/simple_api_testing.js`
3. From the root run tests for high performant API `k6 run --duration 30s --rps 2000 --vus 300 performance_testing/fast_api_testing.js`
4. From the root run tests for searching simple API `k6 run --duration 30s --rps 2000 --vus 300 performance_testing/simple_api_search_testing.js`
5. From the root run tests for searching high performant API `k6 run --duration 30s --rps 2000 --vus 300 performance_testing/fast_api_search_testing.js`
6. From the root run tests for protobuf project `k6 run --duration 30s --rps 2000 --vus 300 performance_testing/protobuf_fast_api_testing.js`

After finishing each test prints report with metrics.
Thre most valuable here is:

```
iteration_duration.........: avg=375.94ms min=65.67ms med=340.09ms max=1.42s   p(90)=565.05ms p(95)=652.63ms
iterations.................: 20377  679.231868/s
```

`iterations per second` and `median iteration duration`

For requesting all games difference twice(Cached version carry twice more requests per second).
For searching by division and season Cached version carry four time more requests. And median request duration is three times less.   

Difference is not so dramatic but it's only first version written in couple of hours, without any optimizations.
It could be faster. I just wanted to show approach that I have been used.

## Api documentation

Allow to fetch all games or search games by division and/or season.
Support JSON and Protobuf protocols.
It's project working horse. Handling payload.
Exercise have been minimalistic and was not restricted.
So i decided to show you trick i have used during solving some problem during my past job.
My purpose was providing better performance API. To achieve that I have used Mnesia <-> Plug schema.
Reading\\Writing to HDD is slowest process through all PC activity. Because it's the last moving part.
So moving all data to RAM will increase searching velocity. That's why i have chosen Mnesia as caching system.
The additional trade-offs is agility for using. We could increase complexity of the requests we might design.
Mnesia provides solid query language allowing to design complicated requests.

But it's just my hypothesis to verify it we must measure.
Except solving exercise this module gonna demonstrate my my skill: Load testing.

So there are three types of requests:

1. Workload;
2. Same as Workload tests but fetching data from Postgres Database;
3. Technical for providing `protobuf` protocol deserialization.

# API documentation

Accept all requests without any authorization. Could return `JSON` or `Protobuf` values. Provide Protobuf schema.
In development mode uses `4001` port by default. Configured in :football_seasons -> :plug_configuration -> :api_port.

## Request ALL games

### API with Mnesia caching

Request `GET /api/seasons`. Accept params as get params. For example `GET /api/seasons?protocol=protobuf`.
Accepted GET parameters:

1. `protocol` - Optional. Response serialization protocol. Allowed values: 'protobuf', 'json'.

Return all games in requested format `JSON` by default. Support two serialization protocols: `JSON`, `Protobuf`.
Protobuf schema is provided by different request `GET /api/seasons/schema`. Fetch data from Mnesia.

Params send as GET parameter. For example

#### JSON response demonstration

**->** `GET /api/seasons`

**<-**

```
[
  {
    "away_team_name":"Essex",
    "date":"2014-01-01",
    "division":"SP1",
    "ftag":7,
    "fthg":10,
    "ftr":"home",
    "home_team_name":"Cowex",
    "htag":7,
    "hthg":6,
    "htr":"away",
    "season":"201920",
  },
  {
    "away_team_name":"Eibar",
    "date":"2016-08-19",
    "division":"SP1",
    "ftag":1,
    "fthg":2,
    "ftr":"home",
    "home_team_name":"La Coruna",
    "htag":0,
    "hthg":0,
    "htr":"draw",
    "season":"201617",
  }
]
```

#### Protobuf response demonstration

**->** `GET /api/seasons?protocol=protobuf`

**<-**

```
<Binary encoded>
```

### API with Postgres database

Return all games in requested format `JSON` by default. Support two serialization protocols: `JSON`, `Protobuf`.
Fetch data from Postgres.

Request `GET /api/db_seasons`. Accept params as get params.
Accepted GET parameters:

1. `protocol` - Optional. Response serialization protocol. Allowed values: 'protobuf', 'json'.

#### JSON response demonstration

**->** `GET /api/db_seasons`

**<-**

```
[
  {
    "away_team_name":"Essex",
    "date":"2014-01-01",
    "division":"SP1",
    "ftag":7,
    "fthg":10,
    "ftr":"home",
    "home_team_name":"Cowex",
    "htag":7,
    "hthg":6,
    "htr":"away",
    "season":"201920",
  },
  {
    "away_team_name":"Eibar",
    "date":"2016-08-19",
    "division":"SP2",
    "ftag":1,
    "fthg":2,
    "ftr":"home",
    "home_team_name":"La Coruna",
    "htag":0,
    "hthg":0,
    "htr":"draw",
    "season":"201617",
  }
]
```

As you see - the same. The same result for `Protobuf` protocol. This is the point. **No difference**. Except
fetching data method. Here every request perform database request and serialize each record to `JSON` object.
Or to `Protobuf`.

This API added to demonstrate requests processing speed.

```
12:20:14.033 [debug] GET /api/db_seasons                              # <= Request to this API.
12:20:14.057 [debug] QUERY OK source="games" <...> "games" AS g0 []   # <= Here is request to database
12:20:14.092 [debug] Sent 200 in 59ms                                 # <= Postgres request speed
12:20:21.433 [debug] GET /api/seasons                                 # <= Request to cached version. To database requests
12:20:21.436 [debug] Sent 200 in 2ms                                  # <= Mnesia request speed
```

As you see time ~30 (59 ms and 2 ms approximately) times faster.

### Performance testing

In this section we gonna compare two API versions with Postgres and Mnesia using k6 load testing tool.
Besides that we gonna compare JSON and Protobuf output data size.

First install https://github.com/loadimpact/k6. Then you can run scripts in `performance_testing/` folder.

#### Measure Postgres API throughput

Run testing script for API with Postgres. Params `--rps` and `--vus` means "requests per second"
and "virtual users" accordingly.

```
$> k6 run --duration 30s --rps 2000 --vus 300 performance_testing/simple_api_testing.js
```

**->**

```
data_received..............: 610 MB 20 MB/s
data_sent..................: 494 kB 16 kB/s
<...>
http_reqs..................: 5960   198.66376/s
iteration_duration.........: avg=1.41s    min=123.29ms med=262.04ms max=5.47s   p(90)=4.13s    p(95)=4.4s
iterations.................: 5195   173.166286/s # <= Here is important metric. ~173 requests per second.
```

This is what does logs looks like:

```
12:42:26.179 [debug] GET /api/db_seasons
12:42:26.191 [debug] Sent 200 in 51ms
12:42:26.199 [debug] QUERY OK source="games" db=19.2ms decode=0.1ms queue=0.1ms
SELECT g0."id", g0."division", g0."season", g0."date", g0."home_team_id", g0."away_team_id", g0."fthg", g0."ftag", g0."hthg", g0."htag", g0."inserted_at", g0."updated_at" FROM "games" AS g0 []
12:42:26.199 [debug] GET /api/db_seasons
12:42:26.208 [debug] Sent 200 in 48ms
12:42:26.216 [debug] QUERY OK source="games" db=16.6ms
SELECT g0."id", g0."division", g0."season", g0."date", g0."home_team_id", g0."away_team_id", g0."fthg", g0."ftag", g0."hthg", g0."htag", g0."inserted_at", g0."updated_at" FROM "games" AS g0 []
12:42:26.219 [debug] GET /api/db_seasons
12:42:26.232 [debug] Sent 200 in 53ms
12:42:26.237 [debug] QUERY OK source="games" db=17.5ms
SELECT g0."id", g0."division", g0."season", g0."date", g0."home_team_id", g0."away_team_id", g0."fthg", g0."ftag", g0."hthg", g0."htag", g0."inserted_at", g0."updated_at" FROM "games" AS g0 []
12:42:26.239 [debug] GET /api/db_seasons
12:42:26.244 [debug] Sent 200 in 45ms
```

During load testing you can look at logs. There will be a lot of errors. But project still working under pressure.
Process some part of requests. With delay. Soft realtime (tm).

#### Measure Mnesia API throughput

Run load test for API with Mnesia.

```
$> k6 run --duration 30s --rps 2000 --vus 300 performance_testing/fast_api_testing.js
```

**->**

```
data_received..............: 16 GB  521 MB/s      # <= Please remember this metric. We gonna compare it soon.
data_sent..................: 3.4 MB 115 kB/s
<...>
http_reqs..................: 37464  1248.790745/s
iteration_duration.........: avg=238.52ms min=4.39ms   med=217.81ms max=772.55ms p(90)=369.28ms p(95)=420.81ms
iterations.................: 37464  1248.790745/s # <= As you see iterations amount increased ~7 times.
                                                  #    And it's first algorithm version without any optimisations.
```

This is what does logs looks like:

```
12:31:27.628 [debug] Sent 200 in 40ms
12:31:27.631 [debug] Sent 200 in 43ms
12:31:27.632 [debug] Sent 200 in 12ms
12:31:27.632 [debug] Sent 200 in 44ms
12:31:27.641 [debug] Sent 200 in 46ms
12:31:27.641 [debug] Sent 200 in 46ms
12:31:27.641 [debug] Sent 200 in 12ms
```

#### Compare JSON and Protobuf traffic measurements

This test send same requests as previous except it have get GET parameter `?protocol=protobuf`.

```
$> k6 run --duration 30s --rps 2000 --vus 300 performance_testing/protobuf_fast_api_testing.js
```

**->**

```
data_received..............: 8.0 GB 268 MB/s          # <= This metric means total received traffic and it's twice less.
data_sent..................: 5.8 MB 192 kB/s
<...>
http_reqs..................: 52295  1743.163497/s
iteration_duration.........: avg=171.34ms min=8.61ms  med=158.46ms max=595.56ms p(90)=245.13ms p(95)=309.28ms
iterations.................: 52295  1743.163497/s     # <= Iterations per seconds also increased.
```

This is what does logs looks like:

```
12:51:06.761 [debug] GET /api/seasons
12:51:06.762 [debug] GET /api/seasons
12:51:06.762 [debug] GET /api/seasons
12:51:06.762 [debug] GET /api/seasons
12:51:06.764 [debug] Sent 200 in 10ms
12:51:06.768 [debug] Sent 200 in 14ms
12:51:06.768 [debug] Sent 200 in 13ms
12:51:06.768 [debug] GET /api/seasons
12:51:06.769 [debug] Sent 200 in 15ms
12:51:06.770 [debug] Sent 200 in 14ms
12:51:06.771 [debug] Sent 200 in 17ms
12:51:06.772 [debug] Sent 200 in 20ms
```

Here we also can see request processing duration is ~3 times faster.

### Performance testing conclusion

It's just first version of measurement. It's not so true because we haven't measured during long time. There our API
might behave different. But it's good starting point for further optimisation for providing: Productivity |> Reliability |> Performance.

Now we can conclude:

1. Chosen request processing (Mnesia <-> Plug) schema works well
2. Elixir\\OTP provide soft real time out of the box
3. Project works well under big load
4. It migh support ~1500 requests per second on my local machine(Core i7 6700, 16 GB RAM.)
5. During measurement using `:observer.start` we found out that CPU is bottleneck. Because we have chosen mnesia
It's necessary to perform a lot of calculations. So server must have enough powerfull CPU. Industrial CPU is ideal
6. RAM is not big problem. But it's just short test. During endurance testing we might reveal problems
7. Using right load testing tool it awesome https://github.com/loadimpact/k6

```
        /\      |‾‾|  /‾‾/  /‾/
   /\  /  \     |  |_/  /  / /
  /  \/    \    |      |  /  ‾‾\
 /          \   |  |‾\  \ | (_) |
/ __________ \  |__|  \__\ \___/ .io
```

Very helpful. <3

## Technical API for providing `protobuf` protocol deserialization

Protobuf schema is looks like:

```
message Game {
  required string division = 1;
  required string season = 2;
  required string date = 3;
  required string home_team_name = 4;
  required string away_team_name = 5;
  required int32 hthg = 6;
  required int32 htag = 7;

  enum TeamResult {
      draw = 0;
      home = 1;
      away = 2;
  }

  required string htr = 8;
  required int32 fthg = 9;
  required int32 ftag = 10;
  required string ftr = 11;
}
```

You can get it on:

**->** `GET /api/seasons/schema`

**<-**

```
<*.proto file>
```

## Search games by division and season

### Search API with Mnesia caching

Request `GET /api/seasons/search`. Accept params as get params.
Accepted GET parameters:

1. `protocol` - Optional. Response serialization protocol. Allowed values: 'protobuf', 'json'.
2. `division` - Required. Game division. String. For example: 'SP1', 'SP2', 'D1'
3. `season` - Required. Game division. String. For example: '201718', '201819'.

`division` and `season` parameters required. Always there is must be at least one of them. If there will be none
response will return empty list. In case if no results also return empty list.

Return all games in requested format `JSON` by default.

Params send as GET parameter. For example

#### JSON response demonstration

**->** `GET /api/seasons/search?division=SP1&season=201617`

**<-**

```
[
  {
    "away_team_name":"Essex",
    "date":"2014-01-01",
    "division":"SP1",
    "ftag":7,
    "fthg":10,
    "ftr":"home",
    "home_team_name":"Cowex",
    "htag":7,
    "hthg":6,
    "htr":"away",
    "season":"201617",
  },
  {
    "away_team_name":"Eibar",
    "date":"2016-08-19",
    "division":"SP1",
    "ftag":1,
    "fthg":2,
    "ftr":"home",
    "home_team_name":"La Coruna",
    "htag":0,
    "hthg":0,
    "htr":"draw",
    "season":"201617",
  }
]
```

#### Protobuf response demonstration

**->** `GET /api/seasons/search?division=SP1&season=201617&protocol=protobuf`

**<-**

```
<Binary encoded>
```

#### Logs and load testing

Here we also gonna compare results between Mnesia and and Postgres data source. Fot that we need metadata
from logs and load testing measurements.

Logs looks like:

```
13:39:16.440 [debug] GET /api/seasons/search
13:39:16.442 [debug] Sent 200 in 1ms
13:47:00.810 [debug] GET /api/seasons/search
13:47:00.811 [debug] Sent 200 in 1ms
```

Nothing unusual. Please remember request duration `1ms`. Load testing run:

```
k6 run --duration 30s --rps 2000 --vus 300 performance_testing/fast_api_search_testing.js
```

**->**

```
data_received..............: 2.2 GB 74 MB/s       # <= If you compare size with /api/seasons you gonna see that
data_sent..................: 7.4 MB 248 kB/s      #    it is less. Because response return only distinct
<...>                                             #    by division and season games
iteration_duration.........: avg=151.39ms min=5.71ms   med=149.8ms max=543.64ms p(90)=162.09ms p(95)=182.35ms
iterations.................: 59262  1975.39572/s  # <= Almost ~2000 requests. Faster than /api/seasons.
```

### Search API with Postgres caching

Request `GET /api/db_seasons/search`. Accept params as get params.
Accepted GET parameters:

1. `protocol` - Optional. Response serialization protocol. Allowed values: 'protobuf', 'json'.
2. `division` - Required. Game division. String. For example: 'SP1', 'SP2', 'D1'
3. `season` - Required. Game division. String. For example: '201718', '201819'.

`division` and `season` parameters required. Always there is must be at least one of them. If there will be none
response will return empty list. In case if no results also return empty list.

Return all games in requested format `JSON` by default.

Response is the same as `GET /api/seasons/search`

#### Logs and load testing. Comparison with Mnesia version.

Running request

**->** `GET /api/db_seasons/search?division=SP1&season=201617`

**<-**

```
13:57:07.371 [debug] GET /api/db_seasons/search
13:57:07.376 [debug] QUERY OK source="games" db=4.6ms queue=0.1ms
SELECT g0."id", g0."division", g0."season", g0."date", g0."home_team_id", g0."away_team_id", g0."fthg", g0."ftag", g0."hthg", g0."htag", g0."inserted_at", g0."updated_at" FROM "games" AS g0 WHERE ((g0."division" = $1) AND (g0."season" = $2)) ["SP1", "201617"]
13:57:07.381 [debug] Sent 200 in 9ms
13:57:30.808 [debug] GET /api/db_seasons/search
13:57:30.816 [debug] QUERY OK source="games" db=7.6ms queue=0.1ms
SELECT g0."id", g0."division", g0."season", g0."date", g0."home_team_id", g0."away_team_id", g0."fthg", g0."ftag", g0."hthg", g0."htag", g0."inserted_at", g0."updated_at" FROM "games" AS g0 WHERE ((g0."division" = $1) AND (g0."season" = $2)) ["SP1", "201617"]
13:57:30.822 [debug] Sent 200 in 14ms
```

We can notice that postgres database requests added. And request duration `9, 14 ms`. It's ~12 times slower than cached Mnesia version.

And finally run load test:

```
$> k6 run --duration 30s --rps 2000 --vus 300 performance_testing/simple_api_search_testing.js
```

**->**

```
data_received..............: 481 MB 16 MB/s        # <= Less than previous example because of less requests.
data_sent..................: 3.2 MB 105 kB/s
<...>
iteration_duration.........: avg=362.89ms min=8.48ms med=330.99ms max=1.56s   p(90)=539.1ms  p(95)=611.03ms
iterations.................: 24603  820.098239/s   # <= Compare to /api/seasons/search ~2.5 times slower.
```

And we see significant difference between Mnesia and Postgres version Q.E.D.

# Technical exercise

## Instructions

Write a simple Elixir application that serves the football results included in the attached data.csv file.
The application must expose a public HTTP API allowing users to:
1. List the league and season pairs (e.g. La Liga 2017-2018) for which there are results available
2. Fetch the results for a specific league and season pair    
3. Users must be able to retrieve the results for a specific league and season pair formatted in JSON and Protocol Buffers

As for the technology stack, you are free to choose the libraries and frameworks that you consider most appropriate to solve this exercise.
We have kept the requirements to a bare minimum. 
We do not want you to overdo the solution, but we also want you to have an opportunity to show us all the tricks you know. 
Feel free to add as many optional features as you deem necessary but make sure that you get the required steps right first. 
Use this opportunity wisely and do not hesitate to contact us should you have any questions.

## Requirements

1. You have 1 week to send us the solution to the exercise, you may submit it earlier if you’d
finish it within this given time
2. Document the solution to make it easy to onboard new developers to the project
3. Document the HTTP API
4. Create a Dockerfile for the application
5. Create a Docker Compose file for the application with 1 HAProxy instance load balancing
traffic across 3 instances of the application
6. (Bonus) Create the Kubernetes deployment, service and ingress files required to replace the
above Docker Compose environment
7. (Bonus) Code instrumentation (e.g. logging, metrics)

## Features

1. **+** Documented HTTP Api;
2. **+** API could response with JSON or ProtocolBuffers;
3. **+** High performant api(see Performance Testing);
4. **-** Use LiveView for displaying data in web forms;
5. **+** Have administrator page;
6. **+** Load data with forms or by downloading CSV files;
7. **-** (optional) logging system.

Not all scheduler features have implemented. But it's still good result.

## Data.csv fields description

Div = League Division    
Season = Footbal season (2016-2017 -> 201617)    
Date = Match Date (dd/mm/yy)   
HomeTeam = Home Team  
AwayTeam = Away Team  
FTHG and HG = Full Time Home Team Goals  
FTAG and AG = Full Time Away Team Goals  
FTR and Res = Full Time Result (H=Home Win, D=Draw, A=Away Win)  
HTHG = Half Time Home Team Goals  
HTAG = Half Time Away Team Goals  
HTR = Half Time Result (H=Home Win, D=Draw, A=Away Win)
