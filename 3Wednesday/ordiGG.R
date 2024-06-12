ggord <- function(...) UseMethod('ggord')

ggord.default <- function(obs, vecs, axes = c('1', '2'), grp_in = NULL, cols = NULL, facet = FALSE, nfac = NULL,
                          addpts = NULL, obslab = FALSE, ptslab = FALSE, ellipse = TRUE, ellipse_pro = 0.95, poly = TRUE,
                          polylntyp = 'solid', hull = FALSE, arrow = 0.4, labcol = 'black', veccol = 'black', vectyp = 'solid',
                          veclsz = 0.5, ext = 1.2, repel = FALSE, vec_ext = 1, vec_lab = NULL, size = 4, sizelab = NULL,
                          addsize = size/2, addcol = 'blue', addpch = 19, txt = 4, alpha = 1, alpha_el = 0.4, xlims = NULL,
                          ylims = NULL, var_sub = NULL, coord_fix = TRUE, parse = TRUE, grp_title = 'Groups', force = 1,
                          max.overlaps = 10, exp = c(0, 0), rotate = FALSE,...){

  # extend vectors by scale
  vecs <- vecs * vec_ext

  # tweaks to vecs for plotting
  # create vecs label  from vecs for labels
  names(vecs) <- c('one', 'two')
  vecs <- vecs[, na.omit(names(vecs))]

  vecs_lab <- ext * vecs
  if(is.null(vec_lab)) vecs_lab$labs <- as.character(row.names(vecs_lab))
  else{
    vecs_lab$labs <- vec_lab[row.names(vecs_lab)]
  }
  vecs$lab <- row.names(vecs)

  # add groups if grp_in is not null
  if(!is.null(grp_in)) obs$Groups <- factor(grp_in)

  # remove vectors for easier viz
  if(!is.null(var_sub)){

    var_sub <- paste(var_sub, collapse = '|')
    vecs <- vecs[grepl(var_sub, vecs$lab), ]
    vecs_lab <- vecs_lab[grepl(var_sub, vecs_lab$lab), ]

  }

  # add size to obs
  if(length(size) > 1){

    if(length(size) != nrow(obs))
      stop('size must have length equal to 1 or ', nrow(obs))

    obs$size <- size

    if(is.null(sizelab))
      sizelab <- 'Size'

  }

  ## plots

  # individual points
  nms <- names(obs)[1:2]
  names(obs)[1:2] <- c('one', 'two')
  obs$lab <- row.names(obs)
  p <- ggplot(obs, aes_string(x = 'one', y = 'two')) +
    scale_x_continuous(name = nms[1], limits = xlims, expand = c(exp, exp)) +
    scale_y_continuous(name = nms[2], limits = ylims, expand = c(exp, exp)) +
    theme_bw()

  # map size as aesthetic if provided
  if(length(size) > 1){

    # observations as points or text, colour if groups provided
    if(obslab){
      if(!is.null(obs$Groups))
        p <- p + geom_text(aes_string(group = 'Groups', fill = 'Groups', colour = 'Groups', label = 'lab', size = 'size'), alpha = alpha, parse = parse)
      else
        p <- p + geom_text(aes_string(size = 'size'), label = row.names(obs), alpha = alpha, parse = parse)
    } else {
      if(!is.null(obs$Groups))
        p <- p + geom_point(aes_string(group = 'Groups', fill = 'Groups', colour = 'Groups', shape = 'Groups', size = 'size'), alpha = alpha) +
          scale_shape_manual('Groups', values = rep(16, length = length(obs$Groups)))
      else
        p <- p + geom_point(aes_string(size = 'size'), alpha = alpha)
    }

    # change size legend title if provided
    p <- p + guides(size=guide_legend(title = sizelab))

  } else {

    # observations as points or text, colour if groups provided
    if(obslab){
      if(!is.null(obs$Groups))
        p <- p + geom_text(aes_string(group = 'Groups', fill = 'Groups', colour = 'Groups', label = 'lab'), size = size, alpha = alpha, parse = parse)
      else
        p <- p + geom_text(label = row.names(obs), size = size, alpha = alpha, parse = parse)
    } else {
      if(!is.null(obs$Groups))
        p <- p + geom_point(aes_string(group = 'Groups', fill = 'Groups', colour = 'Groups', shape = 'Groups'), size = size, alpha = alpha) +
          scale_shape_manual('Groups', values = rep(16, length = length(obs$Groups)))
      else
        p <- p + geom_point(size = size, alpha = alpha)
    }

  }

  # add species scores if addpts not null, for triplot
  if(!is.null(addpts)){

    addpts$lab <- paste0(row.names(addpts))
    #was former  italic
    # addpts$lab <- paste0('italic(', row.names(addpts), ')')

    nms <- names(addpts)[1:2]
    names(addpts)[1:2] <- c('one', 'two')

    # pts as text labels if TRUE
    if(ptslab){
      p <- p +
        geom_text(data = addpts, aes_string(x = 'one', y = 'two', label = 'lab'),
                  size = addsize, col = addcol, alpha = alpha, parse = parse)
    } else {
      p <- p +
        geom_point(data = addpts, aes_string(x = 'one', y = 'two'),
                   size = addsize, col = addcol, alpha = alpha, shape = addpch)
    }
  }

  # fixed coordinates if TRUE
  if(coord_fix)
    p <- p + coord_fixed()

  # concentration ellipse if there are groups, from ggbiplot
  if(!is.null(obs$Groups) & ellipse) {

    theta <- c(seq(-pi, pi, length = 50), seq(pi, -pi, length = 50))
    circle <- cbind(cos(theta), sin(theta))

    ell <- ddply(obs, 'Groups', function(x) {
      if(nrow(x) <= 2) {
        return(NULL)
      }
      sigma <- var(cbind(x$one, x$two))
      mu <- c(mean(x$one), mean(x$two))
      ed <- sqrt(qchisq(ellipse_pro, df = 2))
      data.frame(sweep(circle %*% chol(sigma) * ed, 2, mu, FUN = '+'))
    })
    names(ell)[2:3] <- c('one', 'two')

    # get convex hull for ell ord_in, this is a hack to make it work with geom_polygon
    ell <- ddply(ell, .(Groups), function(x) x[chull(x$one, x$two), ])

    if(poly){

      p <- p + geom_polygon(data = ell, aes(group = Groups, fill = Groups), alpha = alpha_el)

    } else {

      # setup line type as grp_in or standard
      if(identical(polylntyp, obs$Groups))
        p <- p + geom_polygon(data = ell, aes_string(color = 'Groups', group = 'Groups', linetype = 'Groups'), fill = NA, alpha = alpha)
      else
        p <- p + geom_polygon(data = ell, aes_string(color = 'Groups', group = 'Groups'), linetype = polylntyp, fill = NA, alpha = alpha)

    }

  }

  # add convex hull if true
  if(hull){

    if(!is.null(obs$Groups)){

      # get convex hull
      chulls <- ddply(obs, .(Groups), function(x) x[chull(x$one, x$two), ])

      if(poly){

        p <- p + geom_polygon(data = chulls, aes(group = Groups, fill = Groups), alpha = alpha_el)

      } else {

        # setup line type as grp_in or standard
        if(identical(polylntyp, obs$Groups))
          p <- p + geom_polygon(data = chulls, aes(group = Groups, colour = Groups, linetype = Groups), fill = NA, alpha = alpha)
        else
          p <- p + geom_polygon(data = chulls, aes(group = Groups, colour = Groups), linetype = polylntyp, fill = NA, alpha = alpha)

      }

    } else {

      chulls <- obs[chull(obs$one, obs$two), ]

      if(poly){

        p <- p + geom_polygon(data = chulls, alpha = alpha_el)

      } else {

        p <- p + geom_polygon(data = chulls, linetype = polylntyp, alpha = alpha, fill = NA)

      }

    }

  }

  # set colors if provided
  if(!is.null(cols) & !is.null(obs$Groups)){
    if(length(cols) != length(unique(obs$Groups)))
      stop('col vector must have length equal to unique values in grp_in')
    p <- p +
      scale_colour_manual('Groups', values = cols) +
      scale_fill_manual('Groups', values = cols)
  }

  # add vectors
  if(!is.null(arrow))
    p <- p + geom_segment(
      data = vecs,
      aes_string(x = 0, y = 0, xend = 'one', yend = 'two'),
      arrow = grid::arrow(length = grid::unit(arrow, "cm")),
      colour= veccol, linetype = vectyp, size = veclsz
    )

  # facet if true and groups
  nlabs <- 1
  if(facet & !is.null(obs$Groups)){

    p <- p +
      facet_wrap(~Groups, ncol = nfac)

    # for labels if facetting
    nlabs <- length(unique(obs$Groups))

  }

  # add labels
  if(!is.null(txt)){

    # repel overlapping labels
    if(repel){

      p <- p + ggrepel::geom_text_repel(data = vecs_lab, aes_string(x = 'one', y = 'two'),
                                        label = rep(unlist(lapply(vecs_lab$labs, function(x) as.character(as.expression(x)))), nlabs),
                                        size = txt,
                                        parse = parse,
                                        point.padding = NA,
                                        color = labcol,
                                        force = force,
                                        max.overlaps = max.overlaps

      )

    } else {

      p <- p + geom_text(data = vecs_lab, aes_string(x = 'one', y = 'two'),
                         label = rep(unlist(lapply(vecs_lab$labs, function(x) as.character(as.expression(x)))), nlabs),
                         size = txt,
                         parse = parse,
                         color = labcol
      )

    }

  }

  # set legend titles to all scales
  p <- p +
    guides(
      fill = guide_legend(title = grp_title),
      colour = guide_legend(title = grp_title),
      shape = guide_legend(title = grp_title)
    )

  return(p)

}

