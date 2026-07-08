# Auto-generated from Practicals/Rmd/10Practical.Rmd via knitr::purl(). Do not edit directly -- re-run after editing the Rmd. See Practicals/R/README.md.

library(gllvm)
TMB::openmp(parallel::detectCores()-1, autopar = TRUE, DLL = "gllvm")

data(kelpforest)
Yabund <- kelpforest$Y
SPinfo <- kelpforest$SPinfo
Xenv <- kelpforest$X

# sessile invertebrates observed at least 10 times; rarer species summed into one column
Yinvert <- Yabund[SPinfo$GROUP == "INVERT"]
Yinvert10 <- Yinvert[, colSums(Yinvert > 0, na.rm = TRUE) > 9]
Yinvert10$Sum_inv <- rowSums(Yinvert[, colSums(Yinvert > 0, na.rm = TRUE) <= 9], na.rm = TRUE)

studyDesign <- data.frame(year = factor(Xenv$YEAR), site = factor(Xenv$SITE))

# Baseline: site-level random intercepts, no temporal correlation
model_iid <- gllvm(Yinvert10, family = "betaH", num.lv = 0,
                   disp.formula = rep(1, ncol(Yinvert10)),
                   studyDesign = studyDesign, row.eff = ~(1|site), n.init = 3)

# AR(1) structure across years, added on top of the site-level intercepts
model_ar1 <- gllvm(Yinvert10, family = "betaH", num.lv = 0,
                   disp.formula = rep(1, ncol(Yinvert10)),
                   studyDesign = studyDesign, row.eff = ~(1|site) + corAR1(1|year), n.init = 3)

AIC(model_iid, model_ar1)

model_ar1$params$sigma  # the ".rho"-suffixed entry is the year-to-year correlation

Yf <- read.csv("../../data/garchingerFrequencyY.csv", row.names = 1)
Xf <- read.csv("../../data/garchingerFrequencyX.csv")

plot_f <- factor(Xf$PlotID)
# Plots repeat across the 3 survey years (120 rows, 40 distinct plots).
# distLV needs one coordinate row per distinct level of the lvCor grouping
# variable, not one row per observation.
coords_plot <- as.matrix(Xf[match(levels(plot_f), Xf$PlotID), c("E", "N")])

model_iid <- gllvm(Yf, family = "binomial", Ntrials = 100, num.lv = 2, n.init = 3)

model_spatial <- gllvm(Yf, family = "binomial", Ntrials = 100, num.lv = 2,
                       lvCor = ~corExp(1|plot),
                       studyDesign = data.frame(plot = plot_f),
                       distLV = coords_plot, n.init = 3)

AIC(model_iid, model_spatial)

model_spatial$params$rho.lv  # range per LV, in the same units as the coordinates (km)

Y <- read.csv("../../data/waddenY2.csv")[, -c(1:2)]
Y <- Y[, colSums(ifelse(Y == 0, 0, 1)) > 2]

Y_mixed <- Y
Y_mixed[, 1:10] <- ifelse(Y_mixed[, 1:10] > 0, 1, 0)

family_vec <- c(rep("binomial", 10), rep("negative.binomial", ncol(Y_mixed) - 10))

model_mixed <- gllvm(Y_mixed, num.lv = 2, family = family_vec, n.init = 3, sd.errors = FALSE)
