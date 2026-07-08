# Auto-generated from Practicals/Rmd/3Practical.Rmd via knitr::purl(). Do not edit directly -- re-run after editing the Rmd. See Practicals/R/README.md.

# Response data
Y <- t(read.csv("../../data/beetlesY.csv"))
colnames(Y) <- Y[2,]
Y<-Y[-c(1:2),-c(1,70:71)]
Y <- as.data.frame(apply(Y,2,as.integer))

# Environmental predictors
X <- read.csv("../../data/beetlesX.csv")[,-c(1:5)]
X <- as.data.frame(apply(X,2,as.numeric))
X$Sampling.year <- X$Sampling.year - min(X$Sampling.year)
X$Texture <- as.factor(X$Texture)

# Traits
TR  <- read.csv("../../data/beetlesTR.csv")
row.names(TR) <- TR$SPECIES
TR <- TR[,-c(1:3)]
# Traits to categorical
# Removing question marks, not ideal
TR[,c("CLG","CLB","WIN","PRS","OVE","FOA","DAY","BRE","EME","ACT")] <- apply(TR[,c("CLG","CLB","WIN","PRS","OVE","FOA","DAY","BRE","EME","ACT")],2,function(x)as.factor(gsub("\\?.*","",x)))

# Data standardization
X <- scale(model.matrix(~.,X))[,-1] # environmental variables
TR <- scale(model.matrix(~.,TR))[,-1] # species traits

library(gllvm)
model1 <- gllvm(y = Y, X = X, TR = TR, 
                formula = ~ Management + Elevation + pH + Moist + (Management + Elevation + pH + Moist):(LPH+ LTL + OVE2 + BRE2 + BRE3), 
                family = "negative.binomial", num.lv = 0)

library(gllvm)
(fourth <- gllvm:::getFourthCorner(model1))
coefplot(model1)

summary(model1)

# extract standard errors
model1temp <- model1
model1temp$params$B <- model1$sd$B
sds <- gllvm:::getFourthCorner(model1temp) # little trick to arrange the standard errors
LI = t(fourth+sds*qnorm(1-0.95))
UI = t(fourth+sds*qnorm(0.95))
a = max(abs(fourth))
fields::image.plot(1:nrow(fourth),1:ncol(fourth), fourth, axes=F, ylab=NA, xlab=NA, col = colorRampPalette(c("#E69F00","white","#009E73"))(29), breaks =seq(-a,a,length.out=30), legend.width=1, zlim=range(fourth))
mtext("Traits", 3)
mtext("Environment", 4)
text(1:nrow(fourth), -.6, srt = 45, labels = rownames(fourth), xpd = TRUE, cex = 0.6)
axis(1, label=F)
axis(2, 1:ncol(fourth), colnames(fourth), las=1, cex.axis = 0.6)
box(col="white", lwd=3)
cells_to_outline <- which(((LI>0 & UI>0) | (LI<0 & UI<0)), arr.ind = TRUE)

for (cell in 1:nrow(cells_to_outline)){
  x <- cells_to_outline[cell, 1]
  y <- cells_to_outline[cell, 2]
  x_vals <- c(y - 0.5, y + 0.5, y + 0.5, y - 0.5)  # X coordinates of the rectangle corners
  y_vals <- c(x - 0.5, x - 0.5, x + 0.5, x + 0.5)  # Y coordinates of the rectangle corners

polygon(x_vals, y_vals, col = NA, border = "black", lwd = 2)
}

model2 <- gllvm(y = Y, X = X, TR = TR, 
                formula = ~ Management + Elevation + pH + Moist + (Management + Elevation + pH + Moist):(LPH+ LTL + OVE2 + BRE2 + BRE3) + (0+Management + Elevation + pH + Moist|1),
                family = "negative.binomial", num.lv = 0, n.init = 3)

# there is a little bug in the software, this first line circumvents that. Will be fixed in the upcoming CRAN submission
model2$randomX <- model2$Xrandom <- NULL
randomCoefplot(model2)

fourth <- gllvm:::getFourthCorner(model2)
# extract standard errors
model2temp <- model2
model2temp$params$B <- model2$sd$B
sds <- gllvm:::getFourthCorner(model2temp) # little trick to arrange the standard errors
LI = t(fourth+sds*qnorm(1-0.95))
UI = t(fourth+sds*qnorm(0.95))
a = max(abs(fourth))
fields::image.plot(1:nrow(fourth),1:ncol(fourth), fourth, axes=F, ylab=NA, xlab=NA, col = colorRampPalette(c("#E69F00","white","#009E73"))(29), breaks =seq(-a,a,length.out=30), legend.width=1, zlim=range(fourth))
mtext("Traits", 3)
mtext("Environment", 4)
text(1:nrow(fourth), -.6, srt = 45, labels = rownames(fourth), xpd = TRUE, cex = 0.6)
axis(1, label=F)
axis(2, 1:ncol(fourth), colnames(fourth), las=1, cex.axis = 0.6)
box(col="white", lwd=3)
cells_to_outline <- which(((LI>0 & UI>0) | (LI<0 & UI<0)), arr.ind = TRUE)

