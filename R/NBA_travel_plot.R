#' NBB Flight Paths
#'
#' Plots the estimated flight paths for the selected season and team(s). It returns a ggplot object that can be further customized by the user.
#'
#' @param data A data frame. The result of nba_travel()
#' @param season Numeric. A four year digit (i.e. 2018). If not indicated it defaults to the most recent season in the dataset.
#' @param team A character string. The name of a team (or vector of teams) to display. If not indicated it will default to all teams.
#' @param land_color A character string. Color of the land.
#' @param land_alpha Numeric. The alpha value of the land between 0-1. Used to set transparecy level.
#' @param city_color A character String. The color of the points representing the cities.
#' @param city_size Numeric. The size of the point representing the cities.
#' @param path_curvature Numeric. The level of curvature for the path representing the flight. Defaults to 0.05.
#' @param path_color A character String. The color of the lines representing the flight path.
#' @param path_size Numeric. The thickness of the lines representing the flight paths. Defaults to 0.5.
#' @param title A character string. The plot title.
#' @param title_color A character string. The color of the title text.
#' @param title_size Numeric. The size of the title text. Defaults to 20.
#' @param caption A character string. The plot caption.
#' @param caption_color A character string. The color of the caption text.
#' @param caption_size Numeric. The size of the caption text. Defaults to 8.
#' @param caption_face A character string. TThe face of the caption text. Defaults to "italic".
#' @param major_grid_color A character string. The color of the major gridlines. Defaults to "transparent".
#' @param minor_grid_color A character string. The color of the minor gridlines. Defaults to "transparent".
#' @param strip_text_size Numeric. The size of the strip text. Default to 8.
#' @param strip_text_color A character string. The color of the strip text.
#' @param strip_fill A character string. The color of the strip. Defaults to "transparent.
#' @param plot_background_fill A character string. The color of the plot background.
#' @param panel_background_fill A character string. The color of the panel background.
#' @param ncolumns Numeric. The number of columns for facetted plots.
#'
#' @return A ggplot object
#'
#'
#' @export
#' @examples
#' datos <- nba_travel(season = 2015:2018)
#' nba_travel_plot(data = datos,
#'                 season = 2017,
#'                 team = c("Chicago Bulls", "Miami Heat"),
#'                 city_color = "white",
#'                 plot_background_fill = "black",
#'                 land_color = "gray",
#'                 caption_color = "lightblue",
#'                 ncolumns = 1)
#'


nba_travel_plot <- function(
  data,
  season = NULL,
  team = NULL,
  land_color = "#17202a",
  land_alpha = 0.6,
  city_color = "cyan4",
  city_size = 0.8,
  path_curvature = 0.05,
  path_color = "#e8175d",
  path_size = 0.5,
  title = "NBA Flight Paths",
  title_color = "white",
  title_size = 20,
  caption = "",
  caption_color = "gray",
  caption_size = 8,
  caption_face = "italic",
  major_grid_color = "transparent",
  minor_grid_color = "transparent",
  strip_text_size = 8,
  strip_text_color = "white",
  strip_fill = "transparent",
  plot_background_fill = "#343e48",
  panel_background_fill = "transparent",
  ncolumns = 6){

  df <- data %>%
    dplyr::mutate(Year = sub('.*-', '', Season)) %>%
    dplyr::mutate(Year = as.numeric(Year)) %>%
    dplyr::mutate(Year = ifelse(Year <= 45, paste(20, Year, sep = ""), paste(19, Year, sep = ""))) %>%
    dplyr::mutate(Year = as.numeric(Year))

  if(missing(team))
    return(

      df %>%
        dplyr::filter(Distance > 0) %>%
        dplyr::filter(if (is.null(season)) Year == max(Year) else Year == season) %>%

        ggplot2::ggplot() +
        ggplot2::geom_polygon(data = ggplot2::map_data("usa"), ggplot2::aes(x=long, y = lat, group = group), fill = land_color, alpha = land_alpha) +
        ggplot2::geom_curve(ggplot2::aes(x = d.Longitude, y = d.Latitude, xend = Longitude, yend = Latitude), curvature = 0.05, color = "#e8175d", size = 0.5) +
        ggplot2::geom_point(ggplot2::aes(x = as.numeric(Longitude), y = as.numeric(Latitude)), color = city_color, size = city_size) +
        ggplot2::facet_wrap(~Team, ncol = ncolumns) +
        ggplot2::labs(title = title,
                      caption = caption) +
        ggthemes::theme_solarized_2(light = F) +
        ggplot2::theme(panel.grid.major = ggplot2::element_line(color = major_grid_color),
                       panel.grid.minor = ggplot2::element_line(color = minor_grid_color),
                       axis.text = ggplot2::element_blank(),
                       axis.ticks = ggplot2::element_blank(),
                       axis.title.y = ggplot2::element_blank(),
                       axis.title.x = ggplot2::element_blank(),
                       strip.text = ggplot2::element_text(size = strip_text_size, color = strip_text_color),
                       strip.background = ggplot2::element_rect(fill = strip_fill),
                       plot.title = ggplot2::element_text(size = title_size, color = title_color),
                       plot.caption = ggplot2::element_text(size = caption_size, face = caption_face, color = caption_color),
                       plot.background = ggplot2::element_rect(size = 0, fill = plot_background_fill),
                       panel.background = ggplot2::element_rect(fill = panel_background_fill))

    )

  else return (

    df %>%
      dplyr::filter(Distance > 0) %>%
      dplyr::filter(Team %in% team) %>%
      dplyr::filter(if (is.null(season)) Year == max(Year) else Year == season) %>%

      ggplot2::ggplot() +
      ggplot2::geom_polygon(data = ggplot2::map_data("usa"), ggplot2::aes(x=long, y = lat, group = group), fill = land_color, alpha = land_alpha) +
      ggplot2::geom_curve(ggplot2::aes(x = d.Longitude, y = d.Latitude, xend = Longitude, yend = Latitude), curvature = 0.05, color = "#e8175d", size = 0.5) +
      ggplot2::geom_point(ggplot2::aes(x = as.numeric(Longitude), y = as.numeric(Latitude)), color = city_color, size = city_size) +
      ggplot2::facet_wrap(~Team, ncol = ncolumns) +
      ggplot2::labs(title = title,
                    caption = caption) +
      ggthemes::theme_solarized_2(light = F) +
      ggplot2::theme(panel.grid.major = ggplot2::element_line(color = major_grid_color),
                     panel.grid.minor = ggplot2::element_line(color = minor_grid_color),
                     axis.text = ggplot2::element_blank(),
                     axis.ticks = ggplot2::element_blank(),
                     axis.title.y = ggplot2::element_blank(),
                     axis.title.x = ggplot2::element_blank(),
                     strip.text = ggplot2::element_text(size = strip_text_size, color = strip_text_color),
                     strip.background = ggplot2::element_rect(fill = strip_fill),
                     plot.title = ggplot2::element_text(size = title_size, color = title_color),
                     plot.caption = ggplot2::element_text(size = caption_size, face = caption_face, color = caption_color),
                     plot.background = ggplot2::element_rect(size = 0, fill = plot_background_fill),
                     panel.background = ggplot2::element_rect(fill = panel_background_fill))

  )

}