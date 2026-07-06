## ============================================================================
## Coolen et al. (2020) North Sea offshore-platform epifauna survey
## -> gllvm-ready data
##
## Source (open access): Coolen et al. (2020), ICES J. Mar. Sci. 77(3):1250-1266
## https://doi.org/10.1093/icesjms/fsz082
##
## Produces:
##   coolen$Y       : 114 sites x 317 taxa (integers, 0 NAs)
##   coolen$X       : 114-row data.frame with SampleType, Depth, age,
##                    PlatformID, LatStart, LonStart
##   coolen$is_bern : logical[317]; TRUE = taxon is strictly 0/1 (n=131)
##
## Response-type classification (derived from data, not assumed):
##   131 taxa: strictly 0/1 -> binomial with Ntrials = 1 (Bernoulli)
##   186 taxa: integer counts with max > 1 -> negative.binomial
##     Overdispersion: median var/mean = 9.2; 78% of count taxa have
##     dispersion index > 2; Poisson is not defensible for any of them.
##
## Colonial taxa: Porifera, Sycon ciliatum, and Halichondria panicea are
## colonial organisms; recorded "counts" represent sponge patches/colonies,
## not individuals.  Negative binomial remains appropriate for overdispersed
## non-negative integers regardless of counting unit; ecological
## interpretation of those taxa's parameters differs accordingly.
## ============================================================================

load_coolen <- function(path = "data/Coolen.RData") {
  e <- new.env(parent = emptyenv())
  load(path, envir = e)

  Ymat <- as.matrix(e$Y)
  storage.mode(Ymat) <- "numeric"
  rownames(Ymat) <- e$X$sample

  ## Standardise taxon names: runs of dots or spaces -> single underscore,
  ## no trailing underscores.
  colnames(Ymat) <- gsub("_+$", "",
                         gsub("[. ]+", "_", colnames(Ymat)))

  ## Drop never-observed taxa (none expected in this dataset, but defensive).
  Ymat <- Ymat[, colSums(Ymat) > 0, drop = FALSE]

  X <- data.frame(
    SampleType = factor(e$X$SampleType),
    Depth      = e$X$Depth,
    age        = e$X$age,
    PlatformID = factor(e$X$PlatformID),
    LatStart   = e$X$LatStart,
    LonStart   = e$X$LonStart,
    row.names  = e$X$sample,
    stringsAsFactors = FALSE
  )

  is_bern <- apply(Ymat, 2, function(x) all(x %in% c(0, 1)))

  stopifnot(nrow(Ymat) == 114, nrow(X) == 114)
  stopifnot(ncol(Ymat) == 317)
  stopifnot(sum( is_bern) == 131)
  stopifnot(sum(!is_bern) == 186)
  stopifnot(all(!is.na(Ymat)))

  list(Y = Ymat, X = X, is_bern = is_bern)
}

coolen <- load_coolen()
str(coolen, max.level = 1)
