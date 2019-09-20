# FootballSeasons

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Create mnesia schema  `mix reset_mnesia_schema`
  * Create database `mix ecto.reset`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

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

1. **-** Documented HTTP Api;
2. **-** API could response with JSON or ProtocolBuffers;
3. **+** High performant api(see Performance Testing);
4. **-** Use LiveView for displaying data in web forms;
5. **+** Have administrator page;
6. **+** Load data with forms or by downloading CSV files.

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
