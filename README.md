# 🏎️ F1 Knowledge Engine

> **Disciplina:** Lógica e Matemática Discreta — 2026/1  
> **Autor:** Gabriel Martins Rosa  
> **Entrega:** 03/05/2026

---

## 📌 Visão Geral

O **F1 Knowledge Engine** é um sistema de inferência lógica construído sobre dados históricos reais da **Fórmula 1**. O projeto aplica conceitos de **Lógica de Primeira Ordem** para responder perguntas complexas sobre pilotos, equipes e temporadas por meio de **programação lógica em Prolog**.

A arquitetura integra três camadas:

- **ETL em Python** — coleta, limpeza e transformação dos dados brutos para o formato Prolog
- **Base de Conhecimento** — predicados gerados automaticamente a partir do dataset real (Kaggle)
- **Motor de Inferência** — regras e queries em Prolog que permitem raciocínio declarativo sobre os dados

---

## 📂 Estrutura do Projeto

```
KNOWLEDGE-ENGINE/
│
├── datasets/                        # Dataset original do Kaggle
│   ├── circuits.csv
│   ├── constructor_results.csv
│   ├── constructor_standings.csv
│   ├── constructors.csv
│   ├── driver_standings.csv
│   ├── drivers.csv
│   ├── lap_times.csv
│   ├── pit_stops.csv
│   ├── qualifying.csv
│   ├── races.csv
│   ├── results.csv
│   ├── seasons.csv
│   ├── sprint_results.csv
│   └── status.csv
│
├── notebooks/
│   └── etl.ipynb                    # Pipeline de transformação dos dados
│
├── prolog/
│   ├── base.pl                      # Fatos gerados automaticamente (base de conhecimento)
│   └── regras.pl                    # Regras de inferência e queries
│
├── install_dataset.py               # Script para gerar base.pl a partir do dataset
├── requirements.txt
├── .gitignore
└── README.md
```

---

## ⚙️ Modelagem da Base de Conhecimento

Cada resultado de corrida é representado por um único predicado de aridade 8:

```prolog
corrida(Piloto, Equipe, GP, Largada, Posicao, Pontos, Ano, Nacionalidade).
```

### Exemplo de fato gerado

```prolog
corrida(verstappen, red_bull, bahrain_grand_prix, 1, 1, 25.0, 2024, dutch).
corrida(hamilton,  mercedes, australian_grand_prix, 1, 2, 18.0, 2018, british).
corrida(vettel,    ferrari,  australian_grand_prix, 3, 1, 25.0, 2018, german).
```

