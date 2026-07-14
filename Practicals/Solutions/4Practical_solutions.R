# Practical 4 solutions: Joint Species Distribution Models
# Builds on model1/model2 from the alpine JSDM practical.

library(gllvm)
TMB::openmp(parallel::detectCores() - 1, DLL = "gllvm", autopar = TRUE)

Y <- read.csv("../../data/alpineY.csv")[, -1]
X <- read.csv("../../data/alpineX.csv")[, -1]
X <- X[rowSums(Y) > 0, ]
Y <- Y[rowSums(Y) > 0, ]

# These fits can run off to an infinite log-likelihood from a bad starting
# value (the num.lv = 1 fit below is especially prone to it), which then shows
# up much later as a confusing error inside predict()/goodnessOfFit(). Several
# restarts with fixed seeds keep every fit here reproducible and finite.
model1 <- gllvm(y = Y, num.lv = 2, family = "binomial", Lambda.struc = "diagonal",
                 sd.errors = FALSE, optim.method = "L-BFGS-B", n.init = 3, seed = 1:3)
model2 <- gllvm(y = Y, X = X, formula = ~ scale(SLOPE), num.lv = 2, family = "binomial",
                 Lambda.struc = "diagonal", sd.errors = FALSE, optim.method = "L-BFGS-B",
                 n.init = 3, seed = 1:3)

# Tasks I

# 1. Random instead of fixed slope effect.
model2_random <- gllvm(y = Y, X = X, formula = ~ (0+scale(SLOPE)|1), num.lv = 2,
                        family = "binomial", Lambda.struc = "diagonal",
                        sd.errors = FALSE, optim.method = "L-BFGS-B",
                        n.init = 3, seed = 1:3)
AIC(model2, model2_random)
# 175 species-specific fixed slopes vs. one variance parameter: whichever wins
# on AIC tells you whether species differ enough in their slope
# for slope to be worth estimating per species.

# 2. The predict-on-a-map code, step by step: (i) build a new X matrix from
# the raster's slope values, standardized the same way SLOPE was in the model;
# (ii) compute the linear predictor eta = X %*% t(coefficients); (iii) apply
# the inverse link (probit -> pnorm) to get predicted probabilities; (iv) put
# the predictions back into a raster with one layer per species. The built-in
# predict() does the same thing for models without species-specific random
# effects:
slp_scale <- scale(X$SLOPE)
newX <- data.frame(SLOPE = seq(min(X$SLOPE), max(X$SLOPE), length.out = 100))
pred_builtin <- predict(model2, newX = newX, type = "response", level = 0)
dim(pred_builtin)  # 100 x n species, one predicted probability curve per species

# Tasks II

# 1. Fit the LV-only model and visualize associations (already model1 above).
corrplot::corrplot(getResidualCor(model1), type = "lower", order = "AOE",
                    diag = FALSE, tl.pos = "l", tl.cex = 0.2, addgrid.col = NA)

# 2. Compare number of latent variables with goodnessOfFit.
model_lv1 <- gllvm(y = Y, num.lv = 1, family = "binomial", Lambda.struc = "diagonal",
                    sd.errors = FALSE, optim.method = "L-BFGS-B", n.init = 3, seed = 1:3)
model_lv3 <- gllvm(y = Y, num.lv = 3, family = "binomial", Lambda.struc = "diagonal",
                    sd.errors = FALSE, optim.method = "L-BFGS-B", n.init = 3, seed = 1:3)
sapply(list(lv1 = model_lv1, lv2 = model1, lv3 = model_lv3),
       function(m) goodnessOfFit(Y, object = m, measure = "TjurR2")$TjurR2)
AIC(model_lv1, model1, model_lv3)
# Discriminative power (Tjur's R2) should increase with more LVs in principle,
# but these fits use a single starting value, so a worse local optimum could
# reverse that in practice. num.lv is a rank-selection question (like choosing
# factors in a factor analysis), not a boundary test, so treat AIC as a guide.

# 3. Combine LVs with several covariates.
model_full <- gllvm(y = Y, X = X, formula = ~ scale(DDEG0) + scale(SLOPE) +
                       scale(MIND) + scale(SOLRAD) + scale(TPI),
                     num.lv = 2, family = "binomial", Lambda.struc = "diagonal",
                     sd.errors = FALSE, optim.method = "L-BFGS-B", n.init = 3, seed = 1:3)

# 4. Interpret: coefplot/randomCoefplot/summary need standard errors first.
ses <- se.gllvm(model_full); model_full$sd <- ses$sd; model_full$Hess <- ses$Hess
coefplot(model_full, which.Xcoef = "scale(SLOPE)")  # fixed effects
summary(model_full)

# randomCoefplot is the counterpart of coefplot for *random* species-specific
# effects, so it applies to the random-slope model from Task I.1, not to
# model_full (whose slopes are all fixed).
ses_r <- se.gllvm(model2_random)
model2_random$sd <- ses_r$sd; model2_random$Hess <- ses_r$Hess
randomCoefplot(model2_random, which.Xcoef = 1)
# The random-effect version shrinks species' slopes towards the community mean,
# so its intervals are narrower and fewer species sit far from zero than in the
# fixed-effect coefplot.
# Compare model_full's slope coefficients to model2's (same num.lv = 2, only
# SLOPE): if species' slope estimates shift noticeably once the other
# covariates are added, the simpler model was picking up confounded effects
# (e.g. SLOPE correlated with SOLRAD or TPI at these sites).
