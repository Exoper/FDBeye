##' @title Plot Gaze Fixation Data Over a Bitmap
##'
##' @description Plot gaze fixation data overlayed on a bitmap image. This is a convenience wrapper
##'     around ggplot2::ggplot().
##'
##' @details This is a convenience function for using ggplot() to lay fixation data over a
##'     background bitmap. At present, only PNG files are supported for background images. Usually,
##'     these will correspond to the visual stimulus viewed by subjects while gaze was
##'     recorded. Function returns a ggplot2 object which can be further modified by ggplot2 geoms.
##'
##' @param data A data.frame containing one fixation per row. Must include at least x and y
##'     coordinates. Origin is assumed to be upper left corner.
##' @param bgImage Path to background image. Must be a PNG file. Usually this will correspond to the
##'     visual stimulus being viewed by subjects while their eye movements were recorded.
##' @param bgAlpha Alpha level for background layer. Defaults to .33.
##' @param xyMap Aesthetic mapping (ggplot2::aes_string()) for x and y coordinates. Passed to
##'     ggplot().
##' @param pointMap Additional aesthetics specific to points. Passed to geom_point().
##' @param pointAlpha Set fixation point transparency. Defaults to .5.
##' @param mar A 4 vector for margin adjustment (x & y scale limits): top, right, bottom, left. Use
##'     positive values move margins toward center of plot (trim the display area). Use negative
##'     values to expand the display area beyond the bitmap.
##' @param ... Additional arguments passed to ggplot2::geom_point().
##' @param showPlot Logical indicating whether to display the plot. Defaults to TRUE.
##' @return A ggplot2 object.
##' @author Dave Braze \email{davebraze@@gmail.com}
##' @import ggplot2
##' @export
##' @examples
##' data <- data.frame(x=seq(10, 1270, length.out=10),
##'               y=seq(10, 1014, length.out=10))
##' bg <- system.file("extdata/story01.png", package="FDBeye")
##' fixPlot(data = data,
##'         bgImage = bg,
##'         xyMap = ggplot2::aes_string(x='x', y='y'),
##'         pointMap =ggplot2::aes_string())
##'
##' data(EToralreading)
##' D <- EToralreading
##' D$label <- as.factor(as.integer(D$label))
##'
##' fixPlot(data=subset(D, subset=(subj=="s0149")&(story=="1")&(label %in% as.character(1:13))),
##'         bgImage=system.file("extdata/story01.png", package="FDBeye"),
##'         pointMap=ggplot2::aes_string(color="as.factor(as.integer(label)%%3)"), size=5,
##'                                      pointAlpha=.5)
fixPlot <- function(data,
                    bgImage=NULL,
                    bgAlpha=.33,
                    xyMap=ggplot2::aes_string(x="xpos", y="ypos"),
                    pointMap=ggplot2::aes_string(size="dur"),
                    pointAlpha=.5,
                    mar=c(0,0,0,0),
                    ...,
                    showPlot=TRUE) {

    if (!is.null(bgImage)) {
        bg <- png::readPNG(bgImage) # Look into imager::, maybe also see what EBImage:: has to offer?
        ysize <- dim(bg)[1]
        xsize <- dim(bg)[2]
        zsize <- dim(bg)[3]
        bgAlpha <- matrix(bgAlpha, ysize, xsize)
        if(zsize==3) {                  ## add an alpha layer if none is present
            bg <- abind::abind(bg, bgAlpha)
        } else if (zsize==4) {          ## or over-write existing alpha layer
            bg <- abind::abind(bg[,,1:3], bgAlpha)
        }
        bg <- grid::rasterGrob(bg)
        expand <- c(0,0)
    } else {
        xsize <- ysize <- zsize <- 0
        mar <- c(NA, NA, NA, NA)
        expand <- c(0.05, 0) # default for continuous variables
    }

    p <- ggplot(data=data, mapping=xyMap) + geom_blank()
    p <- p + coord_equal()
    p <- p + scale_x_continuous(limits=c(0+mar[4],xsize-mar[2]), ## need to make better choices for tic positions when margins are in place.
                                expand=expand)
    p <- p + scale_y_continuous(limits=c(ysize-mar[3], 0+mar[1]),
                                trans="reverse",
                                expand=expand)
    if (!is.null(bgImage)) {
        p <- p + annotation_custom(bg,
                                   xmin=0, ymin=-ysize,
                                   xmax=xsize, ymax=0)
    }
    p <- p + geom_point(mapping=pointMap, alpha=pointAlpha, ...)

    ## show the fixation plot
    if (showPlot) print(p)

    ## return a ggplot2 object
    invisible(p)

}

if(FALSE) {

    data <- data.frame(x=seq(10, 1270, length.out=10),
                  y=seq(10, 1014, length.out=10))

    fixPlot(data = data,
            bgImage = "../inst/extdata/story01.png",
            xyMap = ggplot2::aes_string(x='x', y='y'),
            pointMap = ggplot2::aes_string())

}