O dataset cobre **temporadas de 2018 em diante**, com dados reais extraídos do [Formula 1 World Championship Dataset](https://www.kaggle.com/) (Kaggle).

---

## 🔄 Pipeline ETL (Python)

O notebook `etl.ipynb` e o script `install_dataset.py` realizam os seguintes passos:

### 1. Leitura e junção dos CSVs

```python
results      = pd.read_csv("../datasets/results.csv")
drivers      = pd.read_csv("../datasets/drivers.csv")
constructors = pd.read_csv("../datasets/constructors.csv")
races        = pd.read_csv("../datasets/races.csv")

df = results.merge(drivers, on="driverId")
df = df.merge(constructors, on="constructorId")
df = df.merge(races, on="raceId")
```

### 2. Renomeação e seleção de colunas

```python
df = df.rename(columns={
    "surname":        "piloto",
    "name_x":         "equipe",
    "name_y":         "corrida",
    "grid":           "largada",
    "position":       "posicao",
    "points":         "pontos",
    "year":           "ano",
    "nationality_x":  "nacionalidade"
})

df_final = df[["piloto", "equipe", "corrida", "largada",
               "posicao", "pontos", "ano", "nacionalidade"]]
```

### 3. Filtragem e limpeza

```python
# Apenas temporadas a partir de 2018
df_final = df_final[df_final["ano"] >= 2018]

# Substituição de posições inválidas ("\\N") por 0
df_final["posicao"] = df_final["posicao"].replace("\\N", 0)
```

### 4. Normalização de strings para Prolog

Todos os campos de texto são convertidos para **snake_case**, minúsculo e sem acentos, para atender às restrições de átomos em Prolog:

```python
def clean(text):
    text = str(text).lower().replace(" ", "_")
    text = unicodedata.normalize('NFKD', text)
    text = text.encode('ascii', 'ignore').decode('ascii')
    if text.endswith("_"):
        text = text[:-1]
    return text

for col in ["piloto", "equipe", "corrida", "nacionalidade"]:
    df_final[col] = df_final[col].apply(clean)

# Prefixo "gp_" para corridas que começam com número
df_final["corrida"] = df_final["corrida"].apply(
    lambda x: "gp_" + x if x[0].isdigit() else x
)
```

### 5. Geração da base Prolog

```python
with open("../prolog/base.pl", "w") as f:
    for _, row in df_final.iterrows():
        linha = (
            f"corrida({row['piloto']}, {row['equipe']}, {row['corrida']}, "
            f"{row['largada']}, {row['posicao']}, {row['pontos']}, "
            f"{row['ano']}, {row['nacionalidade']}).\n"
        )
        f.write(linha)
```

---

## 🧠 Regras Implementadas (`regras.pl`)

### Desempenho individual

| Regra | Descrição |
|---|---|
| `vitoria(Piloto)` | Verifica se o piloto possui ao menos uma vitória |
| `total_vitorias(Piloto, Total)` | Conta o número total de vitórias |
| `pontos_piloto(Piloto, Total)` | Soma todos os pontos acumulados pelo piloto |

### Análise de largada vs. chegada

| Regra | Descrição |
|---|---|
| `ganho_posicao(Piloto, Ganho)` | Posições ganhas em uma corrida específica (`Largada - Posicao`) |
| `total_ganho(Piloto, Total)` | Soma total de posições ganhas na carreira |
| `media_ganho(Piloto, Media)` | Média de posições ganhas por corrida |
| `melhor_ganho(Piloto, Max)` | Maior ganho de posições em uma única corrida |
| `media_posicao(Piloto, Media)` | Média de posição final (excluindo DNFs) |

### Estatísticas por nacionalidade

| Regra | Descrição |
|---|---|
| `pontos_nacionalidade(Nac, Total)` | Soma de pontos por nacionalidade |

### Rankings

| Regra | Descrição |
|---|---|
| `ranking_pilotos(Lista)` | Ranking global de pilotos ordenado por pontos (decrescente) |
| `melhor_piloto(Piloto)` | Piloto com maior pontuação histórica |

### Campeões por temporada

| Regra | Descrição |
|---|---|
| `campeao_ano(Ano, Piloto)` | Campeão de pilotos de uma temporada específica |
| `campeao_construtor(Ano, Equipe)` | Equipe com mais pontos em uma temporada |
| `todos_campeoes` | Lista todos os campeões ano a ano |

---

## ▶️ Como Executar

### Pré-requisitos

- Python 3.8+
- [SWI-Prolog](https://www.swi-prolog.org/) instalado

### 1. Instalar dependências Python

```bash
pip install -r requirements.txt
```

### 2. Gerar a base de conhecimento Prolog

```bash
python install_dataset.py
```

Isso criará o arquivo `prolog/base.pl` com todos os fatos extraídos do dataset.

### 3. Carregar no SWI-Prolog

```prolog
?- consult('prolog/base.pl').
?- consult('prolog/regras.pl').
```

Ou via linha de comando:

```bash
swipl -l prolog/base.pl -l prolog/regras.pl
```

### Alternativa online

Você pode usar o [SWISH — SWI-Prolog online](https://swish.swi-prolog.org/) copiando o conteúdo de `base.pl` e `regras.pl` nas áreas **Program** e realizando as queries na área **Query**.

---

## 🧪 Queries de Exemplo

### Consultas básicas (Pergunta C)

```prolog
% Verificar se um piloto já venceu alguma corrida
?- vitoria(verstappen).

% Total de vitórias de um piloto
?- total_vitorias(verstappen, T).

% Total de pontos acumulados
?- pontos_piloto(hamilton, T).
```

### Análise de performance (Pergunta B — sofisticada)

```prolog
% Média de posição final do piloto (excluindo DNFs)
?- media_posicao(verstappen, M).

% Maior ganho de posições em uma única corrida
?- melhor_ganho(alonso, G).

% Média de posições ganhas por corrida
?- media_ganho(hamilton, M).
```

### Rankings e campeões (Pergunta A — sofisticada)

```prolog
% Ranking global de todos os pilotos por pontos
?- ranking_pilotos(L).

% Piloto com mais pontos históricos (2018–)
?- melhor_piloto(P).

% Campeão de uma temporada específica
?- campeao_ano(2021, P).

% Melhor equipe construtora de uma temporada
?- campeao_construtor(2022, E).

% Listar todos os campeões ano a ano
?- todos_campeoes.
```

### Consulta por nacionalidade

```prolog
% Total de pontos somados por nacionalidade
?- pontos_nacionalidade(dutch, T).
?- pontos_nacionalidade(british, T).
```

---

## 📊 Fonte dos Dados

**Dataset:** [Formula 1 World Championship (1950–2024)](https://www.kaggle.com/) — Kaggle  
**Cobertura utilizada:** Temporadas 2018 a 2024  
**Predicado central:** `corrida/8` com campos de piloto, equipe, GP, largada, posição, pontos, ano e nacionalidade

---

## 🏁 Conclusão

O projeto demonstra na prática como a **Programação Lógica** e a **Lógica de Primeira Ordem** podem ser aplicadas para construir um sistema capaz de **extrair conhecimento** de grandes volumes de dados reais.

A abordagem declarativa do Prolog permite formular perguntas complexas — como rankings, médias e determinação de campeões — de forma concisa e expressiva, evidenciando a diferença fundamental entre o paradigma lógico e o procedural.

---

## 📌 Melhorias Futuras

- Interface web para consultas interativas
- Expansão para todas as temporadas do dataset (1950–presente)
- Dashboards de visualização integrados
- Modelos preditivos com Machine Learning para resultados futuros
