# Practical 2 solutions: fitting multispecies GLMMs and model diagnostics
# Builds directly on model1-model10 as defined in the practical.

library(gllvm)

Y <- read.table("../../data/waddenY.csv", sep = ",", header = TRUE, row.names = 2)[, -1]
X <- read.table("../../data/waddenX.csv", sep = ",", header = TRUE, row.names = 2)[, -1]
X <- X[, -which(apply(X, 2, anyNA))]

# Tasks I (random intercepts/slopes)

# 1. Random intercept and random slope, syntax practice.
model_ri <- gllvm(Y, X, row.eff = ~(1|island), studyDesign = X,
                   family = "negative.binomial", num.lv = 0, sd.errors = FALSE)
model_rs <- gllvm(Y, X, formula = ~(0+scale(elevation)|1),
                   family = "negative.binomial", num.lv = 0, sd.errors = FALSE)

# 2. Standardized vs. raw covariate: compare the fitted random-slope variance.
model_scaled   <- gllvm(Y, X, formula = ~(0+scale(elevation)|1),
                         family = "negative.binomial", num.lv = 0, sd.errors = FALSE)
model_unscaled <- gllvm(Y, X, formula = ~(0+elevation|1),
                         family = "negative.binomial", num.lv = 0, sd.errors = FALSE)
diag(model_scaled$params$sigmaB)
diag(model_unscaled$params$sigmaB)
# Same log-likelihood (it's a reparameterization, as in Practical 1), but the
# variance is on a totally different, less interpretable scale when elevation
# is not standardized. For models with several covariates on different scales,
# unscaled covariates can also cause real convergence problems, not just an
# interpretation headache.

# 3. Fixed vs. random for the same covariate: compare AIC.
model_fixed  <- gllvm(Y, X, formula = ~scale(elevation), family = "negative.binomial",
                       num.lv = 0, sd.errors = FALSE)
model_random <- gllvm(Y, X, formula = ~(0+scale(elevation)|1), family = "negative.binomial",
                       num.lv = 0, sd.errors = FALSE)
AIC(model_fixed, model_random)
# The random-slope model uses one variance parameter instead of 58 species-specific
# slopes, so if species really do differ a lot, the fixed model usually wins on AIC;
# if species are fairly similar, the random model wins by using far fewer parameters.

# 4. Ecological understanding of variance parameters: see the alpha-diversity
# calculation for model4 in the practical, and the ICC/repeatability section
# below (Tasks II items 4-5), for turning a variance component into an
# interpretable fraction of variation explained.

# Part I models (needed below)

model1 <- gllvm(Y, X, formula = ~scale(silt_clay) + scale(elevation),
                family = "negative.binomial", num.lv = 0, sd.errors = FALSE)
model2 <- gllvm(Y, X, formula = ~(0+scale(silt_clay)|1) + (0+scale(elevation)|1),
                 family = "negative.binomial", num.lv = 0, sd.errors = FALSE)
model4 <- gllvm(Y, X, formula = ~diag(0+island|1) + (0+scale(silt_clay)|1) + (0+scale(elevation)|1),
                 row.eff = ~1, family = "negative.binomial", num.lv = 0, sd.errors = FALSE)

# Tasks II (correlation and repeatability)

# 1-2. Correlation parameters: put silt_clay and elevation in the same bracket
# (already model8 in the practical); interpret the sign/magnitude.
model8 <- gllvm(Y, X, formula = ~diag(0+island|1) + (0+scale(silt_clay)+scale(elevation)|1),
                 row.eff = ~1, family = "negative.binomial", num.lv = 0, sd.errors = FALSE)
cov2cor(model8$params$sigmaB)
# Positive correlation: species that respond more strongly and positively to
# silt_clay also tend to respond more strongly and positively to elevation.

# 3. Sensitivity: does the sign/magnitude change with a different fixed/random split?
model8b <- gllvm(Y, X, formula = ~(0+scale(silt_clay)+scale(elevation)|1),
                  row.eff = ~(1|island), studyDesign = X,
                  family = "negative.binomial", num.lv = 0, sd.errors = FALSE)
cov2cor(model8b$params$sigmaB)
# Compare this correlation to the one from model8: if it stays positive and of
# similar magnitude, the correlation is a fairly robust feature of the data, not
# an artefact of exactly how "island" was included.

# 4. ICC for island in model4.
sigmaB <- diag(model4$params$sigmaB)
names(sigmaB) <- colnames(model4$params$sigmaB)
icc <- sigmaB / sum(sigmaB)
icc
# Whichever of "island", "silt_clay", "elevation" has the largest share here
# dominates the explained variance in the linear predictor.

# 5. Repeatability for one species: add the residual variance implied by its
# negative-binomial dispersion parameter, using gllvm's own residual-variance
# definition (see ?getResidualCov, adjust = 1): log(phi + 1).
j <- 1
island_var <- sum(sigmaB[grep("island", names(sigmaB))])  # 3 species-specific island levels
repeatability_island <- island_var / (sum(sigmaB) + log(model4$params$phi[j] + 1))
repeatability_island
# Repeatability is always <= the community-average ICC for the same grouping,
# because the denominator now also includes the residual variance.

