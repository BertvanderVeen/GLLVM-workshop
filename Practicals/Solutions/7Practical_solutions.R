# Practical 7 solutions: ordination with covariates
# Builds on model1-model7 as fitted in the practical.

library(gllvm)
TMB::openmp(parallel::detectCores() - 1, autopar = TRUE, DLL = "gllvm")

Y <- read.csv("../../data/roadY.csv")[, -1] / 100
Y <- Y[, colSums(ifelse(Y == 0, 0, 1)) > 3]
X <- read.csv("../../data/roadX.csv")[, -1]
X$site <- as.factor(X$site)
X <- data.frame(lapply(X, function(x) if (is.numeric(x)) scale(x) else as.factor(x)))
X$plot <- factor(ave(seq_along(X$site), X$site, FUN = seq_along))

zetaMap <- matrix(NA, nrow = 2, ncol = ncol(Y))
zetaMap[1, ] <- 1:ncol(Y)
zetaMap[2, which(apply(Y, 2, max) == 1)] <- ncol(Y) + 1
zetaMap[2, which(apply(Y, 2, max) != 1)] <- NA
setMap <- list(zeta = factor(c(zetaMap)))

lvf <- ~dist_int_veg + caco + slope + loi + grain_size_stand_f + years_since_n + gf

# Tasks I

# 1. Fixed-effects constrained ordination (already model1 in the practical).
model1 <- gllvm(y = Y, X = X, lv.formula = lvf, num.RR = 2, family = "orderedBeta",
                 disp.formula = rep(1, ncol(Y)), n.init = 3,
                 zetacutoff = c(-2, 20), setMap = setMap, sd.errors = FALSE)
ordiplot(model1)

# 2. Concurrent ordination, compare to constrained.
model2 <- gllvm(y = Y, X = X, lv.formula = lvf, num.RR = 2, row.eff = ~(1|site/plot),
                 studyDesign = X, family = "orderedBeta", disp.formula = rep(1, ncol(Y)),
                 zetacutoff = c(-2, 20), setMap = setMap, sd.errors = FALSE)
model3 <- gllvm(y = Y, X = X, lv.formula = lvf, num.lv.c = 2, row.eff = ~(1|site/plot),
                 studyDesign = X, family = "orderedBeta", disp.formula = rep(1, ncol(Y)),
                 n.init = 10, zetacutoff = c(-2, 20), setMap = setMap, sd.errors = FALSE)
vegan::procrustes(getLV(model2), getLV(model3), symmetric = TRUE)
# A small Procrustes error means the two ordinations agree closely, i.e. these
# covariates already explain most of what the unconstrained residual axes
# would otherwise be picking up; a larger error means the environment leaves
# real structure on the table that concurrent ordination recovers and
# constrained ordination (model2) discards.

# 3. ordiplot type = "residual"/"marginal"/"conditional" for the concurrent model.
ordiplot(model3, type = "residual")     # only the residual (unconstrained) part
ordiplot(model3, type = "marginal")     # only the covariate-informed part
ordiplot(model3, type = "conditional")  # both combined (the default)
# "marginal" isolates what the measured covariates explain, "residual" isolates
# what is left over (candidate for missing covariates or species
# interactions), and "conditional" is the full picture used for prediction.

# 4. Species-specific effects vs. the ordination plot.
ses <- se.gllvm(model2); model2$sd <- ses$sd; model2$Hess <- ses$Hess
coefplot(model2, which.Xcoef = "slope")
# Species whose confidence interval for "slope" excludes zero in coefplot
# should also be the ones sitting furthest along the "slope" arrow direction
# in the ordination biplot; species with a wide/zero-crossing interval will
# often sit close to the plot's centre.

# 5. Hypothesis tests: constrained ordination nested in concurrent, tested
# against an unconstrained baseline.
model4 <- gllvm(y = Y, X = cbind(X, obs = factor(1:nrow(X))), lv.formula = ~obs,
                 num.RR = 2, row.eff = ~(1|site/plot), studyDesign = X,
                 family = "orderedBeta", disp.formula = rep(1, ncol(Y)),
                 zetacutoff = c(-2, 20), setMap = setMap, sd.errors = FALSE)
anova(model2, model4)
# model2 vs. model4: is constraining to these covariates better than letting
# every observation have its own fixed LV score? Ordinary fixed-effect test.
model5 <- gllvm(y = Y, num.lv = 2, row.eff = ~(1|site/plot), studyDesign = X,
                 family = "orderedBeta", disp.formula = rep(1, ncol(Y)),
                 zetacutoff = c(-2, 20), setMap = setMap, sd.errors = FALSE)
anova(model3, model5)
# model3 vs. model5: do the covariates improve on a fully unconstrained
# ordination? Ordinary fixed-effect test.
AIC(model2, model3)
# model2 vs. model3: is concurrent worth the extra residual axes over plain
# constrained? A rank-selection question (like num.lv in Practicals 4 and 5),
# not a formal test, so AIC only, read as a guide.

# Tasks II

# 1. Random canonical coefficients (already model6/model7 in the practical).
rlvf <- ~(0+dist_int_veg|1) + (0+caco|1) + (0+slope|1) + (0+loi|1) +
  (0+grain_size_stand_f|1) + (0+years_since_n|1) + (0+gf|1)
model6 <- gllvm(y = Y, X = X, lv.formula = rlvf, num.RR = 2, randomB = "P",
                 family = "orderedBeta", disp.formula = rep(1, ncol(Y)), n.init = 10,
                 zetacutoff = c(-2, 20), setMap = setMap, sd.errors = FALSE)

# 2. Compare to the fixed-effects version (model1).
vegan::procrustes(getLV(model1), getLV(model6), symmetric = TRUE)
# Random canonical coefficients shrink noisy/collinear covariate effects
# towards the community-average, so expect the ordination to be broadly
# similar in its main pattern but somewhat more conservative (less extreme
# arrow lengths) than the fixed-effects version.

# 3. Environmental associations between species.
model7 <- gllvm(y = Y, X = X, lv.formula = rlvf, num.RR = 2, randomB = "LV",
                 family = "orderedBeta", disp.formula = rep(1, ncol(Y)), n.init = 10,
                 zetacutoff = c(-2, 20), setMap = setMap, sd.errors = FALSE)
corrplot::corrplot(getEnvironCor(model7), type = "lower", order = "AOE",
                    diag = FALSE, tl.pos = "l", tl.cex = 0.2, addgrid.col = NA)
# A strong positive entry means those two species tend to respond to the
# environmental gradient in the same direction (likely to co-occur because of
# shared environmental preference, not necessarily biotic interaction); this
# is the "due to environment" analogue of the residual-association corrplots
# from the JSDM practical.
