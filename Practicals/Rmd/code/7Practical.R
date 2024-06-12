# Response data
Y <- t(read.csv("data/beetlesY.csv"))
colnames(Y) <- Y[2,]
Y<-Y[-c(1:2),-c(1,70:71)]
Y <- as.data.frame(apply(Y,2,as.integer))

# Environmental predictors
X <- read.csv("data/beetlesX.csv")[,-c(1:5)]
X <- as.data.frame(apply(X,2,as.numeric))
X$Sampling.year <- X$Sampling.year - min(X$Sampling.year)
X$Texture <- as.factor(X$Texture)

# Traits
TR  <- read.csv("data/beetlesTR.csv")
row.names(TR) <- TR$SPECIES
TR <- TR[,-c(1:3)]
# Traits to categorical
# Removing question marks, not ideal
TR[,c("CLG","CLB","WIN","PRS","OVE","FOA","DAY","BRE","EME","ACT")] <- apply(TR[,c("CLG","CLB","WIN","PRS","OVE","FOA","DAY","BRE","EME","ACT")],2,function(x)as.factor(gsub("\\?.*","",x)))

# Data standardization
X <- scale(model.matrix(~.,X))[,-1] # environmental variables
TR <- scale(model.matrix(~.,TR))[,-1] # species traits



# Y: community data
# X: environmental data
# TR: functional trait data
library(gllvm)
model1 <- gllvm(y = Y, X = X, TR = TR, 
                formula = ~ Elevation + pH + Management + Moist + (Elevation + pH + Management + Moist):(LPH + LTL + OVE2 + BRE2 + BRE3), 
                family = "negative.binomial", num.lv = 2)

summary(model1)

model2 <- gllvm(y = Y, X = X, TR = TR, 
                formula = ~ Elevation + pH + Management + Moist + (Elevation + pH + Management + Moist):(LPH + LTL + OVE2 + BRE2 + BRE3), 
                randomX = ~ Elevation + pH + Management + Moist,
                family = "negative.binomial", num.lv = 2)
summary(model2)
coefplot(model2)

randomCoefplot(model2, which.Xcoef=c("pH"))

# looking at 4th corner coefficients
library(ggplot2)
fourth <- gllvm:::getFourthCorner(model2)
#tricking gllvm to get the SDs sorted
#we use this to strike out effects that are too uncertain
modelSDtrick <- model2
modelSDtrick$params$B <- modelSDtrick$sd$B
fourthSD <- gllvm:::getFourthCorner(modelSDtrick)
library(dplyr)
library(tidyr)
library(tibble)
fourth.gg <- fourth%>%
  as.data.frame%>%
  rownames_to_column("environment")%>%
  pivot_longer(-environment,names_to="trait",values_to="value")
fourth.gg.sd <- fourthSD%>%
  as.data.frame%>%
  rownames_to_column("environment")%>%
  pivot_longer(-environment,names_to="trait",values_to="value")
# Check if CI includes zero
fourth.gg$sig <- ifelse(fourth.gg$value+fourth.gg.sd$value*qnorm(1-0.95)<0 & fourth.gg$value+fourth.gg.sd$value*qnorm(0.95) > 0,0,1)
# set value to 0 if it does
fourth.gg$value <- ifelse(fourth.gg$sig==0,0,fourth.gg$value)

# create the plot
g1 <- ggplot(fourth.gg, aes(trait, environment))+geom_tile(aes(fill=value), col = "grey")+scale_fill_gradientn(
  colors=c("blue","white","red"), values = scales::rescale(c(min(fourth),0,max(fourth))))+theme_minimal()+ theme(axis.text.x = element_text(angle = 90, vjust = 0.5))+ 
  theme(plot.margin = unit(c(0.5,0.5,0.5,0.5), "inches"), plot.title = element_text(size=10),  axis.text.x = element_text(size = 16), axis.text.y = element_text(size = 16), axis.title.x = element_text(size = 16), axis.title.y = element_text(size = 16))+xlab("Traits")+ylab("Environment")#+theme(legend.position="none")
g1

corrplot::corrplot(getResidualCor(model2), type = "lower", order="AOE")
ordiplot(model2, biplot=TRUE)

# missing: NA, offset
Y[5,10]<-NA
offset <- rpois(nrow(Y), lambda = 10)
model <- gllvm(Y, num.lv = 2, family = "poisson", offset = log(offset))
