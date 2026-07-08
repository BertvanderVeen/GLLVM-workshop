# Auto-generated from Practicals/Rmd/10Practical.Rmd via knitr::purl(). Do not edit directly -- re-run after editing the Rmd. See Practicals/R/README.md.

library(gllvm)
TMB::openmp(parallel::detectCores()-1, autopar = TRUE, DLL = "gllvm")

Y <- read.csv("../../data/waddenY2.csv")[, -c(1:2)]
Y <- Y[, colSums(ifelse(Y == 0, 0, 1)) > 2]
X <- read.csv("../../data/waddenX.csv")
X <- X[, !apply(X, 2, anyNA)]
X[, unlist(lapply(X, is.numeric))] <- scale(X[, unlist(lapply(X, is.numeric))])

# Baseline: independent latent variables
model_iid <- gllvm(Y, num.lv = 2, family = "tweedie", Power = NULL,
                   disp.formula = rep(1, ncol(Y)), n.init = 3)

# AR(1) structure across seasons in the row effect
model_ar1 <- gllvm(Y, num.lv = 2, family = "tweedie", Power = NULL,
                   disp.formula = rep(1, ncol(Y)),
                   studyDesign = X[, "season", drop = FALSE],
                   row.eff = ~corAR1(1|season), n.init = 3)

AIC(model_iid, model_ar1)

model_ar1$params$sigma  # the ".rho"-suffixed entry is the temporal correlation between seasons

# Simulate spatial coordinates for the wadden sites
set.seed(42)
n_sites <- nrow(Y)
coords <- data.frame(
  lon = runif(n_sites, 0, 100),
  lat = runif(n_sites, 0, 100)
)
dist_mat <- as.matrix(dist(coords))

# model_spatial <- gllvm(Y, num.lv = 2, family = "tweedie", Power = NULL,
#                        disp.formula = rep(1, ncol(Y)),
#                        lvCor = ~corExp(1|site),
#                        studyDesign = data.frame(site = factor(1:nrow(Y))),
#                        distLV = dist_mat,
#                        Lambda.struc = "UNN", NN = 5,
#                        n.init = 1)

Y_mixed <- Y
Y_mixed[, 1:10] <- ifelse(Y_mixed[, 1:10] > 0, 1, 0)

family_vec <- c(rep("binomial", 10), rep("negative.binomial", ncol(Y_mixed) - 10))

model_mixed <- gllvm(Y_mixed, num.lv = 2, family = family_vec, n.init = 3, sd.errors = FALSE)