# Part III: nested random effects

model3 <- gllvm(Y, X, formula = ~(0+scale(silt_clay)|1) + (0+scale(elevation)|1),
                 row.eff = ~1, family = "negative.binomial", num.lv = 0, sd.errors = FALSE)
StudyDesign <- data.frame(X[, 1:4], sample = rownames(X))

# Tasks III

# 1. Add random effects for the sampling design (already model10 in the practical).
model10 <- gllvm(Y, X, formula = ~(0+scale(silt_clay)|1) + (0+scale(elevation)|1),
                  studyDesign = StudyDesign,
                  row.eff = ~(1|island:transect) + (1|island:transect:station) + (1|sample) + island + season,
                  family = "negative.binomial", num.lv = 0, sd.errors = FALSE)

# 2. Compare to model3 (no sampling-design random effects) for the same fixed
# effects. The task asks about both the estimates and their uncertainty, so
# compare the standard errors too, not just the point estimates.
ses3  <- se.gllvm(model3);  model3$sd  <- ses3$sd;  model3$Hess  <- ses3$Hess
ses10 <- se.gllvm(model10); model10$sd <- ses10$sd; model10$Hess <- ses10$Hess

# point estimates
cbind(model3 = model3$params$Xcoef, model10 = model10$params$Xcoef)[1:5, ]
# standard errors for the same coefficients
cbind(model3 = model3$sd$Xcoef, model10 = model10$sd$Xcoef)[1:5, ]
# Point estimates for the silt_clay/elevation slopes are usually similar; the
# standard errors are where the two models diverge. model3 ignores the fact
# that samples from the same transect/station are not independent, pretending
# we have more independent information than we really do, so its standard
# errors are the less trustworthy of the two.

# Technical caveats: hypothesis testing

# Q1: fixed vs random Wald p-value for the same covariate.
summary(model_fixed)   # scale(elevation) as a fixed effect: one p-value per species
# There is no single Wald p-value for a random slope's variance in the usual
# summary output; the fixed-effect version gives species-specific tests, the
# random-effect version instead reports a variance estimate (see Q2).

# Q2: LRT / AIC for H0: sigma^2 = 0 (boundary problem).
model_norandom <- gllvm(Y, X, family = "negative.binomial", num.lv = 0, sd.errors = FALSE)
model_withrandom <- gllvm(Y, X, formula = ~(0+scale(elevation)|1),
                           family = "negative.binomial", num.lv = 0, sd.errors = FALSE)
AIC(model_norandom, model_withrandom)
# anova() likelihood-ratio tests this too; either way, the naive chi-square(1)
# reference distribution is wrong for testing a variance against its zero
# boundary. The correct null distribution is a 50:50 mixture of chi-square(0)
# and chi-square(1), which is stochastically smaller, i.e. naive p-values here
# are conservative (too large), not anti-conservative.

# Technical caveats: model selection

# Q3: AIC for a fixed-effect difference vs. a random-effect-variance difference.
model_nosilt <- gllvm(Y, X, formula = ~scale(elevation), family = "negative.binomial",
                       num.lv = 0, sd.errors = FALSE)
model_silt   <- gllvm(Y, X, formula = ~scale(elevation) + scale(silt_clay),
                       family = "negative.binomial", num.lv = 0, sd.errors = FALSE)
AIC(model_nosilt, model_silt)              # ordinary fixed-effect comparison: trust this AIC
AIC(model_norandom, model_withrandom)      # random-effect-variance comparison: read cautiously

# Q4: AIC penalty, random slope vs. fixed slope.
AIC(model_fixed)   # 58 species-specific slopes
AIC(model_random)  # 1 variance parameter
# A random slope is far cheaper in AIC terms (1 parameter vs. p parameters), so
# AIC will favour it whenever the fixed-effect model's extra flexibility isn't
# earning its keep in log-likelihood, including some cases where the true
# variance is close to zero (the boundary problem from Q2 again).

# Residual diagnostics

model_pois <- gllvm(Y, X, formula = ~scale(silt_clay) + scale(elevation),
                     family = "poisson", num.lv = 0, sd.errors = FALSE)

# Q5: reproduce the Poisson-vs-NB comparison for model_fixed's family choice.
par(mfrow = c(1, 2))
plot(model_pois, which = c(1, 2))
plot(model1, which = c(1, 2))
# The residuals-vs-fitted (fan-shaped spread) and QQ-plot (heavy tails) are
# usually the first two to visibly flag overdispersion; residuals-vs-row/column
# and the scale-location plot tend to look fine even when the variance function
# is wrong, so check all of them before concluding a model is adequate.

# Q6: normality of the estimated random effects.
qqnorm(as.vector(model2$params$Br)); qqline(as.vector(model2$params$Br))
# A long-tailed (fat-tailed) deviation from the qqline means a handful of
# species have much more extreme responses than a normal random-effects
# distribution predicts. That can mean a few unusual species, or it
# can mean the normal random-effects assumption itself is a poor fit; the plot
# alone cannot distinguish the two.
