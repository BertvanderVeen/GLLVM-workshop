# Auto-generated from Practicals/Rmd/5Practical.Rmd via knitr::purl(). Do not edit directly -- re-run after editing the Rmd. See Practicals/R/README.md.

library(gllvm)
TMB::openmp(parallel::detectCores()-1, autopar = TRUE, DLL = "gllvm")

Y <- read.csv("../../data/alpineY.csv")[,-1]
X <- read.csv("../../data/alpineX.csv")[,-1]
X <- X[rowSums(Y) > 0, ]
Y <- Y[rowSums(Y) > 0, ]
X_sc <- data.frame(scale(X[, sapply(X, is.numeric)]))

model0 <- gllvm(y = Y, X = X_sc,
                formula = ~ELEV,
                num.lv = 0,
                family = "binomial",
                seed = 1,
                sd.errors = FALSE)

sr0 <- predictSR(model0, se.fit = FALSE)
plot(sr0, model0)

elev_seq <- seq(min(X_sc$ELEV), max(X_sc$ELEV), length.out = 100)
newX <- data.frame(ELEV = elev_seq)

ses <- se.gllvm(model0)
model0$sd <- ses$sd
model0$Hess <- ses$Hess
srNew0 <- predictSR(model0, newX = newX, level = 0)

obs_sr <- rowSums(Y)
plot(X_sc$ELEV, obs_sr, pch = 16, col = rgb(0,0,0,0.3),
     xlab = "Elevation (scaled)", ylab = "Species richness")
lines(elev_seq, srNew0$expected$fit, col = "red", lwd = 2)
lines(elev_seq, srNew0$expected$lower, col = "red", lwd = 1, lty = 2)
lines(elev_seq, srNew0$expected$upper, col = "red", lwd = 1, lty = 2)

# Expected richness and variance from the model
pred_probs <- predict(model0, type = "response") # n x m matrix
exp_sr <- rowSums(pred_probs)        # Poisson-Binomial mean
var_sr <- rowSums(pred_probs * (1 - pred_probs))  # PB variance

# Compare to Poisson assumption
plot(exp_sr, var_sr, xlab = "Expected species richness",
     ylab = "Predicted variance", pch = 16, col = "steelblue")
abline(0, 1, col = "red", lty = 2, lwd = 2)  # Poisson: var = mean
legend("topleft", legend = c("Poisson-Binomial", "Poisson (var=mean)"),
       pch = c(16, NA), lty = c(NA, 2), col = c("steelblue", "red"))

model1 <- gllvm(y = Y, X = X_sc,
                formula = ~ELEV,
                num.lv = 2,
                family = "binomial",
                seed = 1,
                sd.errors = FALSE)

sr <- predictSR(model1, se.fit = FALSE)
plot(sr, model1)

ses <- se.gllvm(model1)
model1$sd <- ses$sd
model1$Hess <- ses$Hess
srNew <- predictSR(model1, newX = newX, level = 0)

plot(X_sc$ELEV, obs_sr, pch = 16, col = rgb(0,0,0,0.3),
     xlab = "Elevation (scaled)", ylab = "Species richness")
lines(elev_seq, srNew$expected$fit, col = "red", lwd = 2)
lines(elev_seq, srNew$expected$lower, col = "red", lwd = 1, lty = 2)
lines(elev_seq, srNew$expected$upper, col = "red", lwd = 1, lty = 2)

Yb <- t(read.csv("../../data/beetlesY.csv"))
colnames(Yb) <- Yb[2, ]
Yb <- Yb[-c(1:2), -c(1, 70:71)]
Yb <- as.data.frame(apply(Yb, 2, as.integer))

Xb <- read.csv("../../data/beetlesX.csv")[, -c(1:5)]
Xb <- as.data.frame(apply(Xb, 2, as.numeric))
Xb_sc <- data.frame(scale(Xb[, c("Moist", "Elevation")]))

modelB_lin <- gllvm(y = Yb, X = Xb_sc,
                    formula = ~Moist,
                    num.lv = 2,
                    family = "negative.binomial",
                    seed = 1,
                    sd.errors = FALSE)

sr_full <- predictSR(modelB_lin, se.fit = FALSE)
sr_marg <- predictSR(modelB_lin, se.fit = FALSE,
                     newLV = matrix(0, ncol = 2, nrow = nrow(Yb)))

res_full <- residuals(sr_full, modelB_lin)
res_marg <- residuals(sr_marg, modelB_lin)

par(mfrow = c(1, 2))
plot(Xb_sc$Moist, res_full$residuals, xlab = "Moisture (scaled)",
     ylab = "Dunn-Smyth residuals", main = "Conditional")
abline(h = 0, lty = 2)
plot(Xb_sc$Moist, res_marg$residuals, xlab = "Moisture (scaled)",
     ylab = "Dunn-Smyth residuals", main = "Marginal")
abline(h = 0, lty = 2)
