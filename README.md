# 🏎️ Projeto F1 Knowledge Engine

## 🎓 Disciplina

**Lógica e Matemática Discreta - 2026/1**
**Projeto: Knowledge Engine**

## 👨‍💻 Autor

**Gabriel Martins Rosa**

---

## 📌 Descrição

Este projeto tem como objetivo construir um **mecanismo de inferência baseado em Lógica de Primeira Ordem**, utilizando dados históricos da Fórmula 1.

A proposta segue o conceito clássico de sistemas de IA baseados em regras, onde uma **base de conhecimento** é construída e consultas são realizadas por meio de **inferência lógica em Prolog**.

O projeto integra:

* 📊 **Engenharia de Dados (ETL em Python)**
* 🧠 **Programação Lógica (Prolog)**
* 📈 **Análise de dados reais (Fórmula 1)**

O sistema permite responder perguntas complexas sobre pilotos, desempenho, rankings e campeões ao longo dos anos.

---

## 📂 Estrutura do Projeto

```
KNOWLEDGE-ENGINE/
│
├── datasets/                # Base de dados original (Kaggle)
│
├── prolog/
│   ├── base.pl              # Fatos (base de conhecimento)
│   └── regras.pl            # Regras e queries
│
├── notebooks/
│   └── etl.ipynb            # Tratamento e transformação dos dados
│
├── install_dataset.py       # Script de geração da base Prolog
├── requirements.txt
├── .gitignore
└── README.md
```

---

## ⚙️ Modelagem da Base de Conhecimento

Os dados foram convertidos para o seguinte predicado em Prolog:

```
corrida(Piloto, Equipe, GP, Largada, Posicao, Pontos, Ano, Nacionalidade).
```

### Exemplo:

```
corrida(verstappen, red_bull, bahrain_grand_prix, 1, 1, 25.0, 2024, dutch).
```

Cada fato representa o resultado de um piloto em uma corrida.

---

## 🧠 Regras Implementadas

### 🏁 Desempenho de Pilotos

* `vitoria(Piloto)` → verifica vitórias
* `total_vitorias(Piloto, Total)` → total de vitórias
* `pontos_piloto(Piloto, Total)` → soma total de pontos

---

### 📈 Análise de Performance

* `ganho_posicao(Piloto, Ganho)` → posições ganhas por corrida
* `total_ganho(Piloto, Total)` → ganho total
* `media_ganho(Piloto, Media)` → média de ganho
* `melhor_ganho(Piloto, Max)` → maior ganho em uma corrida
* `media_posicao(Piloto, Media)` → média de posição final

---

### 🌍 Estatísticas

* `pontos_nacionalidade(Nac, Total)` → soma de pontos por nacionalidade

---

### 🏆 Rankings

* `ranking_pilotos(Lista)` → ranking global por pontos
* `melhor_piloto(Piloto)` → piloto com maior pontuação

---

### 🥇 Campeões

* `campeao_ano(Ano, Piloto)` → campeão de cada temporada
* `campeao_construtor(Ano, Equipe)` → melhor equipe por ano
* `todos_campeoes` → lista todos os campeões

---

## ▶️ Como Executar

### 1. Instalar dependências

```
pip install -r requirements.txt
```

### 2. Gerar base Prolog

```
python install_dataset.py
```

### 3. Executar no SWI-Prolog

```
consult('prolog/base.pl').
consult('prolog/regras.pl').
```

---

## 🧪 Exemplos de Queries

### 🔎 Básicas

```
vitoria(verstappen).
total_vitorias(verstappen, T).
pontos_piloto(hamilton, T).
```

### 📊 Análise

```
media_posicao(verstappen, M).
melhor_ganho(verstappen, G).
```

### 🏆 Ranking

```
ranking_pilotos(L).
melhor_piloto(P).
```

### 🥇 Campeões

```
campeao_ano(2021, P).
campeao_construtor(2022, E).
todos_campeoes.
```

---

## 📊 Fonte dos Dados

Dataset público do Kaggle:

**Formula 1 World Championship Dataset**

---

## 🚀 Diferenciais do Projeto

✔ Uso de **dados reais históricos**
✔ Integração entre **Python e Prolog**
✔ Aplicação de **Lógica de Primeira Ordem**
✔ Queries com **agregação, ordenação e inferência**
✔ Estrutura reprodutível e organizada

---

## 📌 Possíveis Melhorias Futuras

* Interface visual para consultas
* API para integração externa
* Dashboards interativos
* Modelos de previsão com Machine Learning

---

## 🏁 Conclusão

Este projeto demonstra, na prática, como a **Programação Lógica** pode ser utilizada para construir sistemas capazes de **extrair conhecimento de grandes volumes de dados**, utilizando inferência declarativa.

A abordagem evidencia a aplicação de conceitos fundamentais de **Lógica e Matemática Discreta** no desenvolvimento de sistemas inteligentes.

---
