library(ggplot2)
library(gridExtra)
library(dplyr)
library(leaflet)
library(corrplot)
library(leaflet)
library(readxl)
library(car)
library(PMCMR)

pacientes <- read.table('./data/pacientes.csv', sep=',', h=T)
medicos <- read_xlsx('./data/dados_raw.xlsx', sheet = 2)

pacientes <- pacientes %>% filter(dist < 50)

shapiro.test(pacientes$Idade)
shapiro.test(pacientes$dist)

nortest::ad.test(pacientes$Idade)
nortest::pearson.test(pacientes$Idade)

#anova distacia para medico, MOIO
model<-aov(dist~Medico, pacientes)
model
summary(model)
# A partir da estat�stica F e seu valor-p abaixo de 0.05 podemos temos 
# embasamento estat�stico para afirmar com grande confian�a que as m�dias de 
# distancia dos pacientes difere entre os locais das UBS analisado.

#testando homostetaticidade
pacientes$Medico<-as.factor(pacientes$Medico)
leveneTest(dist~Medico, pacientes)
# A hip�tese nula do Teste de Levene � de que n�o h� diferen�a entre as 
# vari�ncias dos grupos. O valor-p menor do que 0.05 nos d� embasamento 
# estatistico para afirmar que as vari�ncias s�o de fato diferente e portanto 
# nossos dados s�o heterogeneos
shapiro.test(resid(model))
# A hip�tese nula do Teste de Shapiro-Wilk � de que n�o h� diferen�a entre a 
# nossa distribui��o dos dados e a distribui��o normal. O valor-p menor do que  
# 0.05 nos d� uma confian�a estat�stica para afirmar que as distribui��o dos  
# nossos res�duos se difere da distribui��o normal
TukeyHSD(model)
# as medias na� se diferem em ,b-a,d-c,e-c,f-c,g-c,e-d,f-d,g-d,f-e,g-e

#anova distacia para medico,
model<-aov(dist~categoria, pacientes)
model
summary(model)
# A partir da estat�stica F e seu valor-p acima de 0.05 temos 
# embasamento estat�stico para afirmar com grande confian�a que as m�dias de 
# distancia dos pacientes  n�o se difere entre a idade dos pacientes.
pacientes$categoria<-as.factor(pacientes$categoria)
leveneTest(dist~categoria, pacientes)
# A hip�tese nula do Teste de Levene � de que n�o h� diferen�a entre as 
# vari�ncias dos grupos. O valor-p maior do que 0.05 nos d� uma 
# confian�a estat�stica para afirmar que as vari�ncias s�o de fato 
# iguais e portanto nossos dados s�o homog�neos.
shapiro.test(resid(model))
# A hip�tese nula do Teste de Shapiro-Wilk � de que n�o h� diferen�a entre a 
# distribui��o dos dados e a distribui��o normal. O valor-p menor do que 0.05 
# nossa nos d� uma confian�a estat�stica para afirmar que as distribui��o dos 
# nossos res�duos se difere da distribui��o normal
TukeyHSD(model)
# Nenhuma medida se difere para a idade

# anova distacia para medico e idade
model<-aov(dist~categoria+Medico, pacientes)
model
summary(model)
# A partir da estat�stica F e seu valor-p acima de 0.05 temos 
# embasamento estat�stico para afirmar com grande confian�a que as m�dias de 
# distancia dos pacientes  n�o se difere entre a idade dos pacientes mas se 
# difere para medico.
shapiro.test(resid(model))
# A hip�tese nula do Teste de Shapiro-Wilk � de que n�o h� diferen�a entre a 
# nossa distribui��o dos dados e a distribui��o normal. O valor-p menor do que  
# 0.05 nos d� uma confian�a estat�stica para afirmar que as distribui��o dos  
# nossos res�duos se difere da distribui��o normal
TukeyHSD(model)
# Nenhuma medida se difere para a idade
# as medias na� se diferem em ,b-a,d-c,e-c,f-c,g-c,e-d,f-d,g-d,f-e,g-e
# Kruskal Wallis
kruskal.test(pacientes$dist,pacientes$Medico)
#Existe evid�ncias para rejeitar H0 , ou seja, h�
#evid�ncias de que os medicos apresentam diferen�as eentre as distancias.
kruskal.test(pacientes$dist,pacientes$categoria)
#Existe evid�ncias para rejeitar H0 , ou seja, h�
#evid�ncias de que as categorias de idade apresentam 
# diferen�as eentre as distancias.


# teste de Nemeyni
posthoc.kruskal.nemenyi.test(pacientes$dist~pacientes$Medico)
# existe diferen�a entre a-b,a-c,a-d,a-e,a-f,a-g,b-c,b-d,b-e,b-f,b-g,c-f,e-f,f-g
posthoc.kruskal.nemenyi.test(pacientes$dist~pacientes$categoria)
# N�o existe diferen�a

library(FSA)

a <- dunnTest(pacientes$dist~pacientes$Medico)

a[[3]]

medias <- pacientes %>% group_by(Medico) %>% 
  summarise(media=mean(dist))

medias[order(medias[,2], decreasing = T),]

# compra��o com dunnTest

# medico A: A
# medico B: A
# medico G: B
# medico C: B
# medico D: BC
# medico E: BC
# medico F: C
