#' @title Semi-partial R^2 for model-based ordination
#' @description  
#' 
#' @param object an object of class 'gllvm'.
#' @param ... not used
#' 
#' @details
#' For a model-based constrained or concurrent ordination, we can consider the latent variable to consist of a fixed-effects and a latent-effects term (zero of non-zero). Equivalently, this is a linear regression of the latent variable. Since the response is technically unmeasured, it i snot possible to calculate a convential R^2 measure. As such, this function calculates a semi-partial R^2, which can assist with determining goodness of fit of the regression fo the latent variables (overall, or per predictor).
#' 
#' @author Bert van der Veen
#' @references
#' Edwards, L. J., Muller, K. E., Wolfinger, R.D., Qagish, B.F., and Schabenberger O. (2008). An R2 statistic for fixed effects in the linear mixed model.
#' Jaeger, B. C., Edwards, L. J., Das, K., and Sen P.K. (2017). An R2 statistic for fixed effects in the generalized linear mixed model
#' 
#' @examples
#' \dontrun{
#'# Load a dataset from the mvabund package
#'data(spider)
#'y <- as.matrix(spider$abund)
#'x <- as.matrix(spider$x)
#'# Fit gllvm with constrained latent variables
#'fit <- gllvm(y = y, X=x, num.lv.c=2, family = poisson())
#'# semi-partial R^2:
#'partR2(fit)
#'}
#'@aliases partR2 partR2.gllvm
#'@method partR2 gllvm
#'@export
#'@export partR2.gllvm

partR2.gllvm <- function(object, digits = 3L, ...){
  if(object$num.lv.c==0&object$num.RR==0){
    stop("Cannot calculate partial R^2 for the latent variables if no predictor are included. \n")
  }
  if(is.null(object$sd)|all(unlist(object$sd)==FALSE)){
    cat("Standard errors not present in model, calculating...\n")
    object$Hess<-se.gllvm(object)$Hess 
  }
  covB <- object$Hess$cov.mat.mod
  colnames(covB) <- row.names(covB) <- names(object$TMBfn$par)[object$Hess$incl]
  covB <- covB[row.names(covB)=="b_lv",colnames(covB)=="b_lv"]
  K <- ncol(object$lv.X)
  N <- nrow(object$lv.X)
  d <- object$num.lv.c+object$num.RR
  df=d*K
  resid.df = dim(object$y)[1]*d-df
  num.df <- d
  partR2<-rep(0,ncol(object$lv.X))
  names(partR2)<-colnames(object$lv.X)
  
  for(i in 1:ncol(object$lv.X)){
    covBinv <- try(solve(covB[seq(i,K*d,by=K),seq(i,K*d,by=K)]),silent=T)
    if(inherits(covBinv,"try-error")){
      covBinv <- MASS::ginv(covB[seq(i,K*d,by=K),seq(i,K*d,by=K)],tol=0)
    }
    Ft <- object$params$LvXcoef[i,]%*%covBinv%*%object$params$LvXcoef[i,]/d
    partR2[i]<-(num.df*resid.df^-1*Ft)/(1+num.df*resid.df^-1*Ft)
  }

  covBinv <- try(solve(covB),silent=T)
  if(inherits(covBinv,"try-error")){
    covBinv <- MASS::ginv(covB)
  }
  
  Ftfull <- c(object$params$LvXcoef)%*%covBinv%*%c(object$params$LvXcoef)/(K*d)
  
  partR2f<-(df*resid.df^-1*Ftfull)/(1+df*resid.df^-1*Ftfull)

  cat("R^2 for latent variables:", zapsmall(partR2f,digits), "\n \n")
  cat("Partial R^2 for predictors and all LVs: \n")
  print(zapsmall(partR2,digits))
  
  invisible(list(partR2full=partR2f,partR2=partR2))
}

#'@export partR2
partR2 <- function(object, ...)
{
  UseMethod(generic = "partR2")
}
