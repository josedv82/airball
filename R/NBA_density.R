#' NBA Schedule Density
#'
#' Accepts the result of `nba_travel()` & returns a dataframe with some common arbitrary schedule density related metrics such as back-to-back(b2b), 3in4, 4in5, etc.
#'
#' @param df A dataframe. The object storing the result of `nba_travel()`
#'
#' @return A data frame with the following columns:
#'  \describe{
#'          \item{Season}{A chracter string. The season(s) downloaded.}
#'          \item{Phase}{A character String. The phase of the season. RS or PO.}
#'          \item{Date}{Date object. The date of the game.}
#'          \item{Team}{A character String. The name of the team.}
#'          \item{Opponent}{A character String. The name of the opponent.}
#'          \item{Location}{A character string. Location of the game. (Home or Away)}
#'          \item{`W/L`}{A character string. Outcome of the game. (W or L)}
#'          \item{`B2B`}{A character string. B2B-1st (first game in B2B games) or B2B-2nd (second game in B2B games.)}
#'          \item{`B2B-1st`}{A character string. If yes, it is the first game of a back-to-back.}
#'          \item{`B2B-2nd`}{A character string. If yes, it is the second game of a back-to-back.}
#'          \item{`3in4`}{A character string. If yes, it is the third game in 4 days.}
#'          \item{`4in5`}{A character string. If yes, it is the fourth game in 5 days.}
#'          \item{`5in7`}{A character string. If yes, it is the fith game in 7 days.}
#'     }
#'
#'
#' @export
#' @examples
#' datos <- nba_travel()
#' nba_density(df = datos)
#'

nba_density <- function(df){

  final <- df %>%
    dplyr::select(Season, Phase, Date, Team, Opponent, `W/L`, Location) %>%
    dplyr::group_by(Season, Phase, Team) %>%
    tidyr::complete(Date = seq.Date(min(Date), max(Date), by = "day")) %>%
    dplyr::arrange(Team, Date) %>%
    dplyr::mutate(Opponent = ifelse(is.na(Opponent), "-", Opponent)) %>%
    dplyr::mutate(Location = ifelse(is.na(Location), "-", Location)) %>%
    dplyr::mutate(`W/L` = ifelse(is.na(`W/L`), "-", `W/L`)) %>%
    dplyr::mutate(Game = ifelse(Opponent != "-", 1, 0)) %>%
    dplyr::mutate(B2B = ifelse(dplyr::lag(Game) == 1 & Game == 1, "B2B-2nd", "")) %>%
    dplyr::mutate(B2B = ifelse(dplyr::lead(B2B) == "B2B-2nd", "B2B-1st", B2B)) %>%
    dplyr::mutate(B2B = ifelse(is.na(B2B) & dplyr::lag(Game) == 0, "", B2B)) %>%
    dplyr::mutate(B2B = ifelse(is.na(B2B) & dplyr::lag(Game) == 1, "B2B-2nd", B2B)) %>%
    dplyr::mutate(B2B = ifelse(is.na(B2B) & dplyr::lead(Game) == 0, "", B2B)) %>%
    dplyr::mutate(`B2B-1st` = ifelse(B2B == "B2B-1st", "Yes", "No")) %>%
    dplyr::mutate(`B2B-2nd` = ifelse(B2B == "B2B-2nd", "Yes", "No")) %>%
    dplyr::mutate(`B2B` = ifelse(B2B != "", "Yes", "No")) %>%
    dplyr::mutate(`3in4` = zoo::rollapplyr(Game, 4, sum, partial = TRUE),
                  `4in5` = zoo::rollapplyr(Game, 5, sum, partial = TRUE),
                  `5in7` = zoo::rollapplyr(Game, 7, sum, partial = TRUE)) %>%
    dplyr::mutate(`3in4` = ifelse(`3in4` >= 3, "Yes", "No"),
                  `4in5` = ifelse(`4in5` >= 4, "Yes", "No"),
                  `5in7` = ifelse(`5in7` >= 5, "Yes", "No")) %>%
    dplyr::select(-Game) %>%
    dplyr::filter(Opponent != "-")

  return(final)

}