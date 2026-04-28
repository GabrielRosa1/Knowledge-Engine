<div align="center">

# 🏎️ F1 Knowledge Engine

<img src="https://img.shields.io/badge/Linguagem-Prolog-cc0000?style=for-the-badge" />
<img src="https://img.shields.io/badge/ETL-Python-3776AB?style=for-the-badge&logo=python&logoColor=white" />
<img src="https://img.shields.io/badge/Dataset-Kaggle-20BEFF?style=for-the-badge&logo=kaggle&logoColor=white" />
<img src="https://img.shields.io/badge/Paradigma-Lógico-7B2D8B?style=for-the-badge" />
<img src="https://img.shields.io/badge/Temporadas-2018–2024-E10600?style=for-the-badge" />

<br/><br/>

> Sistema de inferência lógica sobre dados históricos reais da Fórmula 1,  
> construído com **Lógica de Primeira Ordem** e **Programação Lógica em Prolog**.

<br/>

| 👨‍💻 Autor | 📚 Disciplina | 🏫 Instituição | 📅 Entrega |
|:---:|:---:|:---:|:---:|
| **Gabriel Rosa** | Lógica e Matemática Discreta | Insper | 03/05/2026 |

</div>

---

## 📌 Visão Geral

O **F1 Knowledge Engine** aplica conceitos de **Lógica de Primeira Ordem** para responder perguntas complexas sobre pilotos, equipes e temporadas da Fórmula 1. A ideia remete aos primórdios da IA: construir uma base de conhecimento e extrair respostas por meio de **inferência declarativa**.

A arquitetura integra três camadas:

```
📦 Dataset (Kaggle)
      │
      ▼
🐍 ETL em Python  ──►  🧠 Base de Conhecimento (Prolog)  ──►  🔎 Queries & Inferência
   (etl.ipynb)                   (base.pl)                        (regras.pl)
```

- **ETL em Python** — leitura, limpeza e geração automática dos predicados Prolog
- **Base de Conhecimento** — fatos gerados a partir de 4 CSVs do Kaggle (`results`, `drivers`, `constructors`, `races`), cobrindo todas as corridas de 2018 a 2024
- **Motor de Inferência** — regras que permitem raciocinar sobre vitórias, rankings, campeões e performance

---

## 📂 Estrutura do Projeto

```
KNOWLEDGE-ENGINE/
│
├── 📁 datasets/                     # Dataset original do Kaggle
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
├── 📁 notebooks/
│   └── etl.ipynb                    # Pipeline de transformação dos dados
│
├── 📁 prolog/
│   ├── base.pl                      # Fatos gerados automaticamente
│   └── regras.pl                    # Regras de inferência e queries
│
├── install_dataset.py               # Gera base.pl a partir do dataset
├── requirements.txt
├── .gitignore
└── README.md
```

---

## ⚙️ Modelagem da Base de Conhecimento

Cada resultado de corrida é representado por um predicado de **aridade 8**:

```prolog
corrida(Piloto, Equipe, GP, Largada, Posicao, Pontos, Ano, Nacionalidade).
```

### Exemplos de fatos gerados

```prolog
corrida(verstappen, red_bull, bahrain_grand_prix,    1, 1, 25.0, 2024, dutch).
corrida(hamilton,  mercedes,  australian_grand_prix, 1, 2, 18.0, 2018, british).
corrida(vettel,    ferrari,   australian_grand_prix, 3, 1, 25.0, 2018, german).
```

---

## 🔄 Pipeline ETL

<details>
<summary><b>▶ Clique para expandir o pipeline completo</b></summary>

<br/>

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
    "surname":       "piloto",
    "name_x":        "equipe",
    "name_y":        "corrida",
    "grid":          "largada",
    "position":      "posicao",
    "points":        "pontos",
    "year":          "ano",
    "nationality_x": "nacionalidade"
})

df_final = df[["piloto","equipe","corrida","largada","posicao","pontos","ano","nacionalidade"]]
```

### 3. Filtragem e limpeza

```python
# Apenas temporadas a partir de 2018
df_final = df_final[df_final["ano"] >= 2018]