ggord.gllvm <- function(ord_in, type = NULL, grp_in = NULL, axes = c(1,2), scl = 0.5, rotate = FALSE,...){
  p <- ncol(ord_in$y)
  num.lv <- ord_in$num.lv
  num.lv.c <- ord_in$num.lv.c
  num.RR <- ord_in$num.RR
  quadratic <- ord_in$quadratic

  if((num.lv.c+num.RR)==0&is.null(type)){
    type <- "residual"
  }else if(is.null(type)){
    if(num.lv.c==0){
      type <- "marginal"
    }else{
      type <- "conditional"
    }
  }
  if(!is.null(type)){

  }
  # This must be done, otherwise the scale of the ordination is non informative if the scale of params$theta () differ drastically:
  if(type == "residual"|num.lv>0){
    # First create an index for the columns with unconstrained LVs
    which.scl <- NULL
    if(num.lv>0){
      which.scl <- (num.lv.c+num.RR+1):(num.lv.c+num.RR+num.lv)
    }

    if(quadratic!=FALSE){
      which.scl <- c(which.scl, which.scl+num.lv.c+num.RR+num.lv)
    }
    # Add indices of constrained LVs if present
    if(num.lv.c>0&type=="residual"){
      which.scl <- c(which.scl, 1:num.lv.c)
      if(quadratic!=FALSE){
        which.scl <- c(which.scl, 1:num.lv.c+num.lv.c+num.RR+num.lv)
      }
    }
    which.scl <- sort(which.scl)
    # Do the scaling
    if(quadratic==FALSE){
      ord_in$params$theta[,which.scl] <- ord_in$params$theta[,which.scl, drop=FALSE]%*%diag(ord_in$params$sigma.lv, nrow = length(ord_in$params$sigma.lv), ncol = length(ord_in$params$sigma.lv))
    }else{
      sig <- diag(c(ord_in$params$sigma.lv,ord_in$params$sigma.lv^2))
      ord_in$params$theta[,which.scl] <- ord_in$params$theta[,which.scl,drop=FALSE]%*%sig
    }

  }
  if(is.null(ord_in$lv.X) && !is.null(ord_in$lv.X.design)){
    ord_in$lv.X <- ord$lv.X.design
  }
  lv <- gllvm::getLV(ord_in, type = type)

  do_svd <- svd(lv)
  # do_svd <- svd(lv)
  # do_svd <- svd(ord_in$lvs)
  #ensure that rotation is the same even when we use different types of
  #scores
  if(num.lv.c>0|(num.RR+num.lv)>0){
    do_svd$v <- svd(gllvm::getLV(ord_in))$v
  }
  if(!rotate){
    do_svd$v <- diag(ncol(do_svd$v))
  }

  svd_rotmat_sites <- do_svd$v
  svd_rotmat_species <- do_svd$v

  choose.lvs <- lv
  if(quadratic == FALSE){choose.lv.coefs <- gllvm::getLoadings(ord_in)}else{choose.lv.coefs<-gllvm::optima(ord_in,sd.errors=F)}

  #A check if species scores are within the range of the LV
  ##If spp.arrows=TRUE plots those that are not in range as arrows
  if(ord_in$quadratic!=FALSE){
    spp.arrows <- T
  }else{
    spp.arrows <- F
  }
  if(spp.arrows){
    lvth <- max(abs(choose.lvs))
    idx <- choose.lv.coefs>(-lvth)&choose.lv.coefs<lvth
  }else{
    idx <- matrix(TRUE,ncol=num.lv+num.lv.c+num.RR,nrow=p)
  }

  bothnorms <- vector("numeric",ncol(choose.lv.coefs))
  for(i in 1:ncol(choose.lv.coefs)){
    bothnorms[i] <- sqrt(sum(choose.lvs[,i]^2)) * sqrt(sum(choose.lv.coefs[idx[,i],i]^2))
  }

  # bothnorms <- sqrt(colSums(choose.lvs^2)) * sqrt(colSums(choose.lv.coefs^2))
  ## Standardize both to unit norm then scale using bothnorms. Note alpha = 0.5 so both have same norm. Otherwise "significance" becomes scale dependent
  scaled_cw_sites <- t(t(choose.lvs) / sqrt(colSums(choose.lvs^2)) * (bothnorms^scl))
  # scaled_cw_species <- t(t(choose.lv.coefs) / sqrt(colSums(choose.lv.coefs^2)) * (bothnorms^(1-alpha)))
  scaled_cw_species <- choose.lv.coefs
  for(i in 1:ncol(scaled_cw_species)){
    scaled_cw_species[,i] <- choose.lv.coefs[,i] / sqrt(sum(choose.lv.coefs[idx[,i],i]^2)) * (bothnorms[i]^(1-scl))
  }

  choose.lvs <- scaled_cw_sites%*%svd_rotmat_sites
  choose.lv.coefs <- scaled_cw_species%*%svd_rotmat_species

  # data to plot
  obs <- data.frame(choose.lvs[,axes,drop=F])
  obs$Groups <- grp_in
  addpts <- data.frame(choose.lv.coefs)

  # vectors for constraining matrix
  if((ord_in$num.lv.c+ord_in$num.RR)>0){
    constr <- data.frame((ord_in$params$LvXcoef%*%svd_rotmat_sites)[,axes,drop=F])
  }
  # make a nice label for the axes
  colnames(obs)[1:2] <- paste('Latent variable', axes)

  ggord.default(obs, vecs = constr, axes, addpts = addpts, ...)

}
