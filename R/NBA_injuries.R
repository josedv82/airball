#' NBA Injury List
#'
#' Returns a dataframe with injury transactions. This function queries data from <https://www.prosportstransactions.com/>
#'
#' @param start_date Date. Minimum date to query data from. (i.e. 2010-12-03). It defaults to 2017-01-01 if not specified.
#' @param end_date Date. Maximum date to query data to. (i.e. 2018-12-14). It defaults to 2018-01-01 if not specified.
#' @param player Character String. Filter data by a specific player. (i.e. Pau Gasol). Note that if only the last name is indicated (i.e. Gasol) it will return results for all players with the same last name. It defaults to blank if not indicated.
#' @param team Character String. The nickname of a unique team to query. (i.e. Lakers). It defaults to blank (all teams) if not indicated.
#'
#' @return A data frame with the following columns:
#'  \describe{
#'          \item{Date}{A date. The date of the transaction.}
#'          \item{Team}{A character String. The nickname of the team where the transaction occurred.}
#'          \item{Acquired}{A character String. The name of the player involved in the transaction. Usually return to lineup.}
#'          \item{Relinquished}{A character String. The name of the player involved in the transaction. Usually pulled out of the lineup.}
#'          \item{Notes}{A character String. A short description about the transaction.}
#'
#'     }
#'
#'
#' @export
#' @examples
#' nba_injuries(start_date = "2012-01-01",
#'              end_date = "2014-01-01",
#'              player = "Pau Gasol",
#'             team = "Lakers")
#'
#'


nba_injuries <- function(start_date = "2017-01-01",
                         end_date = "2018-01-01",
                         player = "",
                         team = ""){


  result <- tryCatch({

    player <- gsub("\\s", "+", player)
    css_selector <- ".datatable"

    #find max number of links on website
    web <- paste0("https://www.prosportstransactions.com/basketball/Search/SearchResults.php?Player=", player, "&Team=", team, "&BeginDate=", start_date,"&EndDate=", end_date, "&ILChkBx=yes&InjuriesChkBx=yes&PersonalChkBx=yes&Submit=Search&start=0")

    #get link text
    url_ <- xml2::read_html(web) %>%
      rvest::html_nodes("a") %>%
      rvest::html_attr('href')

    #get link address
    link_ <- xml2::read_html(web) %>%
      rvest::html_nodes("a") %>%
      rvest::html_text()

    #fix in case query returns only one link (small queries)
    fake <- c("0", web)
    real <- dplyr::tibble(link_, url_)

    start <- rbind(fake, real) %>%
      dplyr::filter(link_ %in% c(0:1000000)) %>%
      dplyr::mutate(link_ = as.numeric(link_)) %>%
      dplyr::filter(link_ == max(link_)) %>%
      dplyr::mutate(start = as.numeric(gsub('.*start=([0-9]+).*','\\1',url_)))

    #sequence for searching all tables on website
    startCols <- seq(from = 0, to = unique(start$start), by = 25)

    pages <- lapply(startCols,function(x){
      url <- paste0("https://www.prosportstransactions.com/basketball/Search/SearchResults.php?Player=", player, "&Team=", team, "&BeginDate=", start_date,"&EndDate=", end_date, "&ILChkBx=yes&InjuriesChkBx=yes&PersonalChkBx=yes&Submit=Search&start=",x)

      webpage <- xml2::read_html(url)

      data <- webpage %>%
        rvest::html_node(css = css_selector) %>%
        rvest::html_table() %>%
        dplyr::as_tibble()
      colnames(data) = data[1,]
      data[-1, ]
    })

    # final data frame
    data <- do.call(rbind,pages)

    data %>%
      dplyr::mutate(Date = lubridate::ymd(Date)) %>%
      dplyr::mutate(Acquired = sub("\\\u2024 ", "", Acquired)) %>%
      dplyr::mutate(Relinquished = sub("\\\u2024 ", "", Relinquished))

  }, error = function(cond) {
    message("That query did not return any results. Try adjusting your search")
    # Choose a return value in case of error
    return(NA)

  })

  return(result)

}
