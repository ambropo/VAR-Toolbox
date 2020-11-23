## ---- eval=F-------------------------------------------------------------
#  rm(list = ls())
#  set.seed(12345)
#  library(VARsignR)
#  data(uhligdata)

## ---- eval=F-------------------------------------------------------------
#  constr <- c(+4,-3,-2,-5)

## ---- eval=F-------------------------------------------------------------
#  model1 <- uhlig.reject(Y=uhligdata, nlags=12, draws=200, subdraws=200, nkeep=1000, KMIN=1,
#                          KMAX=6, constrained=constr, constant=FALSE, steps=60)
#  
#  Starting MCMC, Tue Dec  8 09:36:53 2015.
#    |========================                             |  44%
#  
#   MCMC finished, Tue Dec  8 09:37:01 2015.

## ---- eval=F-------------------------------------------------------------
#  summary(model1)
#         Length Class  Mode
#  IRFS   360000 -none- numeric
#  FEVDS  360000 -none- numeric
#  SHOCKS 456000 -none- numeric
#  BDraws 432000 -none- numeric
#  SDraws  36000 -none- numeric

## ---- eval=F-------------------------------------------------------------
#  irfs1 <- model1$IRFS
#  
#  vl <- c("GDP","GDP Deflator","Comm.Pr.Index","Fed Funds Rate",
#          "NB Reserves", "Total Reserves")
#  
#  irfplot(irfdraws=irfs1, type="median", labels=vl, save=FALSE, bands=c(0.16, 0.84),
#          grid=TRUE, bw=FALSE)

## ---- eval=F-------------------------------------------------------------
#  fevd1 <- model1$FEVDS
#  fevdplot(fevd1, label=vl, save=FALSE, bands=c(0.16, 0.84), grid=TRUE,
#           bw=FALSE, table=FALSE, periods=NULL)

## ---- eval=F-------------------------------------------------------------
#  fevd.table <- fevdplot(fevd1, table=TRUE, label=vl, periods=c(1,10,20,30,40,50,60))
#  
#  print(fevd.table)
#  
#       GDP    GDP Deflator Comm.Pr.Index Fed Funds Rate NB Reserves Total Reserves
#  1   8.48         7.21          6.55          11.54        5.63           7.70
#  10  9.56         8.50          6.99          13.02        8.50           8.47
#  20 11.86         9.53          7.29          13.12        9.75           9.41
#  30 13.03         9.64          7.65          13.00        9.94           9.85
#  40 12.98         9.81          8.37          12.89       10.16           9.90
#  50 12.49         9.71          8.89          12.71       10.16           9.96
#  60 12.08         9.91          9.31          12.67       10.24          10.12

## ---- eval=F-------------------------------------------------------------
#  shocks <- model1$SHOCKS
#  ss <- ts(t(apply(shocks,2,quantile,probs=c(0.5, 0.16, 0.84))), frequency=12, start=c(1966,1))
#  
#  plot(ss[,1], type="l", col="blue", ylab="Interest rate shock", ylim=c(min(ss), max(ss)))
#  abline(h=0, col="black")

## ---- eval=F-------------------------------------------------------------
#  lines(ss[,2], col="red")
#  lines(ss[,3], col="red")

## ---- eval=F-------------------------------------------------------------
#  model2 <- rwz.reject(Y=uhligdata, nlags=12, draws=200, subdraws=200, nkeep=1000,
#                        KMIN=1, KMAX=6, constrained=constr, constant=FALSE, steps=60)
#  
#  Starting MCMC, Tue Dec  8 10:08:31 2015.
#    |================================================     |  90%
#  
#   MCMC finished, Tue Dec  8 10:08:49 2015.
#  
#  irfs2 <- model2$IRFS
#  
#  irfplot(irfdraws=irfs2, type="median", labels=vl, save=FALSE, bands=c(0.16, 0.84),
#          grid=TRUE, bw=FALSE)

## ---- eval=F-------------------------------------------------------------
#  model3 <- uhlig.penalty(Y=uhligdata, nlags=12, draws=2000, subdraws=1000,
#                          nkeep=1000, KMIN=1, KMAX=6, constrained=constr,
#                          constant=FALSE, steps=60, penalty=100, crit=0.001)
#  
#  Starting MCMC, Tue Dec  8 10:22:34 2015.
#    |==========================                           |  50%
#  
#   Warning! 3 draw(s) did not converge.
#  
#   MCMC finished, Tue Dec  8 10:24:49 2015.

## ---- eval=F-------------------------------------------------------------
#  irfs3 <- model3$IRFS
#  irfplot(irfdraws=irfs3, type="median", labels=vl, save=FALSE, bands=c(0.16, 0.84),
#          grid=TRUE, bw=FALSE)

## ---- eval=F-------------------------------------------------------------
#  constr5 <- c(+4,-3,-2,-5,-6)
#  
#  model5c <- uhlig.reject(Y=uhligdata,  nlags=12, draws=200, subdraws=200, nkeep=1000,
#                          KMIN=1, KMAX=6, constrained=constr5, constant=FALSE, steps=60)
#  
#  Starting MCMC, Fri Dec 11 22:59:28 2015.
#    |==========================                   |  62%
#  
#   MCMC finished, Fri Dec 11 22:59:37 2015.
#  
#  irf5c <- model5c$IRFS
#  irfplot(irf5c, labels=vl)

## ---- eval=F-------------------------------------------------------------
#  fp.target(Y=uhligdata, irfdraws=irfs1,  nlags=12,  constant=F, labels=vl, target=TRUE,
#            type="median", bands=c(0.16, 0.84), save=FALSE,  grid=TRUE, bw=FALSE,
#            legend=TRUE, maxit=1000)

## ---- eval=F-------------------------------------------------------------
#  model0 <- rfbvar(Y=uhligdata, nlags=12, draws=1000, constant=FALSE,
#                    steps=60, shock=4)
#  
#  irfs0 <- model0$IRFS
#  
#  irfplot(irfdraws=irfs0, type="median", labels=vl, save=FALSE, bands=c(0.16, 0.84),
#          grid=TRUE, bw=FALSE)

