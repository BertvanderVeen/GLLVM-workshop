# GLLVMS: Advanced multivariate analysis of ecological communities in R

### Physalia GLLVM workshop 
### Bert van der Veen
This repository includes material for the Physalia workshop on Generalized linear Latent Variable Models, 10-13 June 2024. Feel free to share, alter, or re-use this material with appropriate referencing of this repository.

Workshop webpage: https://www.physalia-courses.org/courses-workshops/gllvm/

## Generalized Linear Latent Variable Models
Since the 1950s, ecologists have used ordination methods for analysis of data on ecological communities.
In recent years, research by (amongst others)  [Warton et al. 2012](https://www.researchgate.net/profile/David-Warton/publication/223956062_Warton_DI_Wright_ST_Wang_Y_Distance-based_multivariate_analyses_confound_location_and_dispersion_effects_Methods_Ecol_Evol_3_89-101/links/631e6fe9873eca0c007d0ea0/Warton-DI-Wright-ST-Wang-Y-Distance-based-multivariate-analyses-confound-location-and-dispersion-effects-Methods-Ecol-Evol-3-89-101.pdf) has shown that classical ordination methods (PCA, PCoA, RDA, CA, CCA, NMDS etc.) which rely on distance measures have various unfavourable properties that lead to a poor representation of the composition of communities.

[Hui et al. (2015)](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.12236) suggested to use the Generalized Linear Latent Variable Modeling (GLLVM) framework instead, and with it modernize ecological multivariate analysis. It is not quite clear to me (at present) who proposed GLLVMs as a class of models first, but [Skrondal and Rabe-Hesketh (2004)](https://www.taylorfrancis.com/books/mono/10.1201/9780203489437/generalized-latent-variable-modeling-anders-skrondal-sophia-rabe-hesketh) and [Bartholomew et al. 2011](https://onlinelibrary.wiley.com/doi/book/10.1002/9781119970583) are go-to resources. It is clear however, that the first latent variable model method to be developed was Factor analysis (Spearman, 1904), which is a GLLVM for normally distributed responses. Factor analysis is not a very popular method in community ecology, mostly because it was noted early on that its assumption of normally distributed responses does not hold for most ecological applications.

GLLVMs have many properties in common with Generalised Linear Models [(GLMs, Nelder and Wedderburn 1972)](https://www.jstor.org/stable/2344614), Generalised Linear Mixed Models, and with other ordination methods. Estimation tends to be challenging due to the omnipresence of random effects, but there are many favorable statistical properties, and tools for inference, that are worth the hassle. This workshop teaches GLLVMs by first providing a quick recap of GLMs, GLMMs, and classical ordination methods since those methods are more familiar to most ecologists (i.e., basic statistical concepts as sampling theory and such are assumed to be somewhat familiar to participants).  The material of [my Physalia workshop on Generalised Linear Models](https://www.physalia-courses.org/courses-workshops/glm-in-r-1/) [can be found here](https://github.com/BertvanderVeen/GLM-workshop). [Gavin Simpsons' Physalia workshop on classical multivariate analysis](https://www.physalia-courses.org/courses-workshops/vegan/) ([github here](https://github.com/gavinsimpson/physalia-multivariate)) can serve as an introduction to some of the material in this course. 

I will assume all workshop participants to be sufficiently familiar with the R statistical programming language, so that in this course I do not recap use of R and Rstudio.

## Updating R
Please make sure to update your R installation prior to the workshop. Most of the code used in the workshop should function on older versions of R as well, but not all R packages used might be available or function fully.

[You can find an R installation based on your operating system here](https://cran.r-project.org/bin/windows/base/)

## PROGRAM
Sessions from 14:00 to 20:00 (Tuesday to Friday). Sessions will consist of a mix of lectures, in-class discussion, and practical exercises / case studies over Slack and Zoom.

### Tuesday
* [Introduction and overview](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/1Tuesday/Introduction.pdf)
* [Aspects of community data](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/1Tuesday/CommunityData.pdf)
* [Multispecies Generalised Linear Models](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/1Tuesday/VGLMs.pdf)
* [Multispecies Generalised Linear Mixed Models](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/1Tuesday/VGLMMs.pdf)

## Wednesday
* [Diagnostics and comparison](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/2Wednesday/Checking.pdf)
* [Hierarchical environmental responses](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/2Wednesday/HierarchicalResponses.pdf)
* [Joint Species Distribution Models](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/2Wednesday/JSDM.pdf)

## Thursday
* [Model-based ordination](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/3Thursday/ModelbasedOrdination.pdf)
* [Ordination with covariates](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/3Thursday/OrdWithPred.pdf)
* [Unimodal responses](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/3Thursday/Unimodal.pdf)


## Friday
* [Other R packages for fitting GLLVMs and JSDMs](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/4Friday/Other.pdf)
* [Beyond vanilla GLLVMs: hierarchical ordination and machine learning](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/4Friday/Beyond.pdf)
* Discussion and reanalysis of a paper
* Possibility for own data analysis, or addressing suggested topics by participants


# Detailed schedule
|   Day   |Time         |Subject                                                         |
|---------|-------------|:---------------------------------------------------------------|
|Tuesday  |14:00 - 14:45| Introduction <!-- the gllvm R-package? -->                     |
|         |14:45 - 15:05| Brainstorming: challenging properties of community data        | <!--maybe do a menti or smt..-->
|         |14:05 - 15:30| Key concepts in modeling community data                        | <!--sampling variation, properties, estimator, confidence interval, sample size / amount of samples, the things that classicla analysis usually forgets -->
|         |15:30 - 15:45| Break                                                          |
|         |15:45 - 16:45| Vector Generalised Linear Models (VGLM)                        |
|         |16:45 - 17:45| Practical 1: Fitting vector GLMs                               | 
|         |17:45 - 18:30| Break                                                          |
|         |18:30 - 19:15| Vector Generalised Linear Mixed Models (GLMM)                  |
|         |19:15 - 20:00| Practical 2: Predicting diversity with multispecies GLMMs      |
|---------|-------------|----------------------------------------------------------------|
|Wednesday|14:00 - 14:45| Model validation and comparison                                |
|         |14:45 - 15:45| Practical 3: Validation and comparison                         |
|         |15:45 - 16:00| Break                                                          |
|         |16:00 - 16:45| Hierarchically modeling environmental responses                |
|         |16:45 - 17:45| Practical 4: traits and phylogeny                              |
|         |17:45 - 18:30| Break                                                          |
|         |18:30 - 19:15| Incorporating species' correlation                             |
|         |19:15 - 20:00| Practical 5: Joint Species Distribution Models                 |<!-- maybe something about prediction here and checking predictive performance and maps-->
|---------|-------------|----------------------------------------------------------------|
|Thursday |14:00 - 14:45| Model-based ordination <!-- vs. JSDM and classical ordination-->|
|         |14:45 - 15:45| Practical 6: Comparing ordinations                             |<!-- eg ca and dca and nmds, but also residual vs ordiplot -->
|         |15:45 - 16:00| Break                                                          |
|         |16:00 - 16:45| Ordination with predictors                                     | 
|         |16:45 - 17:45| Practical 7: Random canonical coefficients                     |<!--R^2, fixed and random-->
|         |17:45 - 18:30| Break                                                          |
|         |18:30 - 19:15| Ordination with unimodal responses                             |
|         |19:15 - 20:00| Practical 8: Quadratic GLLVM                                   |
|---------|-------------|----------------------------------------------------------------|
|Friday   |14:00 - 14:45| Other R packages for fitting GLLVM and JSDMs                   |
|         |14:45 - 15:45| Practical 9: Fit a model with various R packages               |
|         |15:45 - 16:00| Break                                                          |
|         |16:00 - 16:45| Beyond vanilla GLLVMs <!--maybe a little about correlated lvs and HO-->|
|         |16:45 - 17:45| Practical 10: Article reanalysis                               | 
|         |17:45 - 18:30| Break                                                          |
|         |18:30 - 20:00| Wrapping up - questions, requests, own analysis                |
|---------|-------------|----------------------------------------------------------------|

## Bonus

![](ord.gif)

<!--
# TODO
- consider if we can demonstrate the mean-variance issue from the warton paper when we focus on ordination
- present from a concurrent ordination perspective: one framework to rule them all
  - unconstrained, constrained, and concurrent ordination
  - group-level ordination
  - fixed effects unconstrained ordination
  - much, much, more.
- grey meadow data from gauch
- Consider Wed on ordination, Tues on JSDM, expanding 4th corner and Phylo effects; ordination as a more complex type of jsdm
- remove ML methods
- "partial ordination" might be more familiar to people that use vegan
- table of sensible combinations for gllvm formulas!
- consider small exercises that people can do by themselves
- use menti on the first days to boost interaction or a notepad where people can anonmously write things they dont understand
- num.lv.c fits concurrent ordination, num.lv unconstrained,  num.RR constrained
- consider cutting the presentations up in 30 minute chunks
- after each chunk or model a short exercise, and then a bit about ecological inference
- ordination pres should start on monday, and then finish with "but we want to do multispecies modeling"
- perhaps just start with gllvm on covariates without REs
- second part with gllvm REs and interpretation thereof (so pres stays the same but we use gllvm instead of glmmtmb)

- first ex; get people to use the swiss birds or the wetlands data to try vglm

for friday:
- different r package
- hierarchical ordination
- correlated LVs
- hybrid/multiple ordinations in the same model
- self-analysis or own data
-->
