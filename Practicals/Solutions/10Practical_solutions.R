# Practical 10 solutions: extensions, spatial/temporal models and mixed responses
# Builds on the model_iid/model_year/model_ar1 (Part I), model_iid/model_spatial
# (Part II) and model_mixed (Part III) already fitted in the practical.

library(gllvm)
TMB::openmp(parallel::detectCores() - 1, autopar = TRUE, DLL = "gllvm")

# Part I setup + models

data(kelpforest)
Yabund <- kelpforest$Y
SPinfo <- kelpforest$SPinfo
Xenv <- kelpforest$X
Yinvert <- Yabund[SPinfo$GROUP == "INVERT"]
Yinvert10 <- Yinvert[, colSums(Yinvert > 0, na.rm = TRUE) > 9]
Yinvert10$Sum_inv <- rowSums(Yinvert[, colSums(Yinvert > 0, na.rm = TRUE) <= 9], na.rm = TRUE)
studyDesign <- data.frame(year = factor(Xenv$YEAR), site = factor(Xenv$SITE))

model_iid <- gllvm(Yinvert10, family = "betaH", num.lv = 0, disp.formula = rep(1, ncol(Yinvert10)),
                    studyDesign = studyDesign, row.eff = ~(1|site), n.init = 3, sd.errors = FALSE)
model_year <- gllvm(Yinvert10, family = "betaH", num.lv = 0, disp.formula = rep(1, ncol(Yinvert10)),
                     studyDesign = studyDesign, row.eff = ~(1|site) + (1|year), n.init = 3, sd.errors = FALSE)
model_ar1 <- gllvm(Yinvert10, family = "betaH", num.lv = 0, disp.formula = rep(1, ncol(Yinvert10)),
                    studyDesign = studyDesign, row.eff = ~(1|site) + corAR1(1|year), n.init = 3, sd.errors = FALSE)

# Tasks I

# 1. The two comparisons, and why they differ in kind.
AIC(model_year, model_ar1)  # boundary-free: does correlation help, given year matters?
AIC(model_iid, model_year)  # boundary comparison: does year matter at all?
# The first compares two models with the same number of "variance-type"
# parameters, differing only in rho (an interior-point null); the second adds
# a whole new variance component whose null value (zero) sits on its boundary,
# so its naive AIC/LRT comparison is the same kind of "read cautiously"
# situation flagged in Practical 2.

# 2. Interpret rho.
rho <- model_ar1$params$sigma["1 | year.rho"]
rho
# Values close to 1 mean community composition changes very slowly from year
# to year (high persistence); values close to 0 mean each year looks
# essentially independent of the last.

# 3. Lag at which correlation drops below 0.1.
ceiling(log(0.1) / log(rho))
# Solves rho^k < 0.1 for the smallest integer k.

# 4. lvCor instead of row.eff.
model_ar1_lv <- gllvm(Yinvert10, family = "betaH", num.lv = 2,
                       disp.formula = rep(1, ncol(Yinvert10)),
                       studyDesign = studyDesign, lvCor = ~corAR1(1|year),
                       n.init = 3, sd.errors = FALSE)
# In row.eff, the AR(1) correlation applies to a species-common mean-abundance
# term (every species shifts up/down together from year to year); in lvCor,
# it applies to the latent variables themselves, so different species can
# respond differently to the same temporal structure (species-specific
# loadings on a temporally autocorrelated gradient), much closer to a proper
# JSDM-with-temporal-structure than a shared row effect is.

# 5. wadden's `season` only has 2 levels: with just 2 time points, there is
# only a single lag (k = 1) to estimate a correlation over. AR(1), compound
# symmetry, and an unstructured 2x2 covariance all have exactly enough
# parameters to saturate that single 2x2 covariance matrix perfectly, so
# there is no *decay over increasing lags* to observe or distinguish between
# structures with, unlike kelpforest's 21 years.

# Part II setup + models

