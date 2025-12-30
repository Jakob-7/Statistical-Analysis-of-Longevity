library(dplyr)
library(survival)
library(tidyverse)
library(ReIns)
library(MASS)
library(evmix)
library(ismev)
library(ggplot2)

#idl_complete_death_105.xlsx dataset has to be imported to execute this code
#the dataset is available at www.supercentenarians.org


#IDL Complete 
#Data, Validation graph and Double Interval graph.
IDL=idl_complete_death_105
Age=IDL$AGEYEARS
Country=IDL$DEATH_COUNTRY
Validation=IDL$VALIDATION
boxplot(Age~Validation, col = c("lightblue"))

Obs=IDL[IDL$VALIDATION=="YES", ]
Year=Obs$DEATH_YEAR
Agge=Obs$AGEYEARS
plot(Year, Agge)

miny=min(Year)
maxy=max(Year)
miny
maxy
intercept_min=min(Agge - miny)
intercept_max=max(Agge - maxy)
intercept_max
#Double Interval
Semis=Obs[Obs$AGEYEARS<110,]
Ysemis= Semis$DEATH_YEAR
Agesemis= Semis$AGEYEARS
minsemiy=min(Ysemis)
minsemiy
maxsemiy=max(Ysemis)
ggplot( data=NULL, aes(x = Year, y =Agge )) +
  geom_point(color = "blue", size = 2, shape = 16) +
  geom_vline(xintercept = c(miny,maxy+0.1 ), linetype = "dashed", color = "red") +
  geom_vline(xintercept = c(minsemiy,maxsemiy ), linetype = "dashed", color = "green") +
  labs(title = "Double Interval Truncation",
       x = "Year of Death", y = "Age")+
  theme(plot.title = element_text(size = 20, face = "bold"),
        axis.title = element_text(size = 14),
        axis.text = element_text(size = 12),
        legend.position = "none")
#We selected the interval for the "Yes" Validation data.



#1) Pre-processing the data, clearing "exhaustive" and "sample out" data 
clean_idl <- idl_complete_death_105 %>%
  filter((!idl_complete_death_105$VALIDATION=="SAMPLE OUT")&(!idl_complete_death_105$VALIDATION=="EXHAUSTIVE"))

#2)Creating sequence variable for distributions
seq=seq(105,150, 1)

#4) Estimating maximum likelihood variables for Weibull distribution for all ages
fitw1 <- fitdistr(clean_idl$AGEYEARS, "weibull")$estimate [1]
fitw2 <- fitdistr(clean_idl$AGEYEARS, "weibull")$estimate [2]

weibull_pdf = dweibull(seq, shape = fitw1, scale = fitw2)
plot(seq, weibull_pdf, type = "line", xlab = "Age survived", ylab = "Weibull probability density", main = "Weibull PDF")

weibull_cdf = pweibull(seq, shape = fitw1, scale = fitw2)
plot(seq, weibull_cdf,type = "line", xlab = "Age survived", ylab = "Weibull cumulative distribution", main = "Weibull CDF")

weibull_survival = 1 - weibull_cdf
plot(seq, weibull_survival, type = "line", xlab = "Age survived", ylab = "Survival = S(t)", main = "Weibull survival function")

weibull_hazard = weibull_pdf/weibull_survival
plot(seq, weibull_hazard, type ="line", xlab = "Age survived", ylab = "Hazard rate = h(t)", main = "Weibull hazard function")

#5) Estimating maximum likelihood parameters for Gamma distribution for all ages
fitg1 <- fitdistr(clean_idl$AGEYEARS, "gamma")$estimate [1]
fitg2 <- fitdistr(clean_idl$AGEYEARS, "gamma")$estimate [2]

gamma_pdf = dgamma(seq,shape = fitg1, rate = fitg2)
plot(seq,gamma_pdf,type = "line", xlab = "Age survived", ylab = "Gamma probability density", main = "Gamma PDF")

gamma_cdf = pgamma(seq,shape = fitg1, rate = fitg2)
plot(seq,gamma_cdf,type = "line", xlab = "Age survived", ylab = "Gamma cumulative distribution", main = "Gamma CDF")

gamma_survival = 1 - gamma_cdf # from the survival function: the cap for human live is at 126-127 years
plot(seq, gamma_survival, type = "line", xlab = "Age survived", ylab = "Survival = S(t)", main = "Gamma survival function")

gamma_hazard = gamma_pdf/gamma_survival
plot(seq, gamma_hazard, type ="line", xlab = "Age survived", ylab = "Hazard rate = h(t)", main = "Gamma hazard function")


#Kaplan-Maier. QQ plot to Weibull 

weibull_cdf = pweibull(seq(105,115,1), shape = fitw1, scale = fitw2)
weibull_survival = 1 - weibull_cdf

idl_KM <- clean_idl %>%
  filter(!clean_idl$AGEYEARS>115)

km <- survfit(Surv(idl_KM$AGEYEARS)~1, type="kaplan-meier");km
summary(km)
plot(km,conf.int = F, xlab = "Age survived", ylab = "%Alive = S(t)", main = "Kaplan-Maier model", xlim = c(105,115),ylim = c(1,0)) #Kaplan Maier model for the data

km_Age <- km$time
km_prob <- km$n.risk/km$n

km_survival = data.frame(km_Age,km_prob)
plot(km_survival, type="line")

qqplot(weibull_survival, km_prob, xlim = c(0,1), ylab = "Data quantiles", xlab = "Weibull theoretical quantiles", main = "Weibull Q-Q plot")
abline(0, 1)
text(0.4,0.6, bquote(italic('r = 0.9735')), adj=0, cex=.8)

cor(weibull_survival,km_prob) #corelation = 0.9735

#Kaplan-Maier. QQ plot to Gamma 
gamma_cdf = pgamma(seq(105,115,1),shape = fitg1, rate = fitg2)
gamma_survival = 1 - gamma_cdf

qqplot(gamma_survival, km_prob, xlim = c(0,1), ylab = "Data quantiles", xlab = "Gamma theoretical quantiles", main = "Gamma Q-Q plot")
abline(0, 1)
text(0.4,0.6, bquote(italic('r = 0.9858')), adj=0, cex=.8)

cor(gamma_survival,km_prob) #corelation = 0.9858, slightly better than Weibull


