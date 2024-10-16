library(plumber)
library(dplyr)

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
  df
}

#* Rota para inserir um novo registro
#* @param x valor do preditor (numerérico)
#* @param grupo grupo (A, B ou C)
#* @param y valor da resposta (numérico)
#* @serializer csv
#* @post /novoregistro
function(x, grupo, y) {
  readr::read_csv(df, file = "dados.csv")
  if (!grupo %in% c("A", "B", "C")) {
    return(list(error = "Grupo deve ser A, B ou C"))
  }
 df <- rbind(df, data.frame(x = as.numeric(x), 
                          grupo = grupo,
                          y = as.numeric(y),
                          momento_registro = lubridate::now(tzone="America/Sao_Paulo")))

  modelo <- lm(y ~ x + grupo, data = df) 
  
  # Salva os dados atualizados
  readr::write_csv(df, "dados.csv")
  return(print("Registro inserido com sucesso"))
}



