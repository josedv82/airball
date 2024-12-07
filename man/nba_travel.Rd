% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/NBA_travel.R
\name{nba_travel}
\alias{nba_travel}
\title{NBA Travel & Schedule related Metrics}
\usage{
nba_travel(
  start_season = 2018,
  end_season = 2020,
  team = NULL,
  return_home = 20,
  phase = c("RS", "PO"),
  flight_speed = 550
)
}
\arguments{
\item{start_season}{Numeric. The year of the first season users wish to explore (i.e. 2018)}

\item{end_season}{Numeric. The year of the final season users wisth to explore (i.e. 2020)}

\item{team}{Character String. The name of the team to be explored. If empty it defaults to all teams within the selected seasons.}

\item{return_home}{Numeric. Users can set the number of days after which the team will return home between consecutive road games. It defaults to 20 if not indicated.}

\item{phase}{Character String. The phase of the season users wish to download. RS for Regular Season and PO for Playoffs. It defauls to both if not indicated.}

\item{flight_speed}{Numeric. Average cruising speed (in mph) for commercial flights. Used to adjust flight time estimation.}
}
\value{
A data frame with the following columns:
 \describe{
         \item{Season}{A chracter string. The season(s) downloaded.}
         \item{Month}{A character String. The month of the season.}
         \item{Week}{Numeric. The week of the year.}
         \item{Date}{Date object. The date of the game.}
         \item{Team}{A character String. The name of the team.}
         \item{Opponent}{A character String. The name of the opponent.}
         \item{Location}{A character string. Location of the game. (Home or Away)}
         \item{`W/L`}{A character string. Outcome of the game. (W or L)}
         \item{City}{A character String. The name of the city in which the game is played.}
         \item{Distance}{Numeric. Estimated distance travelled (in miles) prior to a game.}
         \item{Route}{A character String. The route travelled for each game. If no travel involved it defaults to "No Travel".}
         \item{Rest}{Numeric. The number of days between games. It defaults to 15 for the first game for each team. If the team is making a "return_home" trip it will default to NA.}
         \item{TZ}{A character string. The time zone where the game is played.}
         \item{`Shift (hrs)`}{Numeric. The time zoen change in hours.}
         \item{`Flight Time`}{A character string. Aproximate duration of the flight for a given trip.}
         \item{`Direction (E/W)`}{A character string. Travel direction for trips involving zone changes.}
         \item{`Return Home`}{A character string. If yes, team is making a "return_home" trip.}
         \item{Latitude}{Numeric. Latitude of the origin location.}
         \item{Longitude}{Numeric. Longitude of the origin location.}
         \item{d.Latitude}{Numeric. Latitude of the destication location.}
         \item{d.Longitude}{Numeric. Longitude of the destination location.}
    }
}
\description{
Returns a dataframe with computed travel and schedule metrics for NBA teams. It requires the game_logs() function from on the nbastatR package written by Bresler, A (2020) <https://github.com/abresler/nbastatR> to query season schedule information that is needed to calculate travel metrics.
}
\examples{
nba_travel(start_season = 2017,
           end_season = 2020,
           team = c("Los Angeles Lakers", "Boston Celtics"),
           return_home = 3,
           phase = "RS",
           flight_speed = 550)

}
