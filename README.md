 <!-- badges: start -->
  [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
  <!-- badges: end -->

# {airball}
An R package to calculate common schedule & travel metrics for NBA teams.

<img src="man/airballlogo.PNG" align="right" width="300" />

***

## Intro

The impact of schedule density and fixture congestion on team performance and injury risk is frequently discussed in various different sports and leagues around the world. **{airball}** provides a set of functions to quickly compute common schedule and travel related metrics from publicly available resources, both at a team and individual player level.

The motivation behind this package is to provide practitioners wishing to model schedule and travel data with tools to facilitate the extraction of several common metrics such as distance traveled, time zone changes, flight duration, routes, number rest days, location coordinates, etc.

**{airball}** is currently under development and only provides information for NBA teams. The goal is to expand to other leagues and sports over time.

## Installation

```{r}
#Install from CRAN 
#Currently underdevelopment and not on CRAN

  
#Install the development version from GitHub  
install.packages("devtools")
devtools::install_github("josedv82/airball")
```

## Usage

### To extract metrics for NBA teams and players:

There are currently two functions to help extract travel and schedule related metrics for NBA teams and players. It is important to highlight and credit Alex Bresler and his package [**{nbastatR}**](https://github.com/abresler/nbastatR) as I rely on his function [`game_logs()`](https://rdrr.io/github/abresler/nbastatR/man/game_logs.html) to query NBA schedule data from the [NBA Stats](https://www.nba.com/stats/players/boxscores/) website.

### Team Metrics:

To get travel and schedule metrics:

```{r}
nba_travel(season = 2017,
           team = c("Los Angeles Lakers", "Boston Celtics"),
           return_home = 3,
           phase = "RS",
           flight_speed = 550)
```

The `nba_travel()` function accepts 5 arguments:

* season: A number or a vector of seasons for multiple seasons. For example `2002` or `c(2005:2008)`. If not set it defaults to 2018.
* team: The name of the team to explore or a vector of teams for multiple teams. If not set it defaults to all teams in the selected season.
* return_home: A number. Users can add a return home trip if two consecutive away games are separated by 'x' number of days. This helps improve the total mileage accuracy.
* phase: The phase of the season to download. *RS* for regular season, *PO* for playoffs or *c("RS", "PO")* for both. It defaults to both if not set.
* flight_speed: Users can set an average flight speed. This parameter is used to calculate estimated flight duration. It defaults to 450 (mph) if not set.


**under development...more info soon
