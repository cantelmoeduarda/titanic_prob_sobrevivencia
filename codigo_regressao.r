options(scipen = 5) # para evitar notação científica

  install.packages('wooldridge')   
  install.packages('readxl')      
  install.packages('tidyverse')    
  install.packages('clipr')
  install.packages( "stargazer")
  install.packages('lmtest')
  install.packages('sandwich')
  install.packages('coeftest')
  install.packages("ggplot2")

  library(wooldridge)
  library(readxl)
  library(tidyverse)
  library(clipr)
  library(stargazer)
  library('coeftest')
  library(wooldridge)
  library(lmtest)
  library(sandwich)
  library(stargazer)
  library(ggplot2)


#####################################################################
#Diretório
setwd("C:/Users/cante/Downloads")
cbo_mg_sp <- read.csv2("cbo_mg_sp2.csv")

# transformando em numeric caso as variáveis tenham ido em character

rais_cbo_final$mulher <- as.numeric(gsub("\\.", "", rais_cbo_final$mulher)) 
rais_cbo_final$cor <- as.numeric(gsub("\\.", "", rais_cbo_final$cor))
rais_cbo_final$log_Sal <- as.numeric(gsub(",", ".", rais_cbo_final$log_Sal))
# tirando o NA e colocando 0 
rais_cbo_final[is.na(rais_cbo_final)] = 0

#####################################################################
#Calculando medias, medianas e máximos 

#Media
cbo_mg_sp %>%
  group_by(mulher)%>%  #### o %>% indica que vamos fazer mudan?as
  summarize(Media_sexo=mean(valor_remuneracao_dezembro))#media_sexo

cbo_mg_sp %>%
  group_by(raca_cor)%>%  
  summarize(Media=mean(valor_remuneracao_dezembro))#media_cor

cbo_mg_sp %>%
  group_by(mulher,raca_cor)%>%  
  summarize(Media=mean(valor_remuneracao_dezembro))#media_sexo_cor

#MEDIANA
cbo_mg_sp %>%
  group_by(mulher)%>%  
  summarize(mediana=median(valor_remuneracao_dezembro))#mediana_sexo

cbo_mg_sp %>%
  group_by(raca_cor)%>%  
  summarize(mediana=median(valor_remuneracao_dezembro))#mediana_cor

cbo_mg_sp %>%
  group_by(mulher,raca_cor)%>%  
  summarize(mediana=median(valor_remuneracao_dezembro))#mediana_sexo_cor

#Máximo
cbo_mg_sp %>%
  group_by(mulher)%>%  
  summarize(valor_max=max(valor_remuneracao_dezembro))#valor_max_sexo

cbo_mg_sp %>%
  group_by(raca_cor)%>%  
  summarize(valor_max=max(valor_remuneracao_dezembro))#valor_max_cor

cbo_mg_sp %>%
  group_by(mulher,cor)%>%  
  summarize(valor_max=max(valor_remuneracao_dezembro))#valor_max_sexo_cor

#Por totais

mean(cbo_mg_sp$log_Sal)# media salarios total, mas em log --> TROCAR PRA REMUNERA??O
median(cbo_mg_sp$valor_remuneracao_dezembro)#mediana rem total
max(cbo_mg_sp$valor_remuneracao_dezembro)#maximo rem total

# Para os estados
cbo_mg_sp %>%
  group_by(sp)%>%  
  summarize(Media_estado=mean(valor_remuneracao_dezembro))
cbo_mg_sp %>%
  group_by(mulher,sp)%>%  
  summarize(Media_estado_sexo=mean(valor_remuneracao_dezembro))
cbo_mg_sp %>%
  group_by(mulher,raca_cor,sp)%>%  
  summarize(Media_estado_sexo_raca=mean(valor_remuneracao_dezembro))

cbo_mg_sp %>%
  group_by(sp)%>%  
  summarize(Mediana_estado=median(valor_remuneracao_dezembro))
