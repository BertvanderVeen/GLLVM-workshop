# GLLVMs: Advanced multivariate analysis of ecological communities in R

### Physalia GLLVM workshop 
### Bert van der Veen
This repository includes material for the Physalia workshop on Generalized Linear Latent Variable Models, 7-10 July 2026. Feel free to share, alter, or re-use this material with appropriate referencing of this repository.

Workshop webpage: https://www.physalia-courses.org/courses-workshops/gllvm/

## Generalized Linear Latent Variable Models
Since the 1950s, ecologists have used ordination methods for analysis of data on ecological communities. In recent years, research has shown that classical ordination methods (PCA, PCoA, RDA, CA, CCA, NMDS etc.) which rely on distance measures have various unfavourable properties. [Warton et al. (2012)](https://www.researchgate.net/profile/David-Warton/publication/223956062_Warton_DI_Wright_ST_Wang_Y_Distance-based_multivariate_analyses_confound_location_and_dispersion_effects_Methods_Ecol_Evol_3_89-101/links/631e6fe9873eca0c007d0ea0/Warton-DI-Wright-ST-Wang-Y-Distance-based-multivariate-analyses-confound-location-and-dispersion-effects-Methods-Ecol-Evol-3-89-101.pdf) showed that distance-based methods confound location and dispersion effects, [O'Hara and Kotze (2010)](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/j.2041-210x.2010.00021.x) demonstrated that log-transforming count data is generally inappropriate, and classical methods lack random effects, uncertainty quantification, predictive capacity, and a coherent unified framework.

[Hui et al. (2015)](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.12236) suggested the Generalized Linear Latent Variable Modeling (GLLVM) framework as a modern alternative for ecological multivariate analysis. GLLVMs can be seen as a multivariate extension of GL(M)Ms, inheriting many useful properties of both statistical models and ordination methods. Resources include [Skrondal and Rabe-Hesketh (2004)](https://www.taylorfrancis.com/books/mono/10.1201/9780203489437/generalized-latent-variable-modeling-anders-skrondal-sophia-rabe-hesketh) and [Bartholomew et al. (2011)](https://onlinelibrary.wiley.com/doi/book/10.1002/9781119970583).

This workshop teaches GLLVMs through a mix of lectures and practicals, building from multispecies GLMs and GLMMs through JSDMs to model-based ordination and beyond. Basic familiarity with GLMs and the R programming language is assumed. The material of [my Physalia workshop on Generalised Linear Models](https://www.physalia-courses.org/courses-workshops/glm-in-r-1/) [can be found here](https://github.com/BertvanderVeen/GLM-workshop). [Gavin Simpson's Physalia workshop on classical multivariate analysis](https://www.physalia-courses.org/courses-workshops/vegan/) ([github here](https://github.com/gavinsimpson/physalia-multivariate)) can serve as an introduction to some of the material in this course.

## Updating R
Please make sure to update your R installation prior to the workshop. Most of the code used in the workshop should function on older versions of R as well, but not all R packages used might be available or function fully.

[You can find an R installation based on your operating system here](https://cran.r-project.org/bin/windows/base/)

## PROGRAM
Sessions from 14:00 to 20:00 (Tuesday to Friday). Sessions will consist of a mix of lectures, in-class discussion, and practical exercises over Zoom.

### Tuesday
*background to multispecies modeling*
* [Introduction to model-based community analysis](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/1Tuesday/CommunityIntroduction.pdf)
* [Multispecies Generalised Linear Models](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/1Tuesday/VGLMs.pdf)
* [Multispecies Generalised Linear Mixed Models](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/1Tuesday/VGLMMs.pdf)
* [Model checking and comparison](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/1Tuesday/Checking.pdf)

Practicals: [1: Fitting multispecies GLMs](https://htmlpreview.github.io/?https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/Practicals/1Practical.html), [2: Multispecies GLMMs and diagnostics](https://htmlpreview.github.io/?https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/Practicals/2Practical.html)

### Wednesday
*joint species distribution models*
* [Hierarchical environmental responses](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/2Wednesday/HierarchicalResponses.pdf)
* [Joint Species Distribution Models](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/2Wednesday/JSDM.pdf)
* [Predicting species richness and diversity](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/2Wednesday/Diversity.pdf)

Practicals: [3: Traits and phylogeny](https://htmlpreview.github.io/?https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/Practicals/3Practical.html), [4: Joint Species Distribution Models](https://htmlpreview.github.io/?https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/Practicals/4Practical.html), [5: Predicting diversity](https://htmlpreview.github.io/?https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/Practicals/5Practical.html)

### Thursday
*ordination*
* [Model-based ordination](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/3Thursday/ModelbasedOrdination.pdf)
* [Ordination with covariates](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/3Thursday/OrdWithPred.pdf)
* [Conditioning and nested designs](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/3Thursday/Conditioning.pdf)

Practicals: [6: Model-based ordination](https://htmlpreview.github.io/?https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/Practicals/6Practical.html), [7: Ordination with covariates](https://htmlpreview.github.io/?https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/Practicals/7Practical.html), [8: Conditioning and partial ordination](https://htmlpreview.github.io/?https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/Practicals/8Practical.html)

### Friday
*advanced GLLVM extensions*
* [Unimodal response models](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/4Friday/Unimodal.pdf)
* [Extensions: spatial/temporal autocorrelation and mixed response types](https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/4Friday/Extensions.pdf)

Practicals: [9: Unimodal responses](https://htmlpreview.github.io/?https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/Practicals/9Practical.html), [10: Extensions](https://htmlpreview.github.io/?https://github.com/BertvanderVeen/GLLVM-workshop/blob/main/Practicals/10Practical.html)
* Own data analysis and wrap-up

# Detailed schedule
|   Day   |Time         |Subject                                                         |
|---------|-------------|:---------------------------------------------------------------|
|Tuesday  |14:00 - 14:45| Introduction to model-based community analysis                 |
|         |14:45 - 15:45| Vector Generalised Linear Models                               |
|         |15:45 - 16:00| Break                                                          |
|         |16:00 - 17:00| Practical 1: Fitting multispecies GLMs                         |
|         |17:00 - 17:45| Vector Generalised Linear Mixed Models                         |
|         |17:45 - 18:30| Break                                                          |
|         |18:30 - 19:00| Model checking and comparison                                  |
|         |19:00 - 20:00| Practical 2: Multispecies GLMMs and diagnostics                |
|---------|-------------|----------------------------------------------------------------|
|Wednesday|14:00 - 14:45| Hierarchically modelling environmental responses               |
|         |14:45 - 15:45| Practical 3: Traits and phylogeny                              |
|         |15:45 - 16:00| Break                                                          |
|         |16:00 - 16:45| Joint Species Distribution Models                              |
|         |16:45 - 17:45| Practical 4: Joint Species Distribution Models                 |
|         |17:45 - 18:30| Break                                                          |
|         |18:30 - 19:15| Predicting species richness and diversity                      |
|         |19:15 - 20:00| Practical 5: Predicting diversity                              |
|---------|-------------|----------------------------------------------------------------|
|Thursday |14:00 - 14:45| Model-based ordination                                         |
|         |14:45 - 15:45| Practical 6: Model-based ordination                            |
|         |15:45 - 16:00| Break                                                          |
|         |16:00 - 16:45| Ordination with covariates                                     |
|         |16:45 - 17:45| Practical 7: Ordination with covariates                        |
|         |17:45 - 18:30| Break                                                          |
|         |18:30 - 19:15| Conditioning and nested designs                                |
|         |19:15 - 20:00| Practical 8: Conditioning and partial ordination               |
|---------|-------------|----------------------------------------------------------------|
|Friday   |14:00 - 14:45| Unimodal response models                                       |
|         |14:45 - 15:30| Practical 9: Unimodal responses                                |
|         |15:30 - 15:45| Break                                                          |
|         |15:45 - 16:30| Extensions: spatial/temporal and mixed response types          |
|         |16:30 - 17:30| Practical 10: Extensions                                       |
|         |17:30 - 18:15| Break                                                          |
|         |18:15 - 20:00| Own data analysis and wrap-up                                  |
|---------|-------------|----------------------------------------------------------------|


## Formula interface table

<table>
  <thead>
    <tr>
      <th>gllvm argument</th>
      <th>Function</th>
      <th>Accepted structures</th>
      <th>Data</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>formula</code></td>
      <td>Fixed and random species-specific effects</td>
      <td><tt>lme4</tt>-type formula (e.g. <code> ~ x1 + (0+x2|1)</code>)</td>
      <td><code>X</code>: environmental variables</td>
    </tr>
    <tr>
      <td><code>lv.formula</code></td>
      <td>Specifies fixed or random effect in the ordination</td>
      <td><tt>lme4</tt>-type formula (e.g., <code> ~x1 + x2</code> or <code> ~(0+x1 + x2|1)</code></td>
      <td><code>X</code>: covariates for the latent variables</td>
    </tr>
    <tr>
      <td><code>row.eff</code></td>
      <td>Includes fixed and random species-common effects</td>
      <td><tt>glmmTMB</tt>-type formula, alternatively "fixed" or "random"</td>
      <td><code>studyDesign</code>: any categorical or continuous covariates</td>
    </tr>
    <tr>
      <td><code>lvCor</code></td>
      <td>For group-level unconstrained ordination or to introduce correlation structure among unconstrained latent variables</td>
      <td><tt>lme4</tt>-type formula</td>
      <td><code>studyDesign</code></td>
    </tr>
  </tbody>
</table>


## R packages for multivariate analysis

The `gllvm` R package is the primary focus of this workshop, but several other packages implement related methods for model-based multivariate analysis of community data. A detailed overview with examples is available in [this presentation](old/otherPackages.pdf) and accompanying [practical](old/orphaned/Practicals/9Practical.html).

| Package | Description |
|---------|-------------|
| [mvabund](https://cran.r-project.org/package=mvabund) | Multivariate GLMs for community data; hypothesis testing via resampling |
| [Hmsc](https://cran.r-project.org/package=Hmsc) | Hierarchical Model of Species Communities; Bayesian JSDM framework |
| [sjSDM](https://cran.r-project.org/package=sjSDM) | Joint Species Distribution Models via deep learning |
| [boral](https://cran.r-project.org/package=boral) | Bayesian ordination and regression analysis using latent variables |
| [ecopCopula](https://cran.r-project.org/package=ecopCopula) | Copula-based models for multivariate abundance data |
| [glmmTMB](https://cran.r-project.org/package=glmmTMB) | Generalised linear mixed models via TMB; flexible random effects |


## Bonus

The animation below shows the variational approximation converging to the final solution when fitting a GLLVM to the spider dataset. The ordination plots settle as the algorithm iterates toward the maximum of the approximate likelihood.

![](ord.gif)

<!-- suggestions
- different dataset for unimodal model; one that has more optima in range of the LVs
- present species richness (P5/Diversity) as a form of co-occurrence, to link it more tightly into the rest of the workshop (JSDM/ordination framing) rather than treating it as a standalone univariate summary
- flow of CommunityIntroduction.Rmd (first lecture, Tuesday) needs considerable improvement
- show a predict function slide in the constrained ordination, conditioning, or another day 3 ordination presentation, wherever it fits best
-->