Yf <- read.csv("../../data/garchingerFrequencyY.csv", row.names = 1)
Xf <- read.csv("../../data/garchingerFrequencyX.csv")
plot_f <- factor(Xf$PlotID)
coords_plot <- as.matrix(Xf[match(levels(plot_f), Xf$PlotID), c("E", "N")])

model_iid_sp <- gllvm(Yf, family = "binomial", Ntrials = 100, num.lv = 2,
                       n.init = 5, seed = 1:5, sd.errors = FALSE)
model_spatial <- gllvm(Yf, family = "binomial", Ntrials = 100, num.lv = 2,
                        lvCor = ~corExp(1|plot), studyDesign = data.frame(plot = plot_f),
                        distLV = coords_plot, n.init = 5, seed = 1:5, sd.errors = FALSE)

# Tasks II

# 1. AIC comparison. VA-tightness caveat already in the practical text; also,
# unlike AR(1)'s rho (Task I.1), corExp's "no correlation" is a boundary null
# (Practical 2's Hypothesis Testing section), not an interior point.
AIC(model_iid_sp, model_spatial)

# 2. Effective range vs. study area extent.
rho_m <- model_spatial$params$rho.lv * 1000  # km -> m
eff_m <- -rho_m * log(0.05)                  # ~3*rho
eff_m
# Compare eff_m to the ~300 m x 300 m extent of the plots: if the effective
# range is a small fraction of that extent, spatial autocorrelation is a
# local, short-range effect; if it approaches or exceeds the extent, it is
# closer to a broad, study-area-wide gradient.

# 3. Variance explained by the spatial structure.
VP(model_spatial)

# 4. distLV needs one row per distinct *level* of the lvCor grouping variable
# (40 plots here), not one row per observation (120 = 40 plots x 3 years).
# Repeating each plot's coordinates 3 times (once per year) would silently
# triple-count those plots in the spatial correlation structure and mismatch
# gllvm's internal indexing of `plot` levels to coordinate rows, giving a
# nonsensical (not just imprecise) correlation matrix, not merely a technical
# inconvenience.

# 5. (Bring-your-own-data task, no fixed code; use Lambda.struc = "bdNN"/"UNN"
# with a small NN for large n, exactly as demonstrated for the Garchinger case
# study in Friday's Extensions lecture.)

# Part III setup + models

Y <- read.csv("../../data/waddenY.csv")[, -c(1:2)]
Y <- Y[, colSums(ifelse(Y == 0, 0, 1)) > 2]
Y_mixed <- Y
Y_mixed[, 1:10] <- ifelse(Y_mixed[, 1:10] > 0, 1, 0)
family_vec <- c(rep("binomial", 10), rep("negative.binomial", ncol(Y_mixed) - 10))
model_mixed <- gllvm(Y_mixed, num.lv = 2, family = family_vec, n.init = 3, sd.errors = FALSE)

# Tasks III

# 1. Compare to an all-negative.binomial fit.
model_allcount <- gllvm(Y_mixed, num.lv = 2, family = "negative.binomial",
                         n.init = 3, sd.errors = FALSE)
plot(model_allcount, which = 1)
plot(model_mixed, which = 1)
# Treating the thresholded 0/1 columns as counts asks the negative-binomial
# variance function to explain data that only ever takes two values; the
# residual diagnostics for those columns should look clearly wrong (or the
# dispersion parameter for those species gets pushed to a degenerate
# boundary trying to compensate), whereas model_mixed's binomial family
# fits that same data with no such conflict.

# 2. Build a family vector for your own data: identify which species columns
# are binary/presence-absence, ordinal, proportion, or count data,
# then build family_vec <- ifelse(condition, "binomial", "negative.binomial")
# (or similar), matching column order exactly as done above.

# 3. See ?gllvm, `family` argument, for the full list and which combinations
# are allowed together. They must share the same estimation `method`, i.e. all
# VA/EVA or all LA; you cannot freely mix families that only support different
# methods.
