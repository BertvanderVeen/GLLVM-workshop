# Practical 8 solutions: conditioning and partial ordination
# Builds on model1/model2/model3 as fitted in the practical.

library(gllvm)
TMB::openmp(parallel::detectCores() - 1, autopar = TRUE, DLL = "gllvm")

Y <- read.csv("../../data/waddenY2.csv")[, -c(1:2)]
Y <- Y[, colSums(ifelse(Y == 0, 0, 1)) > 2]
X <- read.csv("../../data/waddenX.csv")
X <- X[, !apply(X, 2, anyNA)]
X[, unlist(lapply(X, is.numeric))] <- scale(X[, unlist(lapply(X, is.numeric))])

model1 <- gllvm(Y, num.lv = 2, family = "tweedie", Power = NULL,
                 disp.formula = rep(1, ncol(Y)), n.init = 3, seed = 1:3, sd.errors = FALSE)
model2 <- gllvm(Y, num.lv = 2, family = "tweedie", Power = NULL,
                 disp.formula = rep(1, ncol(Y)),
                 row.eff = ~(1|island), studyDesign = X, n.init = 3, seed = 1:3, sd.errors = FALSE)

# Tasks I

# 1-2. Visual + quantitative comparison.
par(mfrow = c(1, 2))
ordiplot(model1, symbols = TRUE, s.cex = 1.5)
ordiplot(model2, symbols = TRUE, s.cex = 1.5)
vegan::procrustes(getLV(model1), getLV(model2), symmetric = TRUE)
# A larger Procrustes error here means island identity was driving a
# noticeable share of what model1's axes were picking up; a small error means
# the community gradient is fairly similar with or without island.

# 3. Condition on transect instead.
model2b <- gllvm(Y, num.lv = 2, family = "tweedie", Power = NULL,
                  disp.formula = rep(1, ncol(Y)),
                  row.eff = ~(1|island/transect), studyDesign = X, n.init = 3, seed = 1:3, sd.errors = FALSE)
vegan::procrustes(getLV(model2), getLV(model2b), symmetric = TRUE)
# Compare this Procrustes error to the model1-vs-model2 one: if it is small,
# transect-level variation on top of island was already fairly minor.

# 4. Conditioning changes what the axes represent: model1's axes reflect
# *all* community variation, island differences included; model2's axes
# reflect only the variation left *after* removing island, i.e. the residual
# community gradient once you already know which island a sample came from.
# The two are not directly comparable numbers, only comparable patterns.

# Tasks II

model3 <- gllvm(Y, X = X, lv.formula = ~season + TOC + elevation + silt_clay + Chl.a,
                 num.RR = 2, randomB = "LV", family = "tweedie", Power = NULL,
                 disp.formula = rep(1, ncol(Y)), row.eff = ~(1|island), studyDesign = X,
                 n.init = 3, seed = 1:3, sd.errors = FALSE)

# 1. Interpret which covariates drive the axes.
ses <- se.gllvm(model3); model3$sd <- ses$sd; model3$Hess <- ses$Hess
summary(model3)
# The longest arrows in the ordiplot (already shown in the practical) and the
# largest-magnitude canonical coefficients in summary() should point at the
# same one or two covariates as the main drivers.

# 2. Remove the conditioning.
model3_nocond <- gllvm(Y, X = X, lv.formula = ~season + TOC + elevation + silt_clay + Chl.a,
                        num.RR = 2, randomB = "LV", family = "tweedie", Power = NULL,
                        disp.formula = rep(1, ncol(Y)), n.init = 3, seed = 1:3, sd.errors = FALSE)
vegan::procrustes(getLV(model3), getLV(model3_nocond), symmetric = TRUE)
# Without conditioning, some of what the environmental covariates "explain"
# may really just be island identity riding along with them (if island and
# the environmental covariates are themselves correlated), inflating their
# apparent importance.

# 3. Concurrent instead of constrained.
model3_conc <- gllvm(Y, X = X, lv.formula = ~season + TOC + elevation + silt_clay + Chl.a,
                      num.lv.c = 2, randomB = "LV", family = "tweedie", Power = NULL,
                      disp.formula = rep(1, ncol(Y)), row.eff = ~(1|island), studyDesign = X,
                      n.init = 3, seed = 1:3, sd.errors = FALSE)
# num.RR discards everything the covariates do not explain; num.lv.c keeps a
# residual component too, so the ordination plot from model3_conc also
# reflects species associations not accounted for by season/TOC/elevation/
# silt_clay/Chl.a, on top of the environmentally-informed part.

# 4. Species-specific TOC effects.
# coefplot() does not work here: model3 puts its covariates in lv.formula with
# randomB, so there are no species-specific fixed slopes to plot and it stops
# with "No predictor effects to plot in the model". In a constrained ordination
# a species' covariate effect is its loading times the canonical coefficient,
# and randomCoefplot() is the function that assembles and plots exactly that.
randomCoefplot(model3, which.Xcoef = "TOC")

# Tasks III

# 1. Variance partitioning for model3.
VP(model3)
# Whichever component (an individual covariate, the row effect, or the
# residual LV part) has the largest mean-explained-variance bar is the
# dominant driver of community composition in this model.

# 2. More covariates: does explained variation increase?
model3_more <- gllvm(Y, X = X, lv.formula = ~season + TOC + elevation + silt_clay + Chl.a + DIN + RDP,
                      num.RR = 2, randomB = "LV", family = "tweedie", Power = NULL,
                      disp.formula = rep(1, ncol(Y)), row.eff = ~(1|island), studyDesign = X,
                      n.init = 3, seed = 1:3, sd.errors = FALSE)
VP(model3_more)
# Unlike ordinary fixed-effect R^2, this is not guaranteed to only increase:
# randomB = "LV" makes the canonical coefficients random effects with their
# own estimated covariance structure, which changes shape (not just size) when
# DIN/RDP are added, so there is no nested-optimum argument here, and the
# non-convex likelihood with only n.init = 3 adds its own risk of a worse
# local optimum for the larger model.

# 3. formula + lv.formula together.
model3_both <- gllvm(Y, X = X, formula = ~scale(TOC),
                      lv.formula = ~season + elevation + silt_clay + Chl.a,
                      num.RR = 2, randomB = "LV", family = "tweedie", Power = NULL,
                      disp.formula = rep(1, ncol(Y)), row.eff = ~(1|island), studyDesign = X,
                      n.init = 3, seed = 1:3, sd.errors = FALSE)
VP(model3_both)
# VP() now reports a separate bar for the species-specific TOC effect
# (formula) alongside the constrained-ordination covariates (lv.formula), the
# row effect, and any residual LVs, letting you see directly whether TOC is
# better treated as a full species-specific effect or folded into the
# ordination.

# 4. Grouping for "environment" vs. "residual" in VP(): pass `group` naming
# every lv.formula/formula covariate as "environment" and the row.eff/LV
# terms as "residual", e.g.
# VP(model3, group = c(rep("environment", 5), "residual"),
#    groupnames = c("environment", "residual"))
# (adjust the length/order of `group` to match VP(model3)'s own row order).

# 5. Residual covariance trace, conditioned vs. not.
getResidualCov(model1)$trace
getResidualCov(model2)$trace
# The intuitive answer ("conditioning removes island variation, so the residual
# trace must drop") turns out to be wrong here: model2's trace comes out
# *larger* than model1's. The trace only measures what the latent variables
# themselves absorb, and the LVs are re-estimated from scratch in each model,
# so removing island from the ordination does not shrink them in any
# guaranteed way. Conditioning changes what the residual covariance *means*
# (co-occurrence beyond island) rather than reliably reducing its size.
