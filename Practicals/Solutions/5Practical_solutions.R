# Practical 5 solutions: predicting species richness
# Builds on model0, model1, modelB_lin as fitted in the practical.

library(gllvm)
TMB::openmp(parallel::detectCores() - 1, autopar = TRUE, DLL = "gllvm")

Y <- read.csv("../../data/alpineY.csv")[, -1]
X <- read.csv("../../data/alpineX.csv")[, -1]
X <- X[rowSums(Y) > 0, ]
Y <- Y[rowSums(Y) > 0, ]
X_sc <- data.frame(scale(X[, sapply(X, is.numeric)]))
obs_sr <- rowSums(Y)
elev_seq <- seq(min(X_sc$ELEV), max(X_sc$ELEV), length.out = 100)
newX <- data.frame(ELEV = elev_seq)

model0 <- gllvm(y = Y, X = X_sc, formula = ~ELEV, num.lv = 0, family = "binomial",
                 seed = 1, sd.errors = FALSE)

# Tasks I

# 1. Does the model capture observed richness without latent variables?
srNew0_task1 <- predictSR(model0, newX = newX, level = 0, se.fit = FALSE)
plot(X_sc$ELEV, obs_sr, xlab = "Elevation (scaled)", ylab = "Species richness",
     pch = 16, col = "grey50")
lines(elev_seq, srNew0_task1$expected$fit, col = "red", lwd = 2)
# The curve tracks the general decline in richness with elevation, but the
# observed points scatter widely around it: with num.lv = 0 there is nothing in
# the model to absorb residual co-occurrence structure, so site-level departures
# from the elevation trend go unexplained.

# 2-3. Poisson-Binomial vs. Poisson variance.
pred_probs <- predict(model0, type = "response")
exp_sr <- rowSums(pred_probs)
var_sr <- rowSums(pred_probs * (1 - pred_probs))
mean(var_sr < exp_sr)  # fraction of sites where PB variance is below the Poisson line
# Var(PB) = sum(p_i(1-p_i)) = sum(p_i) - sum(p_i^2) <= sum(p_i) = mean always,
# since p_i(1-p_i) <= p_i for any 0 <= p_i <= 1. num.lv = 0 assumes species
# respond independently, so this underdispersion is a mathematical property of
# summing bounded [0,1] probabilities, not a sign of species co-occurrence; a
# Poisson model would still overstate the uncertainty in richness here.

# 4. Low-diversity (high-elevation) subset.
high_elev <- X_sc$ELEV > quantile(X_sc$ELEV, 0.75)
plot(exp_sr[high_elev], var_sr[high_elev], xlab = "Expected richness (high elev.)",
     ylab = "Predicted variance", pch = 16, col = "steelblue")
abline(0, 1, col = "red", lty = 2)
# The gap from the Poisson line is sum(p_i^2), which shrinks as the p_i
# themselves shrink, so low-diversity, high-elevation sites (mostly small p_i)
# sit closest to the line, not furthest from it. The underdispersion is
# largest where individual probabilities are moderate (nearer 0.5), which
# tends to be at higher-richness sites, not low-richness ones.

# 5. predictSR residuals.
sr0 <- predictSR(model0, se.fit = FALSE)
plot(sr0, model0)
# Look for a remaining trend against expected richness: a flat scatter around
# zero is consistent with the model capturing what it can; a visible trend
# (as we build explicitly in Part III) means real structure is left unexplained.

# Tasks II

model1 <- gllvm(y = Y, X = X_sc, formula = ~ELEV, num.lv = 2, family = "binomial",
                 seed = 1, sd.errors = FALSE)
ses <- se.gllvm(model0); model0$sd <- ses$sd; model0$Hess <- ses$Hess
ses <- se.gllvm(model1); model1$sd <- ses$sd; model1$Hess <- ses$Hess
srNew0 <- predictSR(model0, newX = newX, level = 0)
srNew  <- predictSR(model1, newX = newX, level = 0)

# 1. Compare the two richness curves directly.
plot(elev_seq, srNew0$expected$fit, type = "l", col = "red",
     xlab = "Elevation (scaled)", ylab = "Predicted richness")
lines(elev_seq, srNew$expected$fit, col = "blue")
legend("topright", legend = c("num.lv = 0", "num.lv = 2"), col = c("red", "blue"), lty = 1)
# The two marginal (level = 0) curves are often fairly similar in shape, since
# both are driven mostly by ELEV; the latent variables mostly change the
# *conditional* (level = 1, site-specific) predictions and the residual
# co-occurrence structure, not the marginal elevation trend.

# 2. Add more covariates.
model1b <- gllvm(y = Y, X = X_sc, formula = ~ELEV + SLOPE + MIND + SOLRAD,
                  num.lv = 2, family = "binomial", seed = 1, sd.errors = FALSE)

# 3. Vary num.lv.
model_lv0 <- model0
model_lv1 <- gllvm(y = Y, X = X_sc, formula = ~ELEV, num.lv = 1, family = "binomial",
                    seed = 1, sd.errors = FALSE)
