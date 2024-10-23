# Trabalho 3 ME918

## API para Regressão Linear

Esta API foi desenvolvida utilizando o pacote **Plumber** em R, permitindo realizar operações de regressão linear e manipulação de dados através de rotas HTTP.

## Rotas

-   `/dados`: Retorna o conjunto de dados em formato CSV.
-   `/novoregistro`: Adiciona um novo registro ao conjunto de dados.
-   `/modificar`: Modifica um registro existente no conjunto de dados.
-   `/deletar`: Remove um registro do conjunto de dados.
-   `/predicao`:Realiza a predição dos valores de `y` com base nos valores fornecidos de `x` e `grupo`.
-   `/grafico`: Gera um gráfico de dispersão com a linha de regressão.
-   `/estimativasJson`: Retorna as estimativas dos parâmetros da regressão em formato JSON.
-   `/residuosJson`: Retorna todos os resíduos do modelo de regressão em formato JSON.
-   `/grafico_residuos`: Gera um gráfico dos resíduos do modelo.
-   `/significancia`: Retorna informações sobre a significância estatística dos parâmetros da regressão.

### 1. Obter Dados

-   **Método:** `GET`
-   **Rota:** `/dados`

### 2. Inserir Novo Registro

-   **Método:** `POST`
-   **Rota:** `/novoregistro`
-   **Parâmetros:**
    -   `x`: Valor do preditor (numérico).
    -   `grupo`: Grupo (A, B ou C).
    -   `y`: Valor da resposta (numérico).

### 3. Modificar um Registro

-   **Método:** `PUT`
-   **Rota:** `/modificar`
-   **Parâmetros:**
    -   `id`: Número da linha a ser modificada.
    -   `x`: Novo valor do preditor (numérico).
    -   `grupo`: Novo valor do grupo (A, B ou C).
    -   `y`: Novo valor da resposta (numérico).

### 4. Deletar um Registro

-   **Método:** `DELETE`
-   **Rota:** `/deletar`
-   **Parâmetros:**
    -   `id`: Número da linha a ser deletada.

### 5. Predição de Valores

-   **Método:** `GET`
-   **Rota:** `/predicao`
-   **Parâmetros:**
    -   `x`: Valores de `x`, no formato `[x1, x2, ...]`.
    -   `grupo`: Grupo das variáveis, no formato `[G1, G2, ...]`.

### 6. Gráfico de Regressão

-   **Método:** `GET`
-   **Rota:** `/grafico`

### 7. Estimativas dos Parâmetros da Regressão

-   **Método:** `GET`
-   **Rota:** `/estimativasJson`

### 8. Resíduos do Modelo

-   **Método:** `GET`
-   **Rota:** `/residuosJson`

### 9. Gráfico de Resíduos

-   **Método:** `GET`
-   **Rota:** `/grafico_residuos`

### 10. Significância Estatística dos Parâmetros

-   **Método:** `GET`
-   **Rota:** `/significancia`
-   **Parâmetros:**
    -   `alpha`: Nível de significância (default é 0.05).

## Dependências

A API utiliza as seguintes bibliotecas R: - `plumber` - `dplyr` - `ggplot2` - `stringr` - `jsonlite` - `lubridate` - `readr`

## Instalação

1.  Instale as dependências necessárias:

```{r}
install.packages(c("plumber", "dplyr", "ggplot2", "stringr", "jsonlite", "lubridate", "readr"))
```

2.  Salve o código da API em um arquivo, por exemplo, `plumber.R`.

3.  Inicie a API:

```{r}
 plumber::plumb(file='plumber.R')$run()
```

## Exemplo
