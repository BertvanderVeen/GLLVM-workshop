# Practical 6 solutions: model-based ordination
# Builds on model1/model2 (Part I) and model5/model6 (Part II).

library(gllvm)
TMB::openmp(parallel::detectCores() - 1, autopar = TRUE, DLL = "gllvm")

Y <- read.csv("../../data/roadY.csv")[, -1] / 100
X <- read.csv("../../data/roadX.csv")[, -1]
X$site <- as.factor(X$site)
X <- data.frame(lapply(X, function(x) if (is.numeric(x)) scale(x) else as.factor(x)))
Y2 <- Y[, colSums(ifelse(Y == 0, 0, 1)) > 3]

model1 <- gllvm(y = Y, num.lv = 2, family = "orderedBeta", disp.formula = rep(1, ncol(Y)),
                 n.init = 5, sd.errors = FALSE)
model2 <- gllvm(y = Y2, num.lv = 2, family = "orderedBeta", disp.formula = rep(1, ncol(Y2)),
                 n.init = 5, sd.errors = FALSE)

# Tasks I

# 1. Fit + clean up the plot: fewer/no species labels, sites only.
ordiplot(model1, biplot = FALSE, symbols = TRUE)
ordiplot(model1, biplot = TRUE, spp.colors = "grey70", cex.spp = 0.5)
# ?ordiplot: `biplot`, `ind.spp` (subset of species shown), `spp.colors`,
# `symbols`, and `s.colors` are the usual levers for decluttering a busy plot.

# 2. Condition on a random or fixed effect, compare with AIC/BIC.
model3 <- gllvm(y = Y2, num.lv = 2, family = "orderedBeta", disp.formula = rep(1, ncol(Y2)),
                 starting.val = "res", row.eff = ~(1|site), studyDesign = X,
                 sd.errors = FALSE, seed = 2, n.init = 5)
AIC(model2, model3)
BIC(model2, model3)
# Boundary comparison (adds a row.eff variance, Practical 2's Hypothesis
# Testing section); read cautiously, not as a clean test.

# 3. Residual diagnostics regardless of how the ordination plot looks.
plot(model3, which = c(1, 2))
# A good-looking ordination can still sit on top of a badly-fitting model
# (wrong family, missed overdispersion, etc.), and vice versa; always check
# the Dunn-Smyth residuals independently of how convincing the biplot looks.

# Tasks II

X$plot <- factor(ave(seq_along(X$site), X$site, FUN = seq_along))

# 1. Site-level (rather than observation-level) ordination via lvCor.
model5 <- gllvm(y = Y2, num.lv = 2, family = "orderedBeta", n.init = 10,
                 lvCor = ~(1|site), studyDesign = X[, "site", drop = FALSE],
                 disp.formula = rep(1, ncol(Y2)), sd.errors = FALSE)
gllvm::ordiplot(model5)
# This collapses num.lv * nrow(Y2) site-scores down to num.lv * n_sites (2*20
# instead of 2*282): every replicate plot at a site now shares the same
# ordination position, so the sampling variation between replicates has to be
# picked up elsewhere, or it leaks into the residuals. The residual plot below
# colours by site and shows exactly that leftover within-site variation.
resi <- residuals(model5)$resi
fitted5 <- predict(model5)
plot(c(resi) ~ c(fitted5), col = rep(X$site, times = ncol(model5$y)),
     xlab = "Linear predictor", ylab = "Dunn-Smyth residuals")

# model6 is the fix: keep the site-level ordination, but add a nested random
# row effect so the within-site (plot) variation is modelled rather than dumped
# into the residuals.
model6 <- gllvm(y = Y2, num.lv = 2, family = "orderedBeta", n.init = 5,
                 lvCor = ~(1|site), studyDesign = X[, c("plot", "site")],
                 disp.formula = rep(1, ncol(Y2)), row.eff = ~(1|site/plot),
                 sd.errors = FALSE)
resi6 <- residuals(model6)$resi
fitted6 <- predict(model6)
plot(c(resi6) ~ c(fitted6), col = rep(X$site, times = ncol(model6$y)),
     xlab = "Linear predictor", ylab = "Dunn-Smyth residuals")
# Compare the two residual plots: the within-site spread should be visibly
# reduced once site/plot is in the model.
