# Data sources

*Alpine*: via [van der Veen et al. (2021)](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.13595). Originally by [D'amen et al. (2018)](https://doi.org/10.1111/ecog.03148) <br>
*Alpine2*: via the jSDM package. Originally by [Choler 2004](https://www.tandfonline.com/doi/full/10.1657/1523-0430%282005%29037%5B0444%3ACSIAPT%5D2.0.CO%3B2#abstract)<br>
*Ants*: in <tt>mvabund</tt> . Originally by [Gibb et al. (2015)](https://link.springer.com/article/10.1007/s00442-014-3101-9) <br>
*BCI*: in <tt>vegan</tt>.<br>
*Beetles*: via [Niku et al. (2022)](https://onlinelibrary.wiley.com/doi/10.1002/env.2683). Originally by [Ribera et al. (2001)](https://esajournals.onlinelibrary.wiley.com/doi/10.1890/0012-9658%282001%29082%5B1112%3AEOLDAS%5D2.0.CO%3B2) <br>
*Birds*: [from CANOCO 5 datasets](http://regent.prf.jcu.cz/maed2/) <br>
*Coolen*: data originally from [Coolen et al. (2020)](https://academic.oup.com/icesjms/article/77/3/1250/5057660#205124878) <br>
*Dune*: in <tt>vegan</tt>. Originally from Jongman et al. (1995) <br>
*Eucalypt*: from [Pollock et al. (2015)](https://besjournals.onlinelibrary.wiley.com/doi/pdfdirect/10.1111/2041-210X.12180) <br>
*Fungi*: originally by [Abrego et al. (2018)](https://doi.org/10.1111/1365-2745.13839) <br>
*GarchingerCoverage*, *GarchingerFrequency*: Bauer, M.; Albrecht, H. (2022). Vegetation surveys from the calcareous grassland of the nature reserve Garchinger Heide. PANGAEA. [10.1594/PANGAEA.940633](https://doi.pangaea.de/10.1594/PANGAEA.940633) (coverage), [10.1594/PANGAEA.941012](https://doi.pangaea.de/10.1594/PANGAEA.941012) (frequency). Originally by [Bauer & Albrecht (2020)](https://doi.org/10.1016/j.baae.2019.11.003) <br>
*microbialdata*: in <tt>gllvm</tt> via [Niku et al. (2017)](https://link.springer.com/article/10.1007/s13253-017-0304-7). Originally by [Kumar et al. (2017)](https://www.frontiersin.org/journals/microbiology/articles/10.3389/fmicb.2017.00012/full) <br>
*Minchin*: via [ter Braak and Simlauer (2015)](https://link.springer.com/article/10.1007/s11258-014-0356-5). Originally by [Minchin (1987)](https://link.springer.com/article/10.1007/BF00038690) <br>
*Mites*: in <tt>vegan</tt>.<br>
*Podani*: via [Gavin Simpson's github](https://github.com/gavinsimpson/random_code/blob/master/podani.R). Originally by [Podani and Miklos (2002)](https://esajournals.onlinelibrary.wiley.com/doi/abs/10.1890/0012-9658%282002%29083%5B3331%3ARCATHE%5D2.0.CO%3B2?casa_token=O9TjHVYDxJQAAAAA%3AipDGDNiIyKVYnqBOH-sZZZ3yT9oul7H05azAJ4dfrQzfbvN-woShh5la0rMsG9mykxdYBF-Kgdmv5w)<br>
*Pyrifos*: in <tt>vegan</tt>.<br>
*Road*:  by [Mehlhoop et al. (2022)](https://onlinelibrary.wiley.com/doi/full/10.1111/avsc.12673). <br>
*Skabbholmen*: in <tt>gllvm</tt> via [van der Veen et al. (2023)](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.14035). Originally by [Cramer and Hytteborn (1987)](https://link.springer.com/chapter/10.1007/978-94-009-4061-1_16) <br>
*Spider*: in <tt>mvabund</tt>, or extended as eSpider in <tt>gllvm</tt>. Originally by [van der Aart and Smeenk-Enserink (1975)](https://link.springer.com/content/pdf/10.1007/BF00038688.pdf)<br>
*SpiderS*: originally by [Saqib et al. (2017)](https://peerj.com/articles/3795/). <br>
*Tikus*: in <tt>mvabund</tt>.<br>
*Wadden*: originally by [Dewenter et al. (2023)](https://onlinelibrary.wiley.com/doi/full/10.1002/ece3.10815). <br>
*Wetlands*: by [Pina and Lougheed 2022](https://link.springer.com/article/10.1007/s13157-022-01647-2#Sec50). <br>
*SwissBirds*: retrieved via [Zurell et al. (2019)](https://datadryad.org/dataset/doi:10.5061/dryad.k88v330), but originally by [Schmid et al. (1998)](). <br>

## GarchingerCoverage and GarchingerFrequency

These two datasets are two survey methods from the same long-term monitoring programme of the Garchinger Heide calcareous grassland (Bauer & Albrecht 2020), decomposed from the merged mixed-response dataset used in the Friday lecture (built by `4Friday/load_garchinger_heide_gllvm.R`, which fetches and processes the raw PANGAEA data; that script is a one-off data-prep tool and does not need to be re-run to use these CSVs).

- `garchingerCoverageY.csv` / `garchingerCoverageX.csv`: percent cover recorded on the Londo scale (ordinal, 12 classes) at 42 plots, surveyed in 2003 and 2018 (84 rows total).
- `garchingerFrequencyY.csv` / `garchingerFrequencyX.csv`: Raunkiaer frequency, the number of 100 sub-quadrats (out of 100) in which a species was recorded (binomial with `Ntrials = 100`) at 40 plots, surveyed in 1984, 1993 and 2018 (120 rows total).

The two surveys cover overlapping but not identical sets of plots and species; species can be cross-referenced between them by name (see `match_species()` in the loader script). Both `X` files include real GPS-derived coordinates (`E`, `N`, in km) for every row, suitable for spatial models (e.g. `distLV` with `lvCor = ~corExp(1|plot)`); note that plots repeat across survey years, so `distLV` should be built from the *distinct* plot locations, not one row per observation.
