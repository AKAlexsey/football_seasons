# FootballSeasons

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Technical test

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
3. **-** Carry big load. 3000 requests per second;
4. **-** Use LiveView for displaying data in web forms;
5. **-** Have administrator page;
6. **-** Load data with forms or by downloading CSV files.

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