# Substituição de posições inválidas por 0
df_final["posicao"] = df_final["posicao"].replace("\\N", 0)
```

### 4. Normalização para Prolog (snake_case, sem acentos)

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

# Prefixo "gp_" para corridas que iniciam com número
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

</details>

---

## 🧠 Regras Implementadas

### 🏁 Desempenho Individual

| Predicado | Descrição |
|:---|:---|
| `vitoria(Piloto)` | Verdadeiro se o piloto possui ao menos uma vitória |
| `total_vitorias(Piloto, Total)` | Conta o número total de vitórias |
| `pontos_piloto(Piloto, Total)` | Soma todos os pontos acumulados |

### 📈 Análise Largada × Chegada

| Predicado | Descrição |
|:---|:---|
| `ganho_posicao(Piloto, Ganho)` | Posições ganhas por corrida (`Largada - Posicao`) |
| `total_ganho(Piloto, Total)` | Soma total de posições ganhas na carreira |
| `media_ganho(Piloto, Media)` | Média de posições ganhas por corrida |
| `melhor_ganho(Piloto, Max)` | Maior ganho de posições em uma única corrida |
| `media_posicao(Piloto, Media)` | Média de posição final (ignora DNFs) |

### 🌍 Estatísticas por Nacionalidade

| Predicado | Descrição |
|:---|:---|
| `pontos_nacionalidade(Nac, Total)` | Soma de pontos acumulados por nacionalidade |

### 🏆 Rankings

| Predicado | Descrição |
|:---|:---|
| `ranking_pilotos(Lista)` | Ranking global ordenado por pontos (decrescente) |
| `melhor_piloto(Piloto)` | Piloto com maior pontuação histórica |

### 🥇 Campeões por Temporada

| Predicado | Descrição |
|:---|:---|
| `campeao_ano(Ano, Piloto)` | Campeão de pilotos de uma temporada |
| `campeao_construtor(Ano, Equipe)` | Equipe campeã construtora por temporada |
| `todos_campeoes` | Lista todos os campeões ano a ano |

---

## ▶️ Como Executar

### Pré-requisitos

![Python](https://img.shields.io/badge/Python-3.8+-3776AB?logo=python&logoColor=white)
![SWI-Prolog](https://img.shields.io/badge/SWI--Prolog-9.x-cc6600)

### Passo a passo

**1. Clone o repositório**
```bash
git clone https://github.com/<seu-usuario>/knowledge-engine.git
cd knowledge-engine
```

**2. Instale as dependências Python**
```bash
pip install -r requirements.txt
```

**3. Gere a base de conhecimento Prolog**
```bash
python install_dataset.py
# → Cria prolog/base.pl com todos os fatos extraídos do dataset
```

**4. Carregue no SWI-Prolog**
```bash
# Via linha de comando
swipl -l prolog/base.pl -l prolog/regras.pl
```
```prolog
% Ou interativamente
?- consult('prolog/base.pl').
?- consult('prolog/regras.pl').
```

> 💡 **Sem SWI-Prolog instalado?** Use o [SWISH online](https://swish.swi-prolog.org/) — cole o conteúdo de `base.pl` e `regras.pl` em **Program** e execute as queries em **Query**.

---

## 🧪 Queries de Exemplo

### 🔵 Nível C — Consultas básicas (filtro direto)

```prolog
% Verificar se um piloto já venceu alguma corrida
?- vitoria(verstappen).

% Total de vitórias
?- total_vitorias(verstappen, T).

% Total de pontos acumulados
?- pontos_piloto(hamilton, T).

% Pontos somados por nacionalidade
?- pontos_nacionalidade(dutch, T).
```

### 🟡 Nível B — Análise com agregação

```prolog
% Média de posição final (excluindo DNFs)
?- media_posicao(verstappen, M).

% Maior ganho de posições em uma única corrida
?- melhor_ganho(alonso, G).

% Média de posições ganhas por corrida
?- media_ganho(hamilton, M).
```

### 🟢 Nível A — Rankings, ordenação e campeões

```prolog
% Ranking global de pilotos por pontos (decrescente)
?- ranking_pilotos(L).

% Piloto com mais pontos históricos (2018–2024)
?- melhor_piloto(P).

% Campeão de pilotos de uma temporada específica
?- campeao_ano(2021, P).

% Campeão construtor de uma temporada
?- campeao_construtor(2022, E).

% Todos os campeões, ano a ano
?- todos_campeoes.
```

---

## 📊 Fonte dos Dados

<div align="center">

| Campo | Valor |
|:---:|:---|
| **Dataset** | [Formula 1 World Championship (1950–2024)](https://www.kaggle.com/datasets/rohanrao/formula-1-world-championship-1950-2020) |
| **Plataforma** | Kaggle |
| **Cobertura utilizada** | Temporadas 2018 → 2024 |
| **Predicado central** | `corrida/8` |
| **Campos** | piloto, equipe, GP, largada, posição, pontos, ano, nacionalidade |

</div>

---

## 🏁 Conclusão

O projeto demonstra na prática como a **Programação Lógica** e a **Lógica de Primeira Ordem** podem construir sistemas capazes de **extrair conhecimento** de grandes volumes de dados reais.

A abordagem declarativa do Prolog permite formular perguntas complexas — rankings, médias, determinação de campeões — de forma concisa, evidenciando a diferença fundamental entre o paradigma lógico e o procedural.

---
</div>
