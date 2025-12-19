# Análise e Tratamento de Dados Clínicos com R

Este repositório contém scripts desenvolvidos para automação, limpeza e análise estatística de dados reais da área de saúde.

## 🛠 Ferramentas Utilizadas
- **Linguagem:** R
- **Bibliotecas:** `tidyverse` (dplyr, tidyr), `janitor`, `writexl`.

##  O que este código faz
 **Limpeza de Dados (Data Cleaning):** Padronização de nomes de colunas e tratamento de valores nulos (NA).
 **Engenharia de Atributos:** Criação de novas variáveis baseadas em datas e condições clínicas.
 **Automatização:** Geração automática de tabelas formatadas para relatórios

##  Nota de Privacidade
Por se tratar de uma análise feita com dados reais de pacientes para uma tese de doutorado, **o arquivo de dados original não foi incluído** neste repositório para respeitar a LGPD e a ética médica. O script serve para demonstrar a lógica de estruturação e manipulação dos dados.
Pipeline de Análise Estatística e Automação de Relatórios Clínicos (R/Tidyverse)

Desenvolvimento de script para limpeza, tratamento e análise estatística de dados de uma tese de doutorado. O projeto automatiza a geração de tabelas prontas para publicação, substituindo processos manuais.

🛠️ Lógica e Ferramentas:

Ética/LGPD: Implementação de módulo "Mock Data" (geração de dados fictícios) para tornar o código público e reprodutível sem expor pacientes.

Data Cleaning: Uso de Regex e janitor para padronizar textos livres e datas não estruturadas.

Stack: R, Tidyverse, Gtsummary, Flextable.

📊 Estrutura das Análises (5 Tabelas Automatizadas):

Tab 1 (Descritiva/Baseline): Panorama demográfico e clínico da amostra. Resume variáveis contínuas (Mediana/IQR) e categóricas (n/%) para validação da coorte.

Tab 2 (Comparativo Sexo x Clínica): Aplicação de Testes Exatos de Fisher e Wilcoxon (Mann-Whitney) para investigar se há diferenças significativas na severidade da doença entre os sexos.

Tab 3 (Estratificação por Início dos Sintomas): Teste de Kruskal-Wallis cruzando gravidade clínica (Escalas) com a precocidade da doença (<6 meses vs ≥6 meses). Objetivo: validar se início precoce prediz pior prognóstico.

Tab 4 (Terapêutica vs Fenótipo): Avalia se o protocolo medicamentoso/cirúrgico varia conforme a idade de início dos sintomas.

Tab 5 (Acesso ao Tratamento): Verifica estatisticamente se há disparidade na indicação de tratamentos baseada no gênero do paciente.

🚧 Status: Projeto em andamento (atualizações contínuas conforme avanço da coleta de dados).
