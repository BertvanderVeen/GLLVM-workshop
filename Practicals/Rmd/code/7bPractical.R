# Response data
Y <- read.csv("data/fungiY.csv")[,-1]
X <- read.csv("data/fungiX.csv")
X <- data.frame(lapply(X, function(x)if(is.numeric(x)){scale(x)}else{as.factor(x)}))
tree <- ape::read.tree("data/fungiTree.txt")
plot(tree,show.tip.label = FALSE)
phyCov <- ape::vcv(tree)[colnames(Y), colnames(Y)]
phyDist <- ape::cophenetic.phylo(tree)[colnames(Y), colnames(Y)]

model <- gllvm(Y, X, formula = ~(0+ALTITUDE + DBH.CM | 1), colMat = list(phyCov, dist = phyDist), nn.colMat = 5, family = "binomial", num.lv = 0)
