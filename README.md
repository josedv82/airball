 <!-- badges: start -->
  [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
  [![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
  <!-- badges: end -->

# {airball}
An R package to extract common NBA schedule & travel metrics for modeling purposes.

<img src="man/images/airballlogo.PNG" align="right" width="300" />

***

## 1) Intro

The impact of schedule density and fixture congestion on team performance and injury risk is frequently discussed in various different sports and leagues around the world. **{airball}** provides a set of functions to quickly compute common schedule and travel related metrics from publicly available resources, both at a team and individual player level.

The motivation behind this package is to provide practitioners wishing to model schedule and travel data with tools to facilitate the extraction of several common metrics such as distance traveled, time zone changes, flight duration, routes, number of rest days, location coordinates, etc.  

The package is currently under development and only provides information for NBA teams. The goal is to expand to more leagues over time.

## 2) Installation

```{r}
#Install from CRAN 
#Not currently on CRAN

  
#Install the development version from GitHub  
install.packages("devtools")
devtools::install_github("josedv82/airball")
```

## 3) Usage

### To extract metrics for NBA teams and players:

There are currently two functions to help extract travel and schedule related metrics for NBA teams and players. 

* `nba_travel()`
* `nba_player_travel()`

Before explaining those two functions, I'd like to credit Alex Bresler and his package [**{nbastatR}**](https://github.com/abresler/nbastatR) as I have embedded one of the functions he wrote [`game_logs()`](https://rdrr.io/github/abresler/nbastatR/man/game_logs.html) within my code to query NBA schedule data from the [NBA Stats](https://www.nba.com/stats/players/boxscores/) website.

### 4) Team Metrics:

To get travel and schedule metrics:

```
nba_travel(start_season = 2017,
           end_season = 2020,
           team = c("Los Angeles Lakers", "Boston Celtics"),
           return_home = 3,
           phase = "RS",
           flight_speed = 550)
           
           
# A tibble: 640 x 22
# Groups:   Season, Team [8]
   Season Phase Month  Week Date       Team  Opponent Location `W/L` City  Distance[,1] Route[,1]  Rest TZ   
   <chr>  <chr> <chr> <dbl> <date>     <chr> <chr>    <chr>    <chr> <chr>        <dbl> <chr>     <dbl> <chr>
 1 2016-~ RS    Oct      43 2016-10-26 Bost~ Brookly~ Home     W     Bost~            0 No Travel    15 Amer~
 2 2016-~ RS    Oct      43 2016-10-27 Bost~ Chicago~ Away     L     Chic~          854 Boston -~     0 Amer~
 3 2016-~ RS    Oct      44 2016-10-29 Bost~ Charlot~ Away     W     Char~          589 Chicago ~     1 Amer~
 4 2016-~ RS    Nov      44 2016-11-02 Bost~ Chicago~ Home     W     Bost~          722 Charlott~     3 Amer~
 5 2016-~ RS    Nov      44 2016-11-03 Bost~ Clevela~ Away     L     Clev~          551 Boston -~     0 Amer~
 6 2016-~ RS    Nov      45 2016-11-06 Bost~ Denver ~ Home     L     Bost~          551 Clevelan~     2 Amer~
 7 2016-~ RS    Nov      45 2016-11-09 Bost~ Washing~ Away     L     Wash~          394 Boston -~     2 Amer~
 8 2016-~ RS    Nov      46 2016-11-11 Bost~ New Yor~ Home     W     Bost~          394 Washingt~     1 Amer~
 9 2016-~ RS    Nov      46 2016-11-12 Bost~ Indiana~ Away     W     Indi~          807 Boston -~     0 Amer~
10 2016-~ RS    Nov      46 2016-11-14 Bost~ New Orl~ Away     L     New ~          704 Indianap~     1 Amer~
# ... with 630 more rows, and 8 more variables: `Shift (hrs)`[,1] <dbl>, `Flight Time` <chr>, `Direction (E/W)`[,1] <chr>,
#   `Return Home` <chr>, Latitude <dbl>, Longitude <dbl>, d.Latitude <dbl>, d.Longitude <dbl>
```

The `nba_travel()` function accepts 5 arguments:

* **start_season**: A number for the first season to explore. For example `2002`. If not set it defaults to 2018.
* **end_season**: A number. The final season to explore. For example `2015`. If not set it defaults to `2018`
* **team**: The name of the team to explore or a vector of teams for multiple teams. If not set it defaults to all teams in the selected season.
* **return_home**: A number. Users can add a return home trip if two consecutive away games are separated by 'x' number of days. This helps improve the total mileage accuracy.
* **phase**: The phase of the season to download. *RS* for regular season, *PO* for playoffs or *c("RS", "PO")* for both. It defaults to both if not set.
* **flight_speed**: Users can set an average flight speed. This parameter is used to calculate estimated flight duration. It defaults to 450 (mph) if not set.

It returns a data frame with multiple travel metrics including: 

* distance, 
* route, 
* rest days, 
* time zone, 
* time zone change (shift), 
* estimate flight duration, 
* direction of travel, 
* whether it is a return home flight 
* origin and destination city coordinates
* etc

**Note**: If you are pulling up to the current season (i.e. 2021) it will show future games that have not been played yet, allowing users to check future schedule metrics. If this is the case, it is recommended to pull the most recent season along with the previous to avoid potential download errors. So,  for example, set ```start_season = 2020``` and ```end_season = 2021``` instead of ```start_season = 2021```  

### 5) Player Metrics:

To get travel and schedule metrics for one or various players use:

```{r}

nba_player_travel(start_season = 2018,
                  end_season = 2020,
                  return_home = 4,
                  team = "Cleveland Cavaliers",
                  player = "Jose Calderon")
                  

# A tibble: 70 x 42
# Groups:   Season, Player [1]
   Season Phase Date       Team  Opponent Location City  `W/L` Route[,1] Distance[,1] TZ    `Flight Time` `Direction (E/W~
   <chr>  <chr> <date>     <chr> <chr>    <chr>    <chr> <chr> <chr>            <dbl> <chr> <chr>         <chr>           
 1 2017-~ RS    2017-10-20 Clev~ Milwauk~ Away     Milw~ W     Clevelan~          340 Amer~ ~55 minutes   West            
 2 2017-~ RS    2017-10-21 Clev~ Orlando~ Home     Clev~ L     Milwauke~          340 Amer~ ~55 minutes   East            
 3 2017-~ RS    2017-10-25 Clev~ Brookly~ Away     New ~ L     Clevelan~          407 Amer~ ~55 minutes   -               
 4 2017-~ RS    2017-10-28 Clev~ New Orl~ Away     New ~ L     New York~         1158 Amer~ ~2.57 hours   West            
 5 2017-~ RS    2017-10-29 Clev~ New Yor~ Home     Clev~ L     New Orle~          913 Amer~ ~2.03 hours   East            
 6 2017-~ RS    2017-11-01 Clev~ Indiana~ Home     Clev~ L     No Travel            0 Amer~ -             -               
 7 2017-~ RS    2017-11-17 Clev~ Los Ang~ Home     Clev~ W     Charlott~          437 Amer~ ~58.27 minut~ -               
 8 2017-~ RS    2017-11-20 Clev~ Detroit~ Away     Detr~ W     Clevelan~           96 Amer~ ~55 minutes   -               
 9 2017-~ RS    2017-11-22 Clev~ Brookly~ Home     Clev~ W     Detroit ~           96 Amer~ ~55 minutes   -               
10 2017-~ RS    2017-11-24 Clev~ Charlot~ Home     Clev~ W     No Travel            0 Amer~ -             -               
# ... with 60 more rows, and 29 more variables: `Return Home` <chr>, Player <chr>, `Team Rest` <dbl>, `Player Rest` <dbl>,
#   `Games Played` <int>, MINs <dbl>, PTS <dbl>, `Shift (hrs)`[,1] <dbl>, fgm <dbl>, fga <dbl>, pctFG <dbl>, fg3m <dbl>,
#   fg3a <dbl>, pctFG3 <dbl>, pctFT <dbl>, fg2m <dbl>, fg2a <dbl>, pctFG2 <dbl>, ftm <dbl>, fta <dbl>, oreb <dbl>,
#   dreb <dbl>, treb <dbl>, ast <dbl>, stl <dbl>, blk <dbl>, tov <dbl>, pf <dbl>, plusminus <dbl>

```

It works like `nba_travel()` but it adds one more argument (player). Users can set it to one player, a vector of players or leave blank, in which case it defaults to all players in the selected query. 

It returns the same metrics as the previous function and adds individidual factors such as

* individual rest
* individual games played
* minutes played
* several common individual game stats (points, rebounds, assists, turn overs, etc).
  
**Note:** This function does not return future games. It only returns up to the most recent played game, since it requires individual player game stats for it to work.
  
`*The first season available for both of the above functions is 1947.*`


### 6) Flight Paths Plot

To plot the estimated flight paths for the selected season and team(s) use `nba_travel_plot()`. This function accepts the result of `nba_travel()` and returns a ggplot object that can be further customized by the user.

```{r}

#example with just 2 teams

datos <- nba_travel(start_season = 2015, end_season = 2018)
nba_travel_plot(data = datos,
                season = 2017,
                team = c("Boston Celtics", "Miami Heat"),
                city_color = "white",
                plot_background_fill = "black",
                land_color = "gray",
                caption_color = "lightblue",
                ncolumns = 2)

```

<img src="man/images/plot2.png" width="800" />


```{r}

#example with all 30 teams

nba_travel_plot(data = datos,
                season = 2017,
                city_color = "white",
                plot_background_fill = "black",
                land_color = "gray",
                caption_color = "lightblue")


```

<img src="man/images/plot1.png" width="800" />

There are several common ggplot arguments users can customise to achieve the desired look as well as the ability to further work with the image outside of the function as it is just a ggplot object.

### 6.1) Interactive 3D Flight Plots

Although outside of the scope of this package, it is worth mentioning that users can combine the results of `nba_travel()` with the plotting capabilities of [{echarts4r}](https://echarts4r.john-coene.com/) to create dynamic 3D plots of the flight paths with just a few lines of code. 

Below is an example of how to do this:

```
library(echarts4r)
library(echarts4r.assets)
library(airball)
library(tidyverse)


data <- nba_travel(start_season = 2019, end_season = 2019, team = "Boston Celtics")

data %>% 
  filter(Route != "No Travel") %>%
  
  e_charts() %>% 
  e_globe(
    environment = ea_asset("starfield"),
    base_texture = ea_asset("world"), 
    height_texture = ea_asset("world"),
    displacementScale = 0.05
  ) %>% 
  e_lines_3d(
    Longitude, 
    Latitude, 
    d.Longitude, 
    d.Latitude,
    name = "flights",
    effect = list(show = TRUE)
  ) %>% 
  e_legend(FALSE)

```
<img src="man/images/globe.gif" width="800" />

### 7) Arbitrary Density Indicators

The `nba_density()` function accepts the result of `nba_travel()` and returns a data frame with various common arbitrary game density descriptors.

```{r}
datos <- nba_travel()
nba_density(df = datos)


# A tibble: 7,532 x 13
# Groups:   Season, Phase, Team [138]
   Season  Phase Team          Date       Opponent            `W/L` Location B2B   `B2B-1st` `B2B-2nd` `3in4` `4in5` `5in7`
   <chr>   <chr> <chr>         <date>     <chr>               <chr> <chr>    <chr> <chr>     <chr>     <chr>  <chr>  <chr> 
 1 2017-18 RS    Atlanta Hawks 2017-10-18 Dallas Mavericks    W     Away     No    No        No        No     No     No    
 2 2017-18 RS    Atlanta Hawks 2017-10-20 Charlotte Hornets   L     Away     No    No        No        No     No     No    
 3 2017-18 RS    Atlanta Hawks 2017-10-22 Brooklyn Nets       L     Away     Yes   Yes       No        No     No     No    
 4 2017-18 RS    Atlanta Hawks 2017-10-23 Miami Heat          L     Away     Yes   No        Yes       Yes    No     No    
 5 2017-18 RS    Atlanta Hawks 2017-10-26 Chicago Bulls       L     Away     Yes   Yes       No        No     No     No    
 6 2017-18 RS    Atlanta Hawks 2017-10-27 Denver Nuggets      L     Home     Yes   No        Yes       No     No     No    
 7 2017-18 RS    Atlanta Hawks 2017-10-29 Milwaukee Bucks     L     Home     No    No        No        Yes    No     No    
 8 2017-18 RS    Atlanta Hawks 2017-11-01 Philadelphia 76ers  L     Away     No    No        No        No     No     No    
 9 2017-18 RS    Atlanta Hawks 2017-11-03 Houston Rockets     L     Home     No    No        No        No     No     No    
10 2017-18 RS    Atlanta Hawks 2017-11-05 Cleveland Cavaliers W     Away     Yes   Yes       No        No     No     No    
# ... with 7,522 more rows
```

It works at a team level and besides season, phase, date, team, location and 'W/L' it returns the following columns:

* **B2B**: Yes if the game is part of a back to back series.
* **B2B-1st**: Yes if the game is the first game of a back to back.
* **B2B-2nd**: Yes if the game is the second game of a back to back.
* **3in4**: Yes if the game is the 3rd game played in four days.
* **4in5**: Yes if the game is the 4th game played in five days.
* **5in7**: Yes if the game is the 5th game played in seven days.

## 8) Injury Transactions

To help explore how the schedule may impact injuries, we added the `nba_injuries()` function to get a list of injury transactions. The function enables querying start date, end date, players and/or individual teams. The data is extracted from [Pro Sport Transactions](https://www.prosportstransactions.com/). Please check this website for information on how the transactions are listed.

Example: 
```{r}

nba_injuries(start_date = "2012-01-01",
             end_date = "2014-01-01",
             player = "Jose Calderon",
             team = "")
             

# A tibble: 18 x 5
   Date       Team      Acquired        Relinquished    Notes                                 
   <date>     <chr>     <chr>           <chr>           <chr>                                 
 1 2012-03-11 Raptors   ""              "Jose Calderon" placed on IL with sprained right ankle
 2 2012-03-17 Raptors   ""              "Jose Calderon" sprained right ankle (DNP) (F)        
 3 2012-03-20 Raptors   "Jose Calderon" ""              activated from IL (P)                 
 4 2012-04-06 Raptors   ""              "Jose Calderon" facial injury (DNP)                   
 5 2012-04-13 Raptors   ""              "Jose Calderon" facial injury (DNP)                   
 6 2012-04-15 Raptors   ""              "Jose Calderon" right eye injury (DNP)                
 7 2012-04-22 Raptors   ""              "Jose Calderon" right eye injury (DNP)                
 8 2012-04-23 Raptors   ""              "Jose Calderon" right eye injury (DNP)                
 9 2012-04-26 Raptors   ""              "Jose Calderon" right eye injury (DNP)                
10 2013-02-01 Pistons   ""              "Jose Calderon" placed on IL                          
11 2013-02-04 Pistons   "Jose Calderon" ""              activated from IL                     
12 2013-04-03 Pistons   ""              "Jose Calderon" arm injury (DNP)                      
13 2013-04-07 Pistons   ""              "Jose Calderon" strained right triceps (DNP)          
14 2013-04-10 Pistons   ""              "Jose Calderon" strained right triceps (DNP)          
15 2013-04-12 Pistons   ""              "Jose Calderon" strained right triceps (DNP)          
16 2013-04-15 Pistons   ""              "Jose Calderon" strained right triceps (DNP)          
17 2013-04-17 Pistons   ""              "Jose Calderon" strained right triceps (DNP)          
18 2013-11-30 Mavericks ""              "Jose Calderon" bone bruise in right ankle (DNP)    


```

If the parameters `player` or `team` are not indicated, it will return all players and teams within the selected dates. Note that for long queries (multiple years/teams) it may take a while.

```{r}

nba_injuries(start_date = "2014-01-01",
             end_date = "2014-01-10")
             

# A tibble: 147 x 5
   Date       Team      Acquired        Relinquished                       Notes                              
   <date>     <chr>     <chr>           <chr>                              <chr>                              
 1 2014-01-01 Bobcats   ""              "Jeffery Taylor / Jeff Taylor (b)" torn right Achilles tendon (DNP)   
 2 2014-01-01 Clippers  ""              "Reggie Bullock"                   placed on IL                       
 3 2014-01-01 Clippers  "Maalik Wayns"  ""                                 activated from IL                  
 4 2014-01-01 Mavericks ""              "Wayne Ellington"                  illness (DNP)                      
 5 2014-01-01 Pelicans  "Eric Gordon"   ""                                 activated from IL                  
 6 2014-01-01 Blazers   "C.J. McCollum" ""                                 activated from IL                  
 7 2014-01-02 Bobcats   ""              "Jeffery Taylor / Jeff Taylor (b)" torn right Achilles tendon (DNP)   
 8 2014-01-02 Bucks     ""              "John Henson"                      sprained left ankle (DNP)          
 9 2014-01-02 Cavaliers ""              "Kyrie Irving"                     bruised left knee (DTD)            
10 2014-01-02 Cavaliers ""              "Kyrie Irving"                     placed on IL with bruised left knee
# ... with 137 more rows

```



## 9) Future Development

**{airball}** is currently under development and it may change over time.

## 10) Acknowledgment

As mentioned above, I'd like to thank Alex Bresler and his package [{nbastatR}](https://github.com/abresler/nbastatR) which I have used to query NBA schedule and box scores from the NBA stats website. 

I have also used his package previously [here](https://josedv.shinyapps.io/NBASchedule/) to create an app to visualize and manipulate several NBA game density factors.

## 11) Citation

```{r}

citation("airball")

Fernandez, J. (2020). airball: Schedule & Travel Related Metrics in Basketball. R package version 0.4.0. https://github.com/josedv82/airball

A BibTeX entry for LaTeX users is

  @Manual{,
    title = {airball: Schedule & Travel Related Metrics in Basketball},
    author = {{person} and email = "jose.fernandezdv at gmail.com")},
    note = {R package version 0.4.0},
    url = {https://github.com/josedv82/airball},
  }
```

## 12) Disclaimer

Please be aware the metrics and calculations in this package are estimations and might not accurately represent actual travel management plans by teams.