for (cell in 1:nrow(cells_to_outline)){
  x <- cells_to_outline[cell, 1]
  y <- cells_to_outline[cell, 2]
  x_vals <- c(y - 0.5, y + 0.5, y + 0.5, y - 0.5)  # X coordinates of the rectangle corners
  y_vals <- c(x - 0.5, x - 0.5, x + 0.5, x + 0.5)  # Y coordinates of the rectangle corners

polygon(x_vals, y_vals, col = NA, border = "black", lwd = 2)
}

model3 <- gllvm(y = Y, X = X,
                formula = ~ (0+Management + Elevation + pH + Moist|1),
                family = "negative.binomial", num.lv = 0, n.init = 3)
anova(model2, model3)

data(fungi, package = "gllvm")
Y2 <- fungi$Y
X2 <- fungi$X
X2 <- data.frame(lapply(X2, function(x)if(is.numeric(x)){scale(x)}else{as.factor(x)}))
tree <- fungi$tree
covMat<- ape::vcv(tree)
distMat <- ape::vcv(tree)
TR <- fungi$TR
colnames(TR)[8] <- "Sp.log.vol" # funky column name needs to be changed

any(rowSums(Y2)==0)
dim(Y2)
colnames(X2)
colnames(TR)

TMB::openmp(parallel::detectCores()-1, autopar = TRUE, DLL = "gllvm")
model4 <- gllvm(Y2, X = X2, TR = TR, formula = ~DBH.CM+AVERDP+CONNECT10+TEMPR+PRECIP+
                  (DBH.CM+AVERDP+CONNECT10+TEMPR+PRECIP):(PC1.1+PC1.2+PC1.3), 
                row.eff = ~(1|REGION/RESERVE), studyDesign =  X2[,c("REGION","RESERVE")],
                num.lv = 0, family = "binomial", sd.errors = FALSE,
                optim.method = "L-BFGS-B")

library(lattice)
fourth <- model4$fourth.corner # the coefficients
a <- max(abs(fourth))
colort <- colorRampPalette(c("blue", "white", "red"))
plot.4th <- levelplot((as.matrix(fourth)), xlab = "Environmental Variables", 
                      ylab = "Species traits", col.regions = colort(100), cex.lab = 1.3, 
                      at = seq(-a, a, length = 100), scales = list(x = list(rot = 45)))
plot.4th

model5 <- gllvm(Y2, X = X2, TR = TR, formula = ~DBH.CM+AVERDP+CONNECT10+TEMPR+PRECIP+
                  (DBH.CM+AVERDP+CONNECT10+TEMPR+PRECIP):(PC1.1+PC1.2+PC1.3), 
                randomX = ~DBH.CM+AVERDP+CONNECT10+TEMPR+PRECIP,
                row.eff = ~(1|REGION/RESERVE), studyDesign =  X2[,c("REGION","RESERVE")],
                num.lv = 0, family = "binomial", sd.errors = FALSE,
                optim.method = "L-BFGS-B", Ab.struct = "diagonal", maxit=1e5)

e <- eigen(covMat)$vectors[,1]
ord <- gllvm:::findOrder(covMat = covMat, distMat = distMat, nn = 15, order = order(e))$order
spec.ord <- colnames(covMat)[ord]
model6 <- gllvm(Y2[,spec.ord], X = X2, TR = TR, formula = ~DBH.CM+AVERDP+CONNECT10+TEMPR+PRECIP+
                  (DBH.CM+AVERDP+CONNECT10+TEMPR+PRECIP):(PC1.1+PC1.2+PC1.3), 
                randomX = ~DBH.CM+AVERDP+CONNECT10+TEMPR+PRECIP,
                row.eff = ~(1|REGION/RESERVE), studyDesign =  X2[,c("REGION","RESERVE")],
                num.lv = 0, family = "binomial", sd.errors = FALSE,
                optim.method = "L-BFGS-B", Ab.struct = "MNdiagonal", maxit = 1e5,
                colMat = list(covMat[spec.ord, spec.ord], dist = distMat[spec.ord, spec.ord]), colMat.rho.struct = "term", nn.colMat = 15)

ses <- se(model6)
model6$sd <- ses$sd
model6$Hess <- ses$Hess

summary(model6)
phyloplot(model6, tree = tree)

library(Matrix)
corrplot::corrplot(cov2cor(getEnvironCov(model6)$cov), type = "lower", order = "AOE", diag = FALSE, tl.pos = "l", tl.cex = 0.2, addgrid.col = NA)
