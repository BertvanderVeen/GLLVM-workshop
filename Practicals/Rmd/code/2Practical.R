Y <- read.table("data/waddenY.csv", sep="," ,header=TRUE, row.names = 2)[,-1]
X <- read.table("data/waddenX.csv", sep=",", header=TRUE, row.names = 2)[,-1]

# Remove species with few observations
Y <- Y[,colSums(Y)>4]

# Scale covariates: always good to do when using numerical optimisation
X <- data.frame(lapply(X, function(x)if(is.numeric(x)){scale(x)}else{as.factor(x)}))
X$site <- as.character(1:nrow(Y))

# Y to long format
datalong <- reshape(cbind(Y, X), 
                    varying = colnames(Y), 
                    v.names = "Count", 
                    timevar = "Species", 
                    direction = "long")

datalong$Species <- factor(datalong$Species, 
                           labels = colnames(Y))

library(glmmTMB)

# these two models are the same
# but the second model has effects that are not relative to the first species
model1 <- glm(Count ~ Species*(elevation+temperature+silt_clay), family = "poisson", data = datalong)
model2 <- glm(Count ~ Species + Species:(elevation+temperature+silt_clay), family = "poisson", data = datalong)

# here we fit the JSADM
model3 <- glmmTMB(Count ~ Species + elevation+temperature+silt_clay+ Species:(elevation+temperature+silt_clay) + (0+Species|island/station/transect), 
                 family = "poisson", data = datalong) # takes long, nevermind

# here we fit a GLLVM
model3 <- glmmTMB(Count ~ Species + elevation+temperature+silt_clay+ Species:(elevation+temperature+silt_clay) + rr(0+Species|island, d = 2), 
                  family = "poisson", data = datalong, control = glmmTMBControl(optCtrl = list(iter.max=1e3, eval.max=1e3)))
ranef(model3) # these are out site scores

# random intercept
model4 <- glmmTMB(Count ~ (1|Species), 
                  family = "poisson", data = datalong, control = glmmTMBControl(optCtrl = list(iter.max=1e3, eval.max=1e3)))
ranef(model4)

# also random slope
model5 <- glmmTMB(Count ~ (1|Species)+(0+elevation|Species), 
                  family = "poisson", data = datalong, control = glmmTMBControl(optCtrl = list(iter.max=1e3, eval.max=1e3)))
ranef(model5)

# also community response
model6 <- glmmTMB(Count ~ (1|Species)+elevation+(0+elevation|Species), 
                  family = "poisson", data = datalong, control = glmmTMBControl(optCtrl = list(iter.max=1e3, eval.max=1e3)))
fixef(model6)
ranef(model6)

# include intercept-slope correlation
model7 <- glmmTMB(Count ~ elevation+(elevation|Species), 
                  family = "poisson", data = datalong, control = glmmTMBControl(optCtrl = list(iter.max=1e3, eval.max=1e3)))

library(ggplot2)
# gather the results
# omit global intercept for now
PIs <- as.data.frame(ranef(model7))
PIs$LI <- PIs$condval + qnorm(1-0.95)*PIs$condsd
PIs$UI <- PIs$condval + qnorm(0.95)*PIs$condsd
# Add a column for the species names
colnames(PIs)[4] <- "Species"
colnames(PIs)[3] <- "Covariate"
colnames(PIs)[5] <- "Estimate"
PIs$col <- ifelse(PIs$LI>0 & PIs$UI>0 | PIs$LI<0 & PIs$UI<0, "black", "grey")

ggplot(data = PIs)+geom_point(aes(y=Species, x = Estimate, col = col))+# our estimates
  geom_errorbarh(aes(y=Species,xmin=LI,xmax=UI, col = col))+#95% PI
  facet_grid(~Covariate)+#a window per covariate
  geom_vline(xintercept = 0, linewidth=1, col="gray")+ #add a vertical line
  theme_classic()+scale_color_manual(values = c(black="black",gray="gray")) # I like this theme better

# uconstrained ordination
model8 <- glmmTMB(Count ~ Species + rr(0+Species|site, d =2), 
                  family = "poisson", data = datalong, control = glmmTMBControl(optCtrl = list(iter.max=1e3, eval.max=1e3)))
ranef(model8)$cond$site[,1:2]

plot(ranef(model8)$cond$site[,1:2], type = "n", xlab="LV1", ylab="LV2")
text(ranef(model8)$cond$site[,1:2], col="grey")
abline(v=0, h=0, lty="dashed")

# residual ordination
model9 <- glmmTMB(Count ~ elevation+(elevation|Species) + rr(0+Species|site, d =2), 
                  family = "poisson", data = datalong, control = glmmTMBControl(optCtrl = list(iter.max=1e3, eval.max=1e3)))