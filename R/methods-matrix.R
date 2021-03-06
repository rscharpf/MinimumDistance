#' @param center ignored
#' @aliases calculateMindist,arrayORff_array-method
#' @rdname calculateMindist
setMethod("calculateMindist", signature(object="arrayORff_array"),
	  function(object, outdir, center, ...){
            ##stopifnot(ncol(object)==3)
            calculateMindistFromArray(object, outdir, ...)
	  })

#' @aliases calculateMindist,matrix-method
#' @rdname calculateMindist
setMethod("calculateMindist", signature(object="matrix"),
	  function(object, ...){
            calculateMindistFromMatrix(object)
	  })

calculateMindistFromMatrix <- function(object){
  ## assumes FMO ordering
  d1 <- object[, 3] - object[, 1] ##offspring - father
  d2 <- object[, 3] - object[, 2] ##offspring - mother
  I <- as.numeric(abs(d1) <= abs(d2))
  I*d1 + (1-I)*d2
}


calculateMindistFromArray <- function(object, outdir=ldPath(), ffprefix="", center=FALSE, ...){
  isff <- is(object, "ff")
  if(!parStatus()) registerDoSEQ()
  if(isff){
    if(!isPackageLoaded("ff")) stop(paste("array has class ", class(object)[[1]], " but the ff package is not loaded"))
    ## so that the worker nodes put the ff objects in the same directory
    ldPath(outdir)
    if(ffprefix != ""){
      ffname <- paste(ffprefix, "mindist", sep="_")
    } else ffname <- "mindist"
    md <- initializeBigMatrix(ffname, nr=nrow(object), nc=ncol(object), vmode="double")
    ##		lrrF <- object[, j, 1]
    ##		lrrM <- object[, j, 2]
    ##		lrrO <- object[, j, 3]
    ##		if(center){
    ##			medsO <- apply(lrrO, median, na.rm=TRUE)
    ##			medsM <- apply(lrrM, median, na.rm=TRUE)
    ##			medsF <- apply(lrrF, median, na.rm=TRUE)
    ##
    ##		}
    for(j in seq_len(ncol(object))){
      d1 <- object[, j, 3] - object[, j, 1] ## offspring - father
      d2 <- object[, j, 3] - object[, j, 2] ## offspring - mother
      I <- as.numeric(abs(d1) <= abs(d2))
      md[, j] <- I*d1 + (1-I)*d2
    }
    colnames(md) <- colnames(object)
  } else {
    d1 <- object[, , 3] - object[, , 1] ##offspring - father
    d2 <- object[, , 3] - object[, , 2] ##offspring - mother
    I <- as.numeric(abs(d1) <= abs(d2))
    md <- I*d1 + (1-I)*d2
    md <- as.matrix(md)
    colnames(md) <- colnames(object)
  }
  return(md)
}
