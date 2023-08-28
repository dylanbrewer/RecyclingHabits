# Authors: Dylan Brewer and Samantha Cameron
# Title: Habit and skill retention in recycling
# Version: August 2023
# Uses SDID on partialed-out variables
################################################################################

# Installation of packages
#install.packages("devtools")
#install.package("Rtools")
#devtools::install_github("synth-inference/synthdid")
#install.packages("ggplot2")

rm(list = ls())

# Run from here

setwd("C:\\Users\\brewe\\Dropbox\\PaperIdeas\\RecyclingHabits\\data\\final")

library(synthdid)
library(ggplot2)
set.seed(12345)

# Load data

data2002_a <- read.csv("final_sdid_2002.csv", header=TRUE, stringsAsFactors=FALSE)

data2002 <- read.csv("partialed_sdid_2002.csv", header=TRUE, stringsAsFactors=FALSE)
data2003 <- read.csv("partialed_sdid_2003.csv", header=TRUE, stringsAsFactors=FALSE)
data2004 <- read.csv("partialed_sdid_2004.csv", header=TRUE, stringsAsFactors=FALSE)
data2005 <- read.csv("partialed_sdid_2005.csv", header=TRUE, stringsAsFactors=FALSE)
data2006 <- read.csv("partialed_sdid_2006.csv", header=TRUE, stringsAsFactors=FALSE)
data2007 <- read.csv("partialed_sdid_2007.csv", header=TRUE, stringsAsFactors=FALSE)
data2008 <- read.csv("partialed_sdid_2008.csv", header=TRUE, stringsAsFactors=FALSE)

# Setup data

setup2002 = panel.matrices(data2002)
setup2003 = panel.matrices(data2003)
setup2004 = panel.matrices(data2004)
setup2005 = panel.matrices(data2005)
setup2006 = panel.matrices(data2006)
setup2007 = panel.matrices(data2007)
setup2008 = panel.matrices(data2008)

# Estimates

tau.hat.2002 = synthdid_estimate(setup2002$Y, setup2002$N0, setup2002$T0)
tau.hat.2003 = synthdid_estimate(setup2003$Y, setup2003$N0, setup2003$T0)
tau.hat.2004 = synthdid_estimate(setup2004$Y, setup2004$N0, setup2004$T0)
tau.hat.2005 = synthdid_estimate(setup2005$Y, setup2005$N0, setup2005$T0)
tau.hat.2006 = synthdid_estimate(setup2006$Y, setup2006$N0, setup2006$T0)
tau.hat.2007 = synthdid_estimate(setup2007$Y, setup2007$N0, setup2007$T0)
tau.hat.2008 = synthdid_estimate(setup2008$Y, setup2008$N0, setup2008$T0)

# Export TEs and conduct inference

breps = 500

estimates = c(synthdid_effect_curve(tau.hat.2002),synthdid_effect_curve(tau.hat.2003),synthdid_effect_curve(tau.hat.2004),synthdid_effect_curve(tau.hat.2005),synthdid_effect_curve(tau.hat.2006),synthdid_effect_curve(tau.hat.2007),synthdid_effect_curve(tau.hat.2008))
var = c(vcov(tau.hat.2002,se.method='placebo',replications = breps),vcov(tau.hat.2003,se.method='placebo',replications = breps),vcov(tau.hat.2004,se.method='placebo',replications = breps),vcov(tau.hat.2005,se.method='placebo',replications = breps),vcov(tau.hat.2006,se.method='placebo',replications = breps),vcov(tau.hat.2007,se.method='placebo',replications = breps),vcov(tau.hat.2008,se.method='placebo',replications = breps))
year = c(2002:2008)

estimates <- data.frame(estimates,var,year)

write.csv(estimates,"partialedestimates.csv",row.names=FALSE)

# Export weights

oweights.2002 = synthdid_controls(tau.hat.2002,mass=1.1)
oweights.2003 = synthdid_controls(tau.hat.2003,mass=1.1)
oweights.2004 = synthdid_controls(tau.hat.2004,mass=1.1)
oweights.2005 = synthdid_controls(tau.hat.2005,mass=1.1)
oweights.2006 = synthdid_controls(tau.hat.2006,mass=1.1)
oweights.2007 = synthdid_controls(tau.hat.2007,mass=1.1)
oweights.2008 = synthdid_controls(tau.hat.2008,mass=1.1)

write.csv(oweights.2002,"partialed_oweights2002.csv",row.names=TRUE)
write.csv(oweights.2003,"partialed_oweights2003.csv",row.names=TRUE)
write.csv(oweights.2004,"partialed_oweights2004.csv",row.names=TRUE)
write.csv(oweights.2005,"partialed_oweights2005.csv",row.names=TRUE)
write.csv(oweights.2006,"partialed_oweights2006.csv",row.names=TRUE)
write.csv(oweights.2007,"partialed_oweights2007.csv",row.names=TRUE)
write.csv(oweights.2008,"partialed_oweights2008.csv",row.names=TRUE)

lweights.2002 = synthdid_controls(tau.hat.2002,weight.type='lambda',mass=1.1)
lweights.2003 = synthdid_controls(tau.hat.2003,weight.type='lambda',mass=1.1)
lweights.2004 = synthdid_controls(tau.hat.2004,weight.type='lambda',mass=1.1)
lweights.2005 = synthdid_controls(tau.hat.2005,weight.type='lambda',mass=1.1)
lweights.2006 = synthdid_controls(tau.hat.2006,weight.type='lambda',mass=1.1)
lweights.2007 = synthdid_controls(tau.hat.2007,weight.type='lambda',mass=1.1)
lweights.2008 = synthdid_controls(tau.hat.2008,weight.type='lambda',mass=1.1)

write.csv(lweights.2002,"partialed_lweights2002.csv",row.names=TRUE)
write.csv(lweights.2003,"partialed_lweights2003.csv",row.names=TRUE)
write.csv(lweights.2004,"partialed_lweights2004.csv",row.names=TRUE)
write.csv(lweights.2005,"partialed_lweights2005.csv",row.names=TRUE)
write.csv(lweights.2006,"partialed_lweights2006.csv",row.names=TRUE)
write.csv(lweights.2007,"partialed_lweights2007.csv",row.names=TRUE)
write.csv(lweights.2008,"partialed_lweights2008.csv",row.names=TRUE)
