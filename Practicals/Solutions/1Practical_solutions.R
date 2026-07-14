# Practical 1 solutions: fitting GLMs to data of multiple species
# One worked example per task, using the wadden data and models already
# built up in the practical (model1-model7).

library(gllvm)
library(mvabund)

Y <- read.table("../../data/waddenY.csv", sep = ",", header = TRUE, row.names = 2)[, -1]
X <- read.table("../../data/waddenX.csv", sep = ",", header = TRUE, row.names = 2)[, -1]
X <- X[, -which(apply(X, 2, anyNA))]

data <- data.frame(Y, X)
datalong <- reshape(data, varying = colnames(Y), v.names = "count",
                    idvar = "Site", timevar = "Species", direction = "long")
datalong$Species <- factor(datalong$Species, labels = colnames(Y))

# Tasks I (GLM/VGLM, species-common vs species-specific effects)

# 1. Explore the models with a different covariate, e.g. "TOC" instead of elevation.
model2b <- glm(count ~ scale(silt_clay) + scale(TOC), data = datalong, family = "poisson")
summary(model2b)
# TOC (organic carbon) turns out to have a much smaller effect than elevation did;
# same idea as model2, just a different pair of covariates.

# 2. Model selection: is the species-specific model (model4-type) actually needed,
# i.e. do species really respond differently to the environment?
model3 <- glm(count ~ 0 + Species + scale(silt_clay):Species + scale(elevation):Species,
              data = datalong, family = "poisson")
model2 <- glm(count ~ scale(silt_clay) + scale(elevation), data = datalong, family = "poisson")
anova(model2, model3, test = "Chisq")
# p < 0.05: rejects the common-slope null, so species do not all respond the
# same way to the environment, and pooling them into one model is misspecified.

# 3. Sum-to-zero contrast for Species: isolates an "average species" effect
# as the intercept, instead of using one species as an arbitrary reference level.
datalong$Species <- C(datalong$Species, contr.sum)
model4_sum <- glm(count ~ Species + scale(silt_clay) + scale(elevation) +
                     scale(silt_clay):Species + scale(elevation):Species,
                   data = datalong, family = "poisson")
coef(model4_sum)["(Intercept)"]
# With sum-to-zero contrasts the intercept represents the average log-abundance
# across species (not "species 1's" log-abundance as with the default treatment
# contrasts), and the silt_clay/elevation main-effect coefficients become the
# average (species-common) response. In this fully-interacted, one-parameter-per-
# species-per-term model the fit is numerically unstable (many species have very
# few observations), so treat the exact intercept value with caution; it is the
# parameterization trick that matters here, not this number.

# 4. (Discussion task, no code.)

# Tasks II (gllvm, different data types)

# The task asks you to draw conclusions from parameter estimates *and* their
# uncertainty. summary() prints no coefficient table at all for a model fitted
# with sd.errors = FALSE, so standard errors have to be added first. This is
# the se.gllvm() pattern from Part I, applied to each fit below.

# 1. Biomass data: wadden biomass (waddenY2), Tweedie handles continuous
# non-negative data with exact zeros.
Y2 <- read.csv("../../data/waddenY2.csv")[, -c(1:2)]
model_biomass <- gllvm(Y2, X, formula = ~ scale(silt_clay) + scale(elevation),
                        family = "tweedie", num.lv = 2, sd.errors = FALSE)
ses <- se.gllvm(model_biomass)
model_biomass$sd <- ses$sd; model_biomass$Hess <- ses$Hess
summary(model_biomass)

# 2. Cover data: road percent-cover data, orderedBeta handles 0/1 boundary values.
# orderedBeta needs a little care here: fitted bare, this model runs away to an
# infinite log-likelihood. Sharing one dispersion parameter across species
# (disp.formula) and using several restarts (n.init) keeps it identifiable,
# which is the same recipe used for this dataset in Practical 6.
Yroad <- read.csv("../../data/roadY.csv")[, -1] / 100
model_cover <- gllvm(Yroad, num.lv = 2, family = "orderedBeta",
                      disp.formula = rep(1, ncol(Yroad)), n.init = 5,
                      sd.errors = FALSE)
ses <- se.gllvm(model_cover)
model_cover$sd <- ses$sd; model_cover$Hess <- ses$Hess
summary(model_cover)

# 3. Cover classes: Skabbholmen ordinal cover-class data (built into gllvm).
data(Skabbholmen)
model_ordinal <- gllvm(Skabbholmen$Y, num.lv = 2, family = "ordinal", sd.errors = FALSE)
ses <- se.gllvm(model_ordinal)
model_ordinal$sd <- ses$sd; model_ordinal$Hess <- ses$Hess
summary(model_ordinal)

# 4. Binary data: SwissBirds presence-absence, with a couple of climate covariates.
birds <- read.csv("../../data/SwissBirds.csv")
Ybirds <- birds[, 1:56]
Xbirds <- birds[, c("bio_1", "rad")]  # temperature, radiation
model_binary <- gllvm(Ybirds, Xbirds, formula = ~ scale(bio_1) + scale(rad),
                       family = "binomial", num.lv = 2, sd.errors = FALSE)
ses <- se.gllvm(model_binary)
model_binary$sd <- ses$sd; model_binary$Hess <- ses$Hess
summary(model_binary)

# 5. Count data: beetles.
Ybeet <- t(read.csv("../../data/beetlesY.csv"))
colnames(Ybeet) <- Ybeet[2, ]
Ybeet <- Ybeet[-c(1:2), -c(1, 70:71)]
Ybeet <- as.data.frame(apply(Ybeet, 2, as.integer))
model_count <- gllvm(Ybeet, num.lv = 2, family = "negative.binomial", sd.errors = FALSE)
ses <- se.gllvm(model_count)
model_count$sd <- ses$sd; model_count$Hess <- ses$Hess
summary(model_count)

# Across all five: check residuals (plot(model)) and compare a Poisson vs.
# negative-binomial/Tweedie fit to see whether overdispersion needed accounting for,
# exactly as covered later in the Checking lecture.