cbo_mg_sp %>%
  group_by(mulher,sp)%>%  
  summarize(Mediana_estado_sexo=median(valor_remuneracao_dezembro))
cbo_mg_sp %>%
  group_by(mulher,raca_cor,sp)%>%  
  summarize(Mediana_estado_sexo_raca=median(valor_remuneracao_dezembro))

cbo_mg_sp %>%
  group_by(sp)%>%  
  summarize(valor_max_estado=max(valor_remuneracao_dezembro))
cbo_mg_sp %>%
  group_by(mulher,sp)%>%  
  summarize(valor_max_estado_sexo=max(valor_remuneracao_dezembro))
cbo_mg_sp %>%
  group_by(mulher,raca_cor,sp)%>%  
  summarize(valor_max_estado_sexo_raca=max(valor_remuneracao_dezembro))

#####################################################################
# Gráficos 

Media_Salarial_GenRaca <- data.frame(
  Genero_e_raca =c(1="Homem Branco",2="Mulher Branca",3="Homem Preto",4="Mulher Preta") ,  
  Media_salarial =c(11.914,8.151,7.507,4.988))
print(Media_Salarial_GenRaca)
ggplot(Media_Salarial_GenRaca, aes(x=Genero_e_raca, y=Media_salarial, fill= Genero_e_raca)) + 
  geom_bar(stat = "identity", width=0.4)

#####################################################################
# Preparando para a regressão 

# Fazendo novas dummies a partir das que já temos na tebela anteriormente tratada

cbo_mg_sp["SEXO_UF"] <- paste(cbo_mg_sp$mulher, cbo_mg_sp$raca_cor,cbo_mg_sp$sp)
view(cbo_mg_sp)

cbo_mg_sp["homem_branco_sp"] <- case_when(cbo_mg_sp["SEXO_UF"] == '0 0 1' ~ 1, TRUE ~ 0)
cbo_mg_sp["homem_preto_sp"] <- case_when(cbo_mg_sp["SEXO_UF"] == '0 1 1' ~ 1, TRUE ~ 0)
cbo_mg_sp["mulher_branca_sp"] <- case_when(cbo_mg_sp["SEXO_UF"] == '1 0 1' ~ 1, TRUE ~ 0)
cbo_mg_sp["mulher_preta_sp"] <- case_when(cbo_mg_sp["SEXO_UF"] == '1 1 1' ~ 1, TRUE ~ 0)

cbo_mg_sp["homem_branco_mg"] <- case_when(cbo_mg_sp["SEXO_UF"] == '0 0 0' ~ 1, TRUE ~ 0)
cbo_mg_sp["homem_preto_mg"] <- case_when(cbo_mg_sp["SEXO_UF"] == '0 1 0' ~ 1, TRUE ~ 0)
cbo_mg_sp["mulher_branca_mg"] <- case_when(cbo_mg_sp["SEXO_UF"] == '1 0 0' ~ 1, TRUE ~ 0)
cbo_mg_sp["mulher_preta_mg"] <- case_when(cbo_mg_sp["SEXO_UF"] == '1 1 0' ~ 1, TRUE ~ 0)

# Incluindo coluna Grau de intrução e fazendo uma dummy

cbo_mg_sp["Grau_instrucao"]<- paste (cbo_mg_sp$graduacao, cbo_mg_sp$mestrado , cbo_mg_sp$doutorado)
cbo_mg_sp["grau_instrucao"] <- case_when(cbo_mg_sp["Grau_instrucao"] == '1 0 0' ~ 0, TRUE ~ 1)


#####################################################################
# Regressões

Salarios_economistas <- lm(log_Sal ~ mulher_preta_sp+homem_preto_mg+mulher_branca_sp+
                  homem_branco_sp+mulher_branca_mg+mulher_preta_mg+
                  idade+idade2+tempo_emprego+Tempo_emprego2+grau_instrucao
                  +capital, data = cbo_mg_sp)
summary(Salarios_economistas)

#####################################################################
# Stargazer -> criando uma tabela 


