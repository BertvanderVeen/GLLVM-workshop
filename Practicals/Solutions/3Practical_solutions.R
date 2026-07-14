# Practical 3 solutions: hierarchically modeling environmental responses
# Fourth-corner (trait) models, using the beetles data as in the practical.
# Part II (phylogeny) has no separate numbered task list in the practical;
# it is a long worked example you follow through directly (see the note at
# the bottom for how to make it faster if you are compute-constrained).

library(gllvm)

Y <- t(read.csv("../../data/beetlesY.csv"))
colnames(Y) <- Y[2, ]
Y <- Y[-c(1:2), -c(1, 70:71)]
Y <- as.data.frame(apply(Y, 2, as.integer))

X <- read.csv("../../data/beetlesX.csv")[, -c(1:5)]
X <- as.data.frame(apply(X, 2, as.numeric))
X$Sampling.year <- X$Sampling.year - min(X$Sampling.year)
X$Texture <- as.factor(X$Texture)

TR <- read.csv("../../data/beetlesTR.csv")
row.names(TR) <- TR$SPECIES
TR <- TR[, -c(1:3)]
TR[, c("CLG","CLB","WIN","PRS","OVE","FOA","DAY","BRE","EME","ACT")] <-
  apply(TR[, c("CLG","CLB","WIN","PRS","OVE","FOA","DAY","BRE","EME","ACT")], 2,
        function(x) as.factor(gsub("\\?.*", "", x)))

X  <- scale(model.matrix(~., X))[, -1]
TR <- scale(model.matrix(~., TR))[, -1]

# Tasks I

# 1. Fit the models with a subset of traits/environmental variables. Here:
# drop the breeding-period traits (BRE2, BRE3) to see if the fourth corner
# and its interpretation change much.
model1_alt <- gllvm(y = Y, X = X, TR = TR,
                    formula = ~ Management + Elevation + pH + Moist +
                      (Management + Elevation + pH + Moist):(LPH + LTL + OVE2),
                    family = "negative.binomial", num.lv = 0, sd.errors = FALSE)
ses <- se.gllvm(model1_alt)  # summary() prints no coefficients without these
model1_alt$sd <- ses$sd; model1_alt$Hess <- ses$Hess
summary(model1_alt)
# Fewer trait interactions to interpret, at the cost of ignoring whatever
# variation the breeding-period traits were explaining (it ends up in the
# residual species-specific responses instead, if those are included).

# 2. Fourth-corner coefficients and the species-common effects together.
model1 <- gllvm(y = Y, X = X, TR = TR,
                formula = ~ Management + Elevation + pH + Moist +
                  (Management + Elevation + pH + Moist):(LPH + LTL + OVE2 + BRE2 + BRE3),
                family = "negative.binomial", num.lv = 0, sd.errors = FALSE)
ses <- se.gllvm(model1); model1$sd <- ses$sd; model1$Hess <- ses$Hess
gllvm:::getFourthCorner(model1)  # trait x environment interaction coefficients
summary(model1)                  # also reports the species-common (non-trait) main effects
# Read a fourth-corner cell as: "species with a higher value of this trait
# respond more positively (or negatively) to this environmental variable, on
# top of the shared species-common response reported separately in summary()."

# 3. Hypothesis test: does species response really depend on the traits?
model2 <- gllvm(y = Y, X = X, TR = TR,
                formula = ~ Management + Elevation + pH + Moist +
                  (Management + Elevation + pH + Moist):(LPH + LTL + OVE2 + BRE2 + BRE3) +
                  (0+Management + Elevation + pH + Moist|1),
                family = "negative.binomial", num.lv = 0, n.init = 3, sd.errors = FALSE)
model3 <- gllvm(y = Y, X = X,
                formula = ~ (0+Management + Elevation + pH + Moist|1),
                family = "negative.binomial", num.lv = 0, n.init = 3, sd.errors = FALSE)
anova(model2, model3)
# p < 0.05: rejects the null of no trait effect, so measured traits carry real
# information about species' environmental responses.

# Part II (phylogeny): no separate task list
# Follow the worked example in the Rmd (model4, model5, model6) directly. If
# you are short on compute time, subset to fewer species/sites before fitting,
# e.g.:
# data(fungi, package = "gllvm")
# keep <- sample(ncol(fungi$Y), 50)          # 50 random species instead of 215
# Y2 <- fungi$Y[, keep]
# and correspondingly subset covMat/distMat/TR to the same species before
# re-running gllvm:::findOrder() and the phylogenetic model.
