

TSplot_ggplot <- function(dat,
                          show.line = TRUE,
                          color_var){
  
  
  #to add: checks for required columns...
  #dat$plotVal <-if(logY){log(dat[[yvar]])}else {dat[[yvar]]}
  
  #CREATE PLOT ----
  
  #for x-axis -- now moved to myGraphs package..
  f <- function(y) seq(floor(min(y)), ceiling(max(y)), 1)  #to create annual sequence from dec_date
  
  p <- ggplot(dat, aes(x=decdate, y=Value)) + 
    geom_point(size=3,  aes(shape = factor(cenTF), 
                                           #fill=factor(.data[[color_var]]), 
                                           color=factor(.data[[color_var]]))) +
    scale_x_continuous(breaks = f )
  
  
  if(show.line){
    p <- p +  geom_line(color="lightgrey")
  }
  
  cen_fill=c("TRUE"=16, "FALSE"=1)
  cen_labels=c("censored", "not censored")
  p <- p +
    scale_shape_manual(name="",
                       values=cen_fill, 
                       labels=cen_labels, 
                       limits=names(cen_fill),
                       drop=FALSE)  
    
  
  
  p <- p + #theme_TS()  + #theme_TS_base() +
    theme_bw() + 
    theme(axis.title.x=element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          #legend.title=element_blank(),
          axis.text.x = element_text(angle = 90),
          #aspect.ratio = aspect.ratio,  #2 / (1 + sqrt(5)), # golden ratio landscape)
          legend.position="left",
          legend.justification = "top")
  
  
  p <- p + labs(title=paste0("Time Series plot for ", unique(dat$paramShortName)), 
                subtitle=paste0(unique(dat$stnlab)), 
                color=paste("Color:", color_var))+
            ylab(unique(dat$paramLAB))
  
  p
  
}#end function


#' theme_TS()
#'
#' @param base_family font
#' @param ... dots
#' @param base_size base_size
#' @param base_line_size base_line_size
#' @param base_rect_size base_rect_size
#' @param aspect.ratio aspect ration
#'
#' @return basic theme for time-series plots
#' @export
#'
#'
theme_TS <- function(base_size = 11, aspect.ratio = 2 / (1 + sqrt(5)), base_family = "", base_line_size = base_size/22,
                     base_rect_size = base_size/22, ...){
  
  theme_bw(base_size = base_size, base_family = base_family,
           base_line_size = base_line_size, base_rect_size = base_rect_size, ...) %+replace%
    theme(axis.title.x=element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          legend.title=element_blank(),
          axis.text.x = element_text(angle = 90),
          aspect.ratio = aspect.ratio,  #2 / (1 + sqrt(5)), # golden ratio landscape)
          legend.position="bottom",
          legend.justification = "right")
}
