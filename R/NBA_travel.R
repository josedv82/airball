#' NBA Travel & Schedule related Metrics
#'
#' Returns a dataframe with computed travel and schedule metrics for NBA teams. It requires the game_logs() function from on the nbastatR package written by Bresler, A (2020) <https://github.com/abresler/nbastatR> to query season schedule information that is needed to calculate travel metrics.
#'
#' @param start_season Numeric. The year of the first season users wish to explore (i.e. 2018)
#' @param end_season Numeric. The year of the final season users wisth to explore (i.e. 2020)
#' @param team Character String. The name of the team to be explored. If empty it defaults to all teams within the selected seasons.
#' @param return_home Numeric. Users can set the number of days after which the team will return home between consecutive road games. It defaults to 20 if not indicated.
#' @param phase Character String. The phase of the season users wish to download. RS for Regular Season and PO for Playoffs. It defauls to both if not indicated.
#' @param flight_speed Numeric. Average cruising speed (in mph) for commercial flights. Used to adjust flight time estimation.
#'
#' @return A data frame with the following columns:
#'  \describe{
#'          \item{Season}{A chracter string. The season(s) downloaded.}
#'          \item{Month}{A character String. The month of the season.}
#'          \item{Week}{Numeric. The week of the year.}
#'          \item{Date}{Date object. The date of the game.}
#'          \item{Team}{A character String. The name of the team.}
#'          \item{Opponent}{A character String. The name of the opponent.}
#'          \item{Location}{A character string. Location of the game. (Home or Away)}
#'          \item{`W/L`}{A character string. Outcome of the game. (W or L)}
#'          \item{City}{A character String. The name of the city in which the game is played.}
#'          \item{Distance}{Numeric. Estimated distance travelled (in miles) prior to a game.}
#'          \item{Route}{A character String. The route travelled for each game. If no travel involved it defaults to "No Travel".}
#'          \item{Rest}{Numeric. The number of days between games. It defaults to 15 for the first game for each team. If the team is making a "return_home" trip it will default to NA.}
#'          \item{TZ}{A character string. The time zone where the game is played.}
#'          \item{`Shift (hrs)`}{Numeric. The time zoen change in hours.}
#'          \item{`Flight Time`}{A character string. Aproximate duration of the flight for a given trip.}
#'          \item{`Direction (E/W)`}{A character string. Travel direction for trips involving zone changes.}
#'          \item{`Return Home`}{A character string. If yes, team is making a "return_home" trip.}
#'          \item{Latitude}{Numeric. Latitude of the origin location.}
#'          \item{Longitude}{Numeric. Longitude of the origin location.}
#'          \item{d.Latitude}{Numeric. Latitude of the destication location.}
#'          \item{d.Longitude}{Numeric. Longitude of the destination location.}
#'     }
#'
#'
#' @export
#' @examples
#' nba_travel(start_season = 2017,
#'            end_season = 2020,
#'            team = c("Los Angeles Lakers", "Boston Celtics"),
#'            return_home = 3,
#'            phase = "RS",
#'            flight_speed = 550)
#'

nba_travel <- function(start_season = 2018,
                       end_season = 2020,
                       team = NULL,
                       return_home = 20,
                       phase = c("RS", "PO"),
                       flight_speed = 550){


## pull regular season data
  invisible(capture.output( RS <- tryCatch({

    suppressWarnings(
      nbastatR::game_logs(
        seasons = start_season:end_season,
        league = "NBA",
        result_types = "player",
        season_types = "Regular Season",
        nest_data = F,
        assign_to_environment = F,
        return_message = F
      )) %>% dplyr::mutate(Phase = "RS")

  }, error = function(cond){

    suppressWarnings(
      nbastatR::game_logs(
        seasons = start_season:(end_season-1),
        league = "NBA",
        result_types = "player",
        season_types = "Regular Season",
        nest_data = F,
        assign_to_environment = F,
        return_message = F
      )) %>% dplyr::mutate(Phase = "RS")

  }

  )))

#pull play off data
  invisible(capture.output( PO <- tryCatch({

    suppressWarnings(
      nbastatR::game_logs(
        seasons = start_season:end_season,
        league = "NBA",
        result_types = "player",
        season_types = "Playoffs",
        nest_data = F,
        assign_to_environment = F,
        return_message = F
      )) %>% dplyr::mutate(Phase = "PO")

  }, error = function(cond){

    suppressWarnings(
      nbastatR::game_logs(
        seasons = start_season:(end_season-1),
        league = "NBA",
        result_types = "player",
        season_types = "Playoffs",
        nest_data = F,
        assign_to_environment = F,
        return_message = F
      )) %>% dplyr::mutate(Phase = "PO")

  }

  )))

  #pull future games (games that have not been played yet)

  future_games <- function(year = 2022, month = "december"){

    year <- year
    month <- month
    url <- paste0("https://www.basketball-reference.com/leagues/NBA_", year, "_games-", month, ".html")
    webpage <- xml2::read_html(url)


    col_names <- webpage %>%
      rvest::html_nodes("table#schedule > thead > tr > th") %>%
      rvest::html_attr("data-stat")
    col_names <- c("game_id", col_names)


    dates <- webpage %>%
      rvest::html_nodes("table#schedule > tbody > tr > th") %>%
      rvest::html_text()
    dates <- dates[dates != "Playoffs"]

    game_id <- webpage %>%
      rvest::html_nodes("table#schedule > tbody > tr > th") %>%
      rvest::html_attr("csk")
    game_id <- game_id[!is.na(game_id)]


    data <- webpage %>%
      rvest::html_nodes("table#schedule > tbody > tr > td") %>%
      rvest::html_text() %>%
      matrix(ncol = length(col_names) - 2, byrow = TRUE)

    month_df <- as.data.frame(cbind(game_id, dates, data), stringsAsFactors = FALSE) %>%
      dplyr::mutate(dates = lubridate::mdy(dates))
    names(month_df) <- col_names

    month_h <- month_df %>% dplyr::select(Date = date_game, Team = home_team_name, Opponent = visitor_team_name) %>% dplyr::mutate(Location = "H")
    month_a <- month_df %>% dplyr::select(Date = date_game, Opponent = home_team_name, Team = visitor_team_name) %>% dplyr::mutate(Location = "A")

    future <- dplyr::full_join(month_h, month_a, by = c("Date", "Team", "Opponent", "Location")) %>%
      dplyr::mutate(Season = "2021-22", `W/L` = "-", Phase = "RS")

  }

#join future games for all months (will need to add remaining months when schedule is announced
  dec <- future_games(year = 2022, month = "december")
  jan <- future_games(year = 2022, month = "january")
  feb <- future_games(year = 2022, month = "february")
  mar <- future_games(year = 2022, month = "march")
  apr <- future_games(year = 2022, month = "april")
  may <- future_games(year = 2022, month = "may")

  future <- dplyr::full_join(dec, jan, by = c("Date", "Team", "Opponent", "Location", "Season", "W/L", "Phase")) %>%
    dplyr::full_join(feb, by = c("Date", "Team", "Opponent", "Location", "Season", "W/L", "Phase")) %>%
    dplyr::full_join(mar, by = c("Date", "Team", "Opponent", "Location", "Season", "W/L", "Phase")) %>%
    dplyr::full_join(apr, by = c("Date", "Team", "Opponent", "Location", "Season", "W/L", "Phase")) %>%
    dplyr::full_join(may, by = c("Date", "Team", "Opponent", "Location", "Season", "W/L", "Phase")) %>%
    dplyr::arrange(Team, Date) %>%
    dplyr::filter(Date >= Sys.Date())


#join regular season, playoffs and future games
  statlogs <- rbind(RS, PO) %>% dplyr::arrange(dateGame)

  #cleaning for away + home games
  away <- statlogs %>%
    dplyr::select(Season = slugSeason, Date = dateGame, Team = nameTeam, Location = locationGame, Opp = slugOpponent, TE = slugTeam, `W/L` = outcomeGame, Phase) %>%
    dplyr::distinct()

  home <- statlogs %>%
    dplyr::select(Season = slugSeason, Date = dateGame, TeamB = nameTeam, LocationB = locationGame, TE = slugOpponent, Opp = slugTeam) %>%
    dplyr::distinct()

  #conditional merging. If there are future games involved join future dataset up to current date, else just pull all previous games
  if(end_season < 2022) {

    cal <- dplyr::full_join(away, home, by = c("Season", "Date", "Opp", "TE")) %>%
      dplyr::select(Season, Date, Team, Opponent = TeamB, Location, `W/L`, Phase, -Opp, -TE, -LocationB) %>%
      dplyr::arrange(Team, Date)

  } else {

    cal <- dplyr::full_join(away, home, by = c("Season", "Date", "Opp", "TE")) %>%
      dplyr::select(Season, Date, Team, Opponent = TeamB, Location, `W/L`, Phase, -Opp, -TE, -LocationB) %>%
      dplyr::full_join(future, by = c("Season", "Date", "Team", "Opponent", "Location", "W/L", "Phase")) %>%
      dplyr::arrange(Team, Date)

  }

  #obtain city coordinates
  cities <- maps::world.cities %>%
    dplyr::group_by(name, country.etc) %>%
    dplyr::filter(pop == max(pop)) %>%
    dplyr::filter(country.etc %in% c("USA", "Canada")) %>%
    dplyr::group_by(name) %>%
    dplyr::filter(pop == max(pop)) %>%
    dplyr::ungroup()

  #clean a few team names so they can be used to locate city coordinates automatically
  cal1 <- cal %>%
    dplyr::mutate(Team = ifelse(Team == "LA Clippers", "Los Angeles Clippers", Team)) %>%
    dplyr::mutate(Opponent = ifelse(Opponent == "LA Clippers", "Los Angeles Clippers", Opponent)) %>%
    dplyr::mutate(name = ifelse(Location == "H", gsub("(\\D+)\\s+.*", "\\1", Team), gsub("(\\D+)\\s+.*", "\\1", Opponent))) %>%
    dplyr::mutate(name = ifelse(name == "Golden State", "San Francisco",
                                ifelse(name == "Utah", "Salt Lake City",
                                       ifelse(name == "Minnesota", "Minneapolis",
                                              ifelse(name == "Indiana", "Indianapolis",
                                                     ifelse(name == "Brooklyn", "New York",
                                                            ifelse(name == "New Jersey", "Newark",
                                                                   ifelse(name == "St. Louis", "Saint Louis",
                                                                          ifelse(name == "Ft. Wayne", "Fort Wayne",
                                                                                 ifelse(name == "Tri-Cities", "Moline",
                                                                                        ifelse(name == "Kansas City-Omaha", "Kansas City",
                                                                                               ifelse(name == "Capital", "Washington",
                                                                                                      ifelse(name == "New Orleans/Oklahoma City", "New Orleans",
                                                                                                             ifelse(name == "Portland Trail", "Portland", name)))))))))))))) %>%

    #correct for Toronto location in 2021
    dplyr::mutate(name = ifelse(Season == "2020-21" & Team == "Toronto Raptors" & Location == "H", "Tampa", name)) %>%
    dplyr::mutate(name = ifelse(Season == "2020-21" & Opponent == "Toronto Raptors" & Location == "A", "Tampa", name)) %>%

    #join team with cities
    dplyr::full_join(cities, by = "name") %>%
    dplyr::mutate(off = paste(name, country.etc)) %>%
    dplyr::filter(off != "Dallas Canada" & off != "Houston Canada") %>%
    na.omit() %>%
    dplyr::select(Season, Date, Team, Opponent, Location, City = name, `W/L`, Phase, lat, long) %>%
    dplyr::group_by(Team, Season) %>%
    dplyr::mutate(destLat = dplyr::lag(lat), destLon = dplyr::lag(long))

   #cleaning home cities
  calhome <- cal1 %>%
    dplyr::filter(Location == "H") %>%
    dplyr::ungroup() %>%
    dplyr::select(Team, City, lat, long) %>%
    dplyr::distinct() %>%
    dplyr::select(Team, City, destLat1 = lat, destLon1 = long)

  #cleaning all calendar data after joining cities + team data
  allcal <- dplyr::full_join(cal1, calhome, by = c("Team", "City")) %>%
    dplyr::group_by(Season, Team) %>%
    tidyr::fill(destLat1, .direction = "up") %>%
    tidyr::fill(destLon1, .direction = "up") %>%
    dplyr::mutate(destLat = ifelse(is.na(destLat), destLat1, destLat)) %>%
    dplyr::mutate(destLon = ifelse(is.na(destLon), destLon1, destLon)) %>%
    dplyr::select(-destLat1, -destLon1) %>%
    dplyr::group_by(Season, Team) %>%
    dplyr::mutate(Rest = abs(as.numeric(dplyr::lag(Date) - Date) + 1)) %>%
    dplyr::mutate(Rest = ifelse(is.na(Rest), 15, Rest)) %>%
    dplyr::mutate(AB = paste(Location, dplyr::lag(Location)))

 #completes missing date sequence
  miscal <-  allcal %>%
    dplyr::group_by(Season, Team) %>%
    tidyr::complete(Date = seq.Date(min(Date), max(Date), by = "day")) %>%
    dplyr::filter(is.na(Location)) %>%
    dplyr::select(Season, Team, Date) %>%
    dplyr::full_join(calhome, by = "Team") %>%
    dplyr::select(Season, Team, City, Date, lat = destLat1, long = destLon1)

  #perform rest + detination coordinates calculations (account for orlando during covid)
  cal_rest <- dplyr::full_join(allcal, miscal, by = c("Season", "Date", "Team", "City", "lat", "long")) %>%
    dplyr::arrange(Season, Team, Date) %>%
    dplyr::mutate(A_B = ifelse(Rest >= return_home & AB == "A A", "-", NA)) %>%
    dplyr::mutate(A_B = ifelse(dplyr::lead(A_B) == "-", "y", A_B)) %>%
    dplyr::filter(!is.na(Rest) | A_B == "y") %>%
    dplyr::mutate(destLat = ifelse(is.na(destLat), dplyr::lag(lat), destLat),
                  destLon = ifelse(is.na(destLon), dplyr::lag(long), destLon)) %>%
    dplyr::mutate(destLat1 = ifelse(dplyr::lag(A_B == "y"), dplyr::lag(lat), destLat),
                  destLon1 = ifelse(dplyr::lag(A_B == "y"), dplyr::lag(long), destLon)) %>%
    dplyr::mutate(destLat = ifelse(!is.na(destLat1), destLat1, destLat),
                  destLon = ifelse(!is.na(destLon1), destLon1, destLon)) %>%
    dplyr::select(-AB, -A_B, -destLat1, -destLon1) %>%
    dplyr::mutate(City = ifelse(Date > "2020-07-01" & Date < "2020-11-01", "Orlando", City)) %>%
    dplyr::mutate(lat = ifelse(Date > "2020-07-01" & Date < "2020-11-01", 28.50, lat),
                  destLat = ifelse(Date > "2020-07-01" & Date < "2020-11-01", 28.50, destLat),
                  long = ifelse(Date > "2020-07-01" & Date < "2020-11-01", -81.37, long),
                  destLon = ifelse(Date > "2020-07-01" & Date < "2020-11-01", -81.37, destLon)) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(dist = geosphere::distm(c(destLon, destLat), c(long, lat), fun = geosphere::distHaversine)) %>%
    dplyr::mutate(Distance = round(dist * 0.000621,0)) %>%
    dplyr::select(-dist) %>%
    dplyr::ungroup()

  home <- calhome %>%
    dplyr::select(Team, Citys = City) %>%
    dplyr::ungroup()

  #extract time zones for cities
  TZs <- lutz::tz_list() %>%
    dplyr::select(TZ = tz_name, is_dst, utc_offset_h) %>%
    dplyr::filter(is_dst == FALSE) %>%
    dplyr::select(-is_dst)

  #calculate time zone changes + other time related metrics
  shift <- cal_rest %>% dplyr::full_join(home, by = "Team") %>%
    dplyr::group_by(Season, Team) %>%
    dplyr::mutate(lagcity = ifelse(is.na(dplyr::lag(City)), "-" , dplyr::lag(City))) %>%
    dplyr::mutate(Route = ifelse(lagcity == "-", paste(Citys, dplyr::lead(lagcity), sep = " - "), paste(lagcity, dplyr::lead(lagcity), sep = " - "))) %>%
    dplyr::mutate(Route = ifelse(Distance == 0, "No Travel", Route)) %>%
    dplyr::select(-Citys, -lagcity) %>%
    dplyr::mutate(Opponent = ifelse(is.na(Opponent), "-", Opponent),
                  Location = ifelse(is.na(Location), "-", Location),
                  Location = ifelse(Location == "A", "Away",
                                    ifelse(Location == "H", "Home", "-")),
                  `Return Home` = ifelse(Location == "-", "Yes", "")) %>%
    dplyr::mutate(Month = lubridate::month(Date),
                  Week = lubridate::week(Date)) %>%
    dplyr::mutate(TZ = lutz::tz_lookup_coords(lat, long, method = "fast", warn = F)) %>%
    dplyr::full_join(TZs, by = "TZ") %>%
    dplyr::select(offset = utc_offset_h, everything()) %>%
    dplyr::ungroup()

#create final data set with all parameters
  final <- shift %>%
    dplyr::filter(Location == "Home") %>%
    dplyr::select(Team, City, TZ) %>%
    dplyr::distinct() %>%
    dplyr::full_join(TZs, by = "TZ") %>%
    na.omit() %>%
    dplyr::full_join(shift, c("Team", "City", "TZ")) %>%
    dplyr::arrange(Season, Team, Date) %>%
    dplyr::group_by(Season, Team) %>%
    tidyr::fill(utc_offset_h, .direction = "up") %>%
    tidyr::fill(utc_offset_h, .direction = "down") %>%
    dplyr::mutate(`Shift (hrs)` = offset - dplyr::lag(offset)) %>%
    dplyr::mutate(`Shift (hrs)` = ifelse(Route != "No Travel" & is.na(`Shift (hrs)`), offset - utc_offset_h,
                                         ifelse(Route == "No Travel" & is.na(`Shift (hrs)`), 0, `Shift (hrs)`))) %>%
    dplyr::mutate(`Direction (E/W)` = ifelse(`Shift (hrs)` < 0, "West",
                                             ifelse(`Shift (hrs)` > 0, "East", "-"))) %>%
    dplyr::mutate(`Flight Time` = ifelse(Distance == 0, NA, Distance / (flight_speed / 3600))) %>%
    dplyr::mutate(`Flight Time` = ifelse(`Flight Time` <= 3300, 3300, `Flight Time`)) %>%
    dplyr::mutate(`Flight Time` = lubridate::duration(num = `Flight Time`, units = "seconds")) %>%
    dplyr::mutate(`Flight Time` = gsub("(?<=\\()[^()]*(?=\\))(*SKIP)(*F)|.", "", `Flight Time`, perl=T)) %>%
    dplyr::mutate(`Flight Time` = ifelse(is.na(`Flight Time`), "-", `Flight Time`)) %>%
    dplyr::select(Season, Phase, Month, Week, Date, Team, Opponent, Location, `W/L`, City, Distance, Route, Rest, TZ, `Shift (hrs)`, `Flight Time`, `Direction (E/W)`, `Return Home`, Latitude = lat, Longitude = long, d.Latitude = destLat, d.Longitude = destLon) %>%
    dplyr::ungroup() %>%
    dplyr::filter(!is.na(Team)) %>%
    dplyr::mutate(Month = ifelse(Month == 1, 'Jan',
                                 ifelse(Month == 2, 'Feb',
                                        ifelse(Month == 3, 'Mar',
                                               ifelse(Month == 4, 'Apr',
                                                      ifelse(Month == 5, 'May',
                                                             ifelse(Month == 6, 'Jun',
                                                                    ifelse(Month == 7, 'Jul',
                                                                           ifelse(Month == 8, 'Aug',
                                                                                  ifelse(Month == 9, 'Sep',
                                                                                         ifelse(Month == 10, 'Oct',
                                                                                                ifelse(Month == 11, 'Nov', 'Dec')))))))))))) %>%

    dplyr::mutate(Notes = ifelse(Date > "2020-07-01" & Date < "2020-11-01" & `Return Home` == "Yes", "Remove", "")) %>% #for bubble
    dplyr::filter(Notes != "Remove") %>%
    dplyr::select(-Notes) %>%
    tidyr::fill(Phase, .direction = "up") %>%
    tidyr::fill(Phase, .direction = "down") %>%
    dplyr::mutate(`W/L` = ifelse(is.na(`W/L`), "-", `W/L`)) %>%
    dplyr::filter(Phase %in% phase) %>%
    dplyr::group_by(Season, Team) %>%
    dplyr::mutate(Rem = ifelse(!is.na(dplyr::lag(Date)) & dplyr::lag(Date) == Date, "1", "")) %>%
    dplyr::filter(Rem != "1") %>% dplyr::select(-Rem)

  #conditional return based on whether users select a team or not
  if(missing(team)) return(final)
  else return(final %>% dplyr::filter(Team %in% team))

}

