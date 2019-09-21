# FootballSeasons

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Create mnesia schema  `mix reset_mnesia_schema`
  * Create database `mix ecto.reset`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Performance testing

I have decided to implement high performant API. To provide it i put data about all games into Mnesia table.   
Most of code related to this purpose located in `/football_seasons/lib/football_seasons/caching/`.    
Each record in Mnesia contains game statistics teams names and cached JSON and Protobuf versions those response
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
6. From the root run tests for protobuf project `k6 run --duration 30s --rps 2000 --vus 300 performance_testing/protobuf_simple_api_testing.js`

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

## Handle API requests.

  # Common description

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

  Yes it's little bit wrong that module have three purposes for existing:
  1. Handle requests;
  2. Compare requests speed between database and cache system;
  3. Demonstrate performance testing skill.
  But it's quite expressively describe how does project works.

  So there are three types of requests:

  1. Workload;
  2. Cached version velocity Demonstration;
  3. Technical for providing `protobuf` protocol deserialization.

  # API documentation

  Accept all requests without any authorization. Could return `JSON` or `Protobuf` values. Provide Protobuf schema.
  In development mode uses `4001` port by default.

  ## Workload

  ### `GET /api/seasons`

  Return all seasons in requested format `JSON` by default. Support two serialization protocols: `JSON`, `Protobuf`.
  Protobuf schema is provided by different request `GET /api/seasons/schema`.

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

  As you see usual JSON. And here is example for `Protobuf` protocol.

  **->** `GET /api/seasons?protocol=protobuf`

  **<-**

  ```
  <Binary encoded file>
  ```

  ## Cached version velocity Demonstration

  ### `GET /api/db_seasons`

  Return all seasons in requested format `JSON` by default. Support two serialization protocols: `JSON`, `Protobuf`.
  Protobuf schema is provided by different request `GET /api/seasons/schema`.

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

  As you see - the same. The same result for `Protobuf` protocol. This is the point. **No difference**. Except
  requesting data method. Here every request perform database request and serialize each record to `JSON` object. Or to
  `Protobuf`

  This API added to demonstrate requests processing speed.

  ```
  12:20:14.033 [debug] GET /api/db_seasons                              # <= Request to this API.
  12:20:14.057 [debug] QUERY OK source="games" <...> "games" AS g0 []   # <= Here is request to database
  12:20:14.092 [debug] Sent 200 in 59ms                                 # <= Postgres request speed
  12:20:21.433 [debug] GET /api/seasons                                 # <= Request to cached version. To database requests
  12:20:21.436 [debug] Sent 200 in 2ms                                  # <= Mnesia request speed
  ```

  Moreover `Perofmrnace Testing` shows how throughput of the project.

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

  And now we gonna compare with fast requests:

  ```
  $> k6 run --duration 30s --rps 2000 --vus 300 performance_testing/fast_api_testing.js
  ```

  **->**

  ```
  data_received..............: 16 GB  521 MB/s
  data_sent..................: 3.4 MB 115 kB/s
  <...>
  http_reqs..................: 37464  1248.790745/s
  iteration_duration.........: avg=238.52ms min=4.39ms   med=217.81ms max=772.55ms p(90)=369.28ms p(95)=420.81ms
  iterations.................: 37464  1248.790745/s # <= As you see iterations amount increased 10 times.
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

  And the final point here is measuring `Protobuf` traffic:


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

  Here we also can see request processing duration.

  ### Performance testing conclusion

  It's just first version of measurement. It's not so true because we haven't measured during long time. There our API
  might behave different. But it's good starting point for further optimisation for providing: Productivity |> Reliability |> Speed.

  Now we can conclude:

  1. Chosen request processing algorithm works well
  2. Elixir\\OTP provide soft real time out of the box
  3. Project works well under big load
  4. It migh support ~1500 requests per second on my local machine(Core i7 6700, 16 GB RAM.)
  5. During measurement using `:observer.start` we found out that CPU is bottleneck. Because we have chosen mnesia.
  It's necessary to perform a lot of calculations. So server must have enough powerfull CPU. Industrial CPU is ideal.
  6. RAM is not big problem. But it's just short test. During endurance testing we might reveal problems.
  7. Using right load testing tool it awesome https://github.com/loadimpact/k6:

  ```
          /\\      |‾‾|  /‾‾/  /‾/
     /\\  /  \\     |  |_/  /  / /
    /  \\/    \\    |      |  /  ‾‾\\
   /          \\   |  |‾\\  \\ | (_) |
  / __________ \\  |__|  \\__\\ \\___/ .io
  ```

  Very helpful. <3

  ## Technical for providing `protobuf` protocol deserialization

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

## Technical exercise

### Instructions

Write a simple Elixir application that serves the football results included in the attached data.csv file.
The application must expose a public HTTP API allowing users to:
1. List the league and season pairs (e.g. La Liga 2017-2018) for which there are results available
2. Fetch the results for a specific league and season pair
Users must be able to retrieve the results for a specific league and season pair formatted in JSON and Protocol Buffers.
As for the technology stack, you are free to choose the libraries and frameworks that you consider most appropriate to solve this exercise.
We have kept the requirements to a bare minimum. 
We do not want you to overdo the solution, but we also want you to have an opportunity to show us all the tricks you know. 
Feel free to add as many optional features as you deem necessary but make sure that you get the required steps right first. 
Use this opportunity wisely and do not hesitate to contact us should you have any questions.

### Requirements

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

### Features

1. **+** Documented HTTP Api;
2. **+** API could response with JSON or ProtocolBuffers;
3. **+** High performant api(see Performance Testing);
4. **-** Use LiveView for displaying data in web forms;
5. **+** Have administrator page;
6. **+** Load data with forms or by downloading CSV files;
7. **-** (optional) logging system.

### Data.csv fields description

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