model_lv2 <- model1
model_lv3 <- gllvm(y = Y, X = X_sc, formula = ~ELEV, num.lv = 3, family = "binomial",
                    seed = 1, sd.errors = FALSE)

# 4. Compare with AIC/BIC.
AIC(model_lv0, model_lv1, model_lv2, model_lv3)
BIC(model_lv0, model_lv1, model_lv2, model_lv3)
# More LVs almost always improve AIC/BIC; the marginal richness curve may
# barely move though (see Task II.1), since LVs mostly help the conditional
# fit. Rank-selection question as in Practical 4, not a boundary test.

# 5. predictSR residuals for model1 vs. model0.
sr <- predictSR(model1, se.fit = FALSE)
plot(sr0, model0)
plot(sr, model1)
# If Part I's residuals showed a trend that model1's do not, that trend was a
# missed relationship the latent variables have absorbed, exactly the
# phenomenon investigated explicitly in Part III.

# Tasks III

Yb <- t(read.csv("../../data/beetlesY.csv"))
colnames(Yb) <- Yb[2, ]
Yb <- Yb[-c(1:2), -c(1, 70:71)]
Yb <- as.data.frame(apply(Yb, 2, as.integer))
Xb <- read.csv("../../data/beetlesX.csv")[, -c(1:5)]
Xb <- as.data.frame(apply(Xb, 2, as.numeric))
Xb_sc <- data.frame(scale(Xb[, c("Moist", "Elevation")]))

modelB_lin <- gllvm(y = Yb, X = Xb_sc, formula = ~Moist, num.lv = 2,
                     family = "negative.binomial", seed = 1, sd.errors = FALSE)
sr_full <- predictSR(modelB_lin, se.fit = FALSE)
sr_marg <- predictSR(modelB_lin, se.fit = FALSE, newLV = matrix(0, ncol = 2, nrow = nrow(Yb)))
res_full <- residuals(sr_full, modelB_lin)
res_marg <- residuals(sr_marg, modelB_lin)

# 1. The marginal (level = 0, LVs forced to zero) residuals show a clear
# curved pattern against Moist; the conditional (level = 1, model's own site
# scores) residuals look flat. That is exactly the point: the latent
# variables have absorbed the missing nonlinear Moist effect for the sites
# they were estimated on, hiding the misspecification conditionally.

# 2. Refit with a quadratic term and repeat.
modelB_quad <- gllvm(y = Yb, X = Xb_sc, formula = ~Moist + I(Moist^2), num.lv = 2,
                      family = "negative.binomial", seed = 1, sd.errors = FALSE)
sr_marg_quad <- predictSR(modelB_quad, se.fit = FALSE,
                          newLV = matrix(0, ncol = 2, nrow = nrow(Yb)))
res_marg_quad <- residuals(sr_marg_quad, modelB_quad)
plot(Xb_sc$Moist, res_marg_quad$residuals, xlab = "Moisture (scaled)",
     ylab = "Dunn-Smyth residuals", main = "Marginal, quadratic")
abline(h = 0, lty = 2)
# The curved pattern should now be gone (or much reduced): the fixed effects
# alone now capture the nonlinearity, so the latent variables no longer need
# to (silently) compensate for it.

# 3. plot(modelB_lin) uses the model's own (conditional, level = 1) residuals,
# the same ones shown to look flat in Task 1. By construction it can only ever
# show what is left over after the latent variables have already done their
# absorbing, so a fixed-effect misspecification that the LVs can soak up is
# invisible to it.

# 4. Predicted richness curve for a new site (no estimated LV score).
moist_seq <- seq(min(Xb_sc$Moist), max(Xb_sc$Moist), length.out = 100)
newXb <- data.frame(Moist = moist_seq)
sr_new_lin  <- predictSR(modelB_lin,  newX = newXb, newLV = matrix(0, ncol = 2, nrow = 100), se.fit = FALSE)
sr_new_quad <- predictSR(modelB_quad, newX = newXb, newLV = matrix(0, ncol = 2, nrow = 100), se.fit = FALSE)
plot(moist_seq, sr_new_lin$expected$fit, type = "l", col = "red",
     xlab = "Moisture (scaled)", ylab = "Predicted richness (new site)")
lines(moist_seq, sr_new_quad$expected$fit, col = "blue")
legend("topright", legend = c("linear", "quadratic"), col = c("red", "blue"), lty = 1)
# For new sites the two curves can diverge substantially, especially
# towards the extremes of the moisture gradient: this is exactly the scenario
# (new-site prediction, no LV score to lean on) where the missing nonlinearity
# actually matters for the final answer.

# 5. Elevation is an obvious second candidate in both datasets (species
# richness vs. elevation is a classic unimodal, not monotonic, relationship
# in mountain systems); check it the same way as Moist above: fit linear vs.
# linear+quadratic, and compare *marginal* (newLV = 0) residuals/predictions.
