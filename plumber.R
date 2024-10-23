library(plumber)
library(dplyr)
library(ggplot2) 
library(stringr)
library(jsonlite)

#* @apiTitle API para Regressão Linear
ra <- 217505
  set.seed(ra)
b0 <- runif(1, -2, 2); b1 <- runif(1, -2, 2)
bB <- 2; bC <- 3
n <- 25
x <- rpois(n, lambda = 4) + runif(n, -3, 3)
grupo <- sample(LETTERS[1:3], size = n, replace = TRUE)
y <- rnorm(n, mean = b0 + b1*x + bB*(grupo=="B") + bC*(grupo=="C"), sd = 2)
df <- data.frame(x = x, grupo = grupo, y = y,
                 momento_registro = lubridate::now(tzone="America/Sao_Paulo"))
readr::write_csv(df, file = "dados.csv")

modelo <- lm(y ~ x + grupo, data = df)


#* Rota para obter os dados
#* @get /dados
#* @serializer csv
function() {
  df = readr::read_csv('dados.csv')
  return(df)
}

#* Rota para inserir um novo registro
#* @param x valor do preditor (numérico)
#* @param grupo grupo (A, B ou C)
#* @param y valor da resposta (numérico)
#* @post /novoregistro
function(x, grupo, y) {
  grupo = toupper(grupo)
  df = readr::read_csv("dados.csv")
  if (!grupo %in% LETTERS[1:3]) {
    return(list(error = "Grupo deve ser A, B ou C"))
  }
  if(is.na(as.numeric(x))|is.na(as.numeric(y))) return(list(error = "x e y devem ser numéricas"))
  df <- rbind(df, data.frame(x = as.numeric(x), 
                          grupo = grupo,
                          y = as.numeric(y),
                          momento_registro = lubridate::now(tzone="America/Sao_Paulo")))

  modelo <- lm(y ~ x + grupo, data = df) 
  
  # Salva os dados atualizados
  readr::write_csv(df, "dados.csv")
  return(print("Registro inserido com sucesso"))
}

#* Rota para modificar um registro
#* @param id número da linha a ser modificada
#* @param x novo valor do preditor (numérico)
#* @param grupo novo valor do grupo (A, B ou C)
#* @param y novo valor da resposta (numérico)
#* @put /modificar
function(id, x, grupo, y) {
  if (!grupo %in% LETTERS[1:3]) {
    return(list(error = "Grupo deve ser A, B ou C"))
  }
  if(!(is.numeric(x)&is.numeric(y))) return(list(error = "x e y devem ser numéricas"))
  df = readr::read_csv(file = "dados.csv")
  # Modifica o registro correspondente
  df[id,] = data.frame(x, grupo, y, momento_registro = lubridate::now(tzone="America/Sao_Paulo"))
  # Atualiza o modelo
  modelo <- lm(y ~ x + grupo, data = df)
  
  # Salva os dados atualizados
  readr::write_csv(df, "dados.csv")
  
  return(print("Registro modificado com sucesso"))
}

#* Rota para deletar um registro
#* @param id número da linha a ser deletada
#* @put /deletar
function(id) {
  df = readr::read_csv(file = "dados.csv")
  df <- df[-as.numeric(id),]
  
  # Salva os dados atualizados
  readr::write_csv(df, "dados.csv")
  
  return(print("Registro deletado com sucesso"))
}

#* Rota para predição de valores
#* @serializer json
#* @param x Valores de x, no formato [x1, x2, ...]
#* @param grupo Grupo das variáveis, no formato [G1, G2, ...]
#* @get /predicao
function(x, grupo){
  modelo <- lm(y ~ x + grupo, data = df)
  print(c(x, grupo))
  x = as.numeric(fromJSON(x))
  grupo=fromJSON(str_replace_all(grupo, c(','='","', '\\['='["', '\\]'='"]','\n'='')))
  predicao = predict(modelo, data.frame(x, grupo))
  return(valores_preditos = predicao)
}

#* Gráfico
#* @get /grafico
#* @serializer png
function() {
  df = readr::read_csv(file = "dados.csv")
  grafico<-ggplot(data = df, aes(x = x, y = y, colour = grupo)) + 
    geom_point()+
    geom_smooth(method = "lm", se = FALSE) +  
    labs(title = "Gráfico de Regressão Linear",
         x = "X",
         y = "Y")+
    theme_bw()
  return(print(grafico))
}

#* Rota para obter as estimativas dos parâmetros da regressão
#* @get /estimativasJson
#* @serializer json
function() {
  df = readr::read_csv(file = "dados.csv")
  modelo <- lm(y ~ x + grupo, data = df)
  estimativas <- summary(modelo)$coefficients[,1]
  return(as.data.frame(estimativas))
}

#* Rota para obter todos os resíduos do modelo de regressão em formato JSON
#* @get /residuosJson
#* @serializer json
function() {
  df = readr::read_csv(file = "dados.csv")
  modelo <- lm(y ~ x + grupo, data = df)
  residuos <- modelo$residuals
  return(residuos)
}

#* Rota para obter um gráfico de resíduos
#* @get /grafico_residuos
#* @serializer png
function() {
  df = readr::read_csv(file = "dados.csv")
  modelo <- lm(y ~ x + grupo, data = df)
  residuos <- modelo$residuals
  df_residuos <- data.frame(x = df$y, residuos = residuos)
  
  grafico_residuos <- ggplot(data = df_residuos, aes(x = x, y = residuos)) + 
    geom_point() + 
    geom_hline(yintercept = 0, linetype = "dashed", color = "red")  +
    theme_bw() +
    labs(title = "Gráfico de Resíduos",
         x = "Valores observados",
         y = "Resíduos")
  return(print(grafico_residuos))
}


#* Rota para obter informações sobre a significância estatística dos parâmetros
#* @param alpha Nível de significância 
#* @get /significancia
#* @serializer json
function(alpha = 0.05) {
  df = readr::read_csv(file = "dados.csv")
  modelo <- lm(y ~ x + grupo, data = df)
  resumo <- summary(modelo)
  parametros <- as.data.frame(resumo$coefficients)

  df_sig <- data.frame(parametros = rownames(parametros), 
                      p_valor = parametros[, 4],
                      significativo = ifelse(parametros[, 4] < alpha, "significativo", "não significativo"))
  
  # Retornar os resultados como JSON
  return(df_sig)
}