reg1 <- lm(log_Sal~mulher_preta_sp+homem_preto_mg+mulher_branca_sp+
             homem_branco_sp+mulher_branca_mg+mulher_preta_mg,data= cbo_mg_sp)
reg2 <- lm(log_Sal~mulher_preta_sp+homem_preto_mg+mulher_branca_sp+
             homem_branco_sp+mulher_branca_mg+mulher_preta_mg+
             idade+idade2,data=cbo_mg_sp)
reg3 <- lm(log_Sal~mulher_preta_sp+homem_preto_mg+mulher_branca_sp+
             homem_branco_sp+mulher_branca_mg+mulher_preta_mg+
             idade+idade2+tempo_emprego+Tempo_emprego2, data = cbo_mg_sp)
reg4 <- lm(log_Sal~mulher_preta_sp+homem_preto_mg+mulher_branca_sp+
             homem_branco_sp+mulher_branca_mg+mulher_preta_mg+
             idade+idade2+tempo_emprego+Tempo_emprego2+grau_instrucao, data = cbo_mg_sp)
Salario_economistas <- lm(log_Sal~mulher_preta_sp+homem_preto_mg+mulher_branca_sp+
                            homem_branco_sp+mulher_branca_mg+mulher_preta_mg+
                            idade+idade2+tempo_emprego+Tempo_emprego2+grau_instrucao+capital, data= cbo_mg_sp)
summary(Salario_economistas)


stargazer(reg1, reg2,reg3,reg4,Salario_economistas,
          digits = 1,
          type = "text",
          out = "stargazer1.cvs",
          header = TRUE,
          title = "Resultado das regressões",
          align=FALSE,
          covariate.labels = c("Mulher preta de SP","Homem preto de MG", "Mulher branca de SP",
                               "Homem branco de SP","Mulher branca de MG",
                               "Mulher preta de MG", "Idade", "Idade²", "Tempo de emprego", "Tempo de emprego²","Grau de instrucão", "Capital"))






#####################################################################
# testes

# teste t robusto 
coeftest(regressao, vcov=vcovHC(regressao, type = "HC0")) #test t robusto 

#estatistica f usual

#regressao restrita, sem grau_instrucao e idade
regressao_sem_idade_intrucao <- lm(log_Sal ~ mulher_preta_sp+homem_preto_mg+mulher_branca_sp+
                                     homem_branco_sp+mulher_branca_mg+homem_preto_mg+mulher_preta_mg+idade2+tempo_emprego+Tempo_emprego2, data = cbo_mg_sp)


anova(regressao,regressao_sem_idade_intrucao) #p-valor super baixo, rej a hip. nula de que eles conj. n sao importantes
# agora sem idade² e tempo_emprego²
regressao_sem_idade2_tempo2<- lm(log_Sal ~ mulher_preta_sp+homem_preto_mg+mulher_branca_sp+
                                   homem_branco_sp+mulher_branca_mg+homem_preto_mg+mulher_preta_mg+
                                   idade+tempo_emprego+grau_instrucao, data = cbo_mg_sp)
anova(regressao,regressao_sem_idade2_tempo2) # mesma coisa

#estatistica f robusta 
waldtest(regressao, regressao_sem_idade_intrucao,
         vcov = vcovHC(regressao, type = "HC0"))
waldtest(regressao, regressao_sem_idade2_tempo2,
         vcov = vcovHC(regressao, type = "HC0"))
######teste bp 
#pegando o resíduo² da eq. 1 
res_eq1 <- (summary(regressao)$residual)^2

#usando o residuo contra as var. explicativas do mod. da eq. estrutural.
lm_eq1_cont <- lm(res_eq1~mulher_preta_sp+homem_preto_mg+mulher_branca_sp+
                    homem_branco_sp+mulher_branca_mg+homem_preto_mg+mulher_preta_mg+
                    idade+idade2+tempo_emprego+Tempo_emprego2+grau_instrucao,data = cbo_mg_sp)

summary(lm_eq1_cont)
