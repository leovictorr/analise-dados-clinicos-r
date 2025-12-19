# -------------------------------------------------------------------------
# SCRIPT DE ANÁLISE DE DADOS CLÍNICOS (PORTFÓLIO)
# -------------------------------------------------------------------------
# ESTE SCRIPT REALIZA:
# 1. Geração de dados fictícios (para anonimização e conformidade com LGPD).
# 2. Limpeza e tratamento de strings (Regex, padronização).
# 3. Análise estatística descritiva e comparativa.
# 4. Geração de tabelas formatadas para publicação (Word/Excel).
# -------------------------------------------------------------------------

# --- 1. CONFIGURAÇÃO INICIAL E PACOTES ---
if (!require("pacman")) install.packages("pacman")
pacman::p_load(
  readxl, tidyverse, janitor, lubridate, writexl, 
  gtsummary, flextable, stringr, tibble, openxlsx
)

# Cria a pasta de saída se não existir
if(!dir.exists("saida")) dir.create("saida")

# Configurações regionais do gtsummary (PT-BR)
theme_gtsummary_language("pt", decimal.mark = ",", big.mark = ".")
theme_gtsummary_compact()

# --- 2. GERAÇÃO DE DADOS FICTÍCIOS (MOCK DATA) ---
# OBJETIVO: Simular a estrutura do banco de dados real para demonstração pública,
# preservando o sigilo dos pacientes reais da tese.

print("Gerando dados fictícios para demonstração...")
set.seed(123) # Semente para reprodutibilidade

n_pacientes <- 60 # Tamanho da amostra simulada

# Lista de medicamentos para simular o campo de texto livre
lista_meds <- c("uso de baclofeno", "diazepam regular", "biperideno", 
                "triexifenidil", "clorpromazina", "clonidina", "sem medicacao", NA)

# Lista de sintomas para simular a extração de texto (Regex)
lista_inicio <- c("2 meses", "1 ano", "6 meses", "nasceu assim", "1a 2m", "5 dias", NA)

# Criando o dataframe bruto simulado (já com nomes limpos para facilitar)
dados_brutos <- tibble(
  nome_do_paciente = paste("Paciente Fictício", 1:n_pacientes),
  
  # Datas
  data_de_nascimento = sample(seq(as.Date('2000-01-01'), as.Date('2023-01-01'), by="day"), n_pacientes),
  data_1o_consulta = data_de_nascimento + sample(100:2000, n_pacientes, replace = TRUE),
  
  # Variáveis demográficas
  sexo = sample(c("Feminino", "Masculino"), n_pacientes, replace = TRUE),
  naturalidade = sample(c("Rio de Janeiro - RJ", "São Paulo - SP", "Belo Horizonte - MG", "Salvador - BA"), n_pacientes, replace = TRUE),
  idade = paste(sample(1:20, n_pacientes, replace = TRUE), "anos"),
  
  # Variáveis Clínicas (Sim/Não e Categóricas)
  macrocrania = sample(c("Sim", "Não"), n_pacientes, replace = TRUE, prob = c(0.3, 0.7)),
  consaguineidade = sample(c("Sim", "Não"), n_pacientes, replace = TRUE, prob = c(0.1, 0.9)),
  crise_encefalopatica = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  
  # Campos de texto livre para tratamento via Regex posteriormente
  inicio_dos_sintomas = sample(lista_inicio, n_pacientes, replace = TRUE),
  nome_medicacao_tratamento_distonia = sample(lista_meds, n_pacientes, replace = TRUE),
  evento_desencadeante = sample(c("infecção viral", "vacina", "cirurgia", "assintomático", "febre"), n_pacientes, replace = TRUE),
  
  # Variáveis Neurológicas
  disturbio_do_movimento = sample(c("Distonia", "Coreia", "Outro"), n_pacientes, replace = TRUE),
  distonia = sample(c("Generalizada", "Focal"), n_pacientes, replace = TRUE),
  escala_distonia = as.character(sample(0:100, n_pacientes, replace = TRUE)), # Texto para ser convertido depois
  coreoatetose = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  mioclonias = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  sinais_piramidais = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  
  hipotonia = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  caracterizacao_da_hipotonia = sample(c("global", "axial", "axial com hipertonia apendicular"), n_pacientes, replace = TRUE),
  
  epilepsia = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  ataxia = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  
  declinio_cognitivo = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  grau_do_declinio_cognitivo = sample(c("leve", "grave", "moderado"), n_pacientes, replace = TRUE),
  
  inicio_insidioso = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  familiar_com_ga1 = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  neuropatia_periferica = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  
  # Tratamentos e Exames
  em_em_tandem = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  diagnostico_molecular = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  diagnostico_pre_sintomatico = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  fez_dieta_restritiva = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  uso_l_carnitina = sample(c("Sim", "Não"), n_pacientes, replace = TRUE), # Correção do nome para match
  anticonvulsivante = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  tratamento_pra_distonia = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  
  neurocirurgia = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  ressonancia = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  
  # Variáveis adicionais da lista original (preenchidas com NA ou Sim/Não)
  alargamento_de_fissura_silviana = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  necrose_estriatal_bilateral = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  nodulos_ependimarios = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  hematoma_subdural = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  funcao_renal_tfg = sample(c("Normal", "Alterada"), n_pacientes, replace = TRUE),
  realizou_usg_de_rins_e_vias_urinarias = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  realizado_proteinuria_de_24_horas = sample(c("Sim", "Não"), n_pacientes, replace = TRUE),
  alteracao_de_substancia_branca_supratentorial = sample(c("Sim", "Não"), n_pacientes, replace = TRUE)
)

# -------------------------------------------------------------------------
# IMPORTAÇÃO ORIGINAL (COMENTADA POR SEGURANÇA)
# -------------------------------------------------------------------------
# input_file <- "dataframe_pacientes_rev.xlsx" 
# dados_brutos <- read_excel(input_file, skip = 2) 

# --- 3. FUNÇÕES AUXILIARES ---

teste_fisher_robusto <- function(data, variable, by, ...) {
  result <- tryCatch(
    {
      stats::fisher.test(data[[variable]], data[[by]], simulate.p.value = TRUE)$p.value
    },
    error = function(e) { return(NA_real_) }
  )
  if (is.null(result) || length(result) == 0) result <- NA_real_
  return(tibble::tibble(p.value = result))
}

# Função: Gera texto de missing para rodapé
gerar_texto_missing <- function(tabela) {
  dados_input <- tabela$inputs$data
  
  vars_na_tabela <- tabela$table_body %>% 
    filter(!is.na(variable)) %>% 
    pull(variable) %>% 
    unique()
  
  lista_missing <- dados_input %>%
    select(any_of(vars_na_tabela)) %>%
    map_df(~sum(is.na(.))) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "n_missing") %>%
    filter(n_missing > 0)
  
  if (nrow(lista_missing) == 0) return(NULL)
  
  labels_map <- tabela$table_body %>%
    select(variable, var_label) %>%
    distinct() %>%
    filter(!is.na(variable)) %>%
    deframe()
  
  texto_final <- lista_missing %>%
    mutate(
      label_bonito = labels_map[variable],
      label_bonito = ifelse(is.na(label_bonito), variable, label_bonito),
      texto = paste0(label_bonito, " (n=", n_missing, ")")
    ) %>%
    pull(texto) %>%
    paste(collapse = "; ")
  
  return(paste("Valores ausentes:", texto_final))
}

# Função de Estilo (Word)
minha_config_tbl <- function(tabela) {
  texto_rodape <- gerar_texto_missing(tabela)
  
  t <- tabela %>%
    bold_labels() %>%
    italicize_levels()
  
  if(!is.null(texto_rodape)) {
    t <- t %>% modify_footnote(all_stat_cols() ~ texto_rodape)
  }
  return(t)
}

# Função Exportação Excel com Rodapé
converter_para_excel_com_rodape <- function(tabela_gt) {
  df <- as_tibble(tabela_gt)
  texto_rodape <- gerar_texto_missing(tabela_gt)
  
  if (!is.null(texto_rodape)) {
    nova_linha <- df[1, ] %>% mutate(across(everything(), ~NA))
    nova_linha[[1]] <- texto_rodape 
    df <- bind_rows(df, nova_linha)
  }
  return(df)
}

# --- 4. PROCESSAMENTO E LIMPEZA DE DADOS (ETL) ---

colunas_binarias_originais <- c(
  "macrocrania", "consaguineidade", "crise_encefalopatica",
  "disturbio_do_movimento", "distonia", "coreoatetose", "mioclonias",
  "sinais_piramidais", "epilepsia", "ataxia", "declinio_cognitivo", 
  "inicio_insidioso", "familiar_com_ga1", 
  "em_em_tandem", "diagnostico_molecular", "diagnostico_pre_sintomatico",
  "fez_dieta_restritiva", "neurocirurgia", "ressonancia",
  "alargamento_de_fissura_silviana", "necrose_estriatal_bilateral",
  "nodulos_ependimarios", "hematoma_subdural",
  "funcao_renal_tfg", "realizou_usg_de_rins_e_vias_urinarias",
  "realizado_proteinuria_de_24_horas", "neuropatia_periferica", 
  "uso_l_carnitina", "anticonvulsivante"
)

dados_formatados <- dados_brutos %>%
  clean_names() %>% # Padroniza nomes das colunas
  filter(!is.na(data_de_nascimento), !is.na(nome_do_paciente)) %>%
  
  # --- TRATAMENTO DE TEXTO ---
  mutate(across(where(is.character), ~ str_trim(str_to_lower(.x)))) %>%
  mutate(across(where(is.character), ~ case_when(
    . %in% c("desconhecido", "não informado", "ni", "não se aplica", "na") ~ NA_character_,
    TRUE ~ .
  ))) %>%
  
  mutate(
    # --- 1. DATAS E IDADES ---
    data_de_nascimento = as_date(data_de_nascimento),
    data_1o_consulta    = as_date(data_1o_consulta),
    idade_consulta_anos = time_length(interval(data_de_nascimento, data_1o_consulta), "years"),
    idade_recrutamento = as.numeric(str_extract(idade, "\\d+")), 
    
    # Extração Idade Início Sintomas (Regex)
    sintomas_limpo = str_extract(inicio_dos_sintomas, "^[^\\.\\+\\(/]+"),
    ano_ext = as.numeric(str_extract(sintomas_limpo, "\\d+(?=\\s*a)")),
    mes_ext = as.numeric(str_extract(sintomas_limpo, "\\d+(?=\\s*m)")),
    dia_ext = as.numeric(str_extract(sintomas_limpo, "\\d+(?=\\s*d)")),
    
    inicio_sintomas_meses_num = case_when(
      is.na(ano_ext) & is.na(mes_ext) & is.na(dia_ext) ~ NA_real_,
      TRUE ~ replace_na(ano_ext, 0) * 12 + replace_na(mes_ext, 0) + replace_na(dia_ext, 0) / 30
    ),
    
    idade_inicio_sintomas_anos = as.numeric(inicio_sintomas_meses_num / 12),
    
    # --- 2. NOVA CATEGORIZAÇÃO DE SINTOMAS (3 GRUPOS) ---
    grupo_sintomas = case_when(
      !is.na(inicio_sintomas_meses_num) & inicio_sintomas_meses_num < 6 ~ "< 6 meses",
      !is.na(inicio_sintomas_meses_num) & inicio_sintomas_meses_num >= 6 ~ "≥ 6 meses",
      TRUE ~ "Sem sintomas ou sem informação"
    ),
    grupo_sintomas = factor(grupo_sintomas, levels = c("< 6 meses", "≥ 6 meses", "Sem sintomas ou sem informação")),
    
    # --- 3. MINERAÇÃO DE TEXTO DE MEDICAMENTOS ---
    nome_medicacao_tratamento_distonia = replace_na(as.character(nome_medicacao_tratamento_distonia), ""),
    uso_baclofeno = case_when(str_detect(nome_medicacao_tratamento_distonia, "baclofen") ~ "Sim", TRUE ~ "Não"),
    uso_diazepam_nitra = case_when(str_detect(nome_medicacao_tratamento_distonia, "diazepa|nitrazepa") ~ "Sim", TRUE ~ "Não"),
    uso_biperideno = case_when(str_detect(nome_medicacao_tratamento_distonia, "biperiden") ~ "Sim", TRUE ~ "Não"),
    uso_triexifenidil = case_when(str_detect(nome_medicacao_tratamento_distonia, "triexifenidil") ~ "Sim", TRUE ~ "Não"),
    uso_clorpromazina = case_when(str_detect(nome_medicacao_tratamento_distonia, "clorpromazina") ~ "Sim", TRUE ~ "Não"),
    uso_clonidina = case_when(str_detect(nome_medicacao_tratamento_distonia, "clonidina") ~ "Sim", TRUE ~ "Não"),
    
    # --- 4. ENGENHARIA CLÍNICA ---
    escala_distonia = as.character(escala_distonia),
    escala_distonia = str_replace(escala_distonia, ",", "."),
    escala_distonia = suppressWarnings(as.numeric(escala_distonia)),
    
    evento_desencadeante_cat = case_when(
      str_detect(evento_desencadeante, "infec") ~ "Infecção",
      str_detect(evento_desencadeante, "cirurg") ~ "Cirurgia",
      str_detect(evento_desencadeante, "assint") ~ "Assintomático (NSA)",
      TRUE ~ "Outro"
    ),
    
    hipotonia_tipo = case_when(
      str_detect(hipotonia, "^n") ~ "Não", 
      str_detect(caracterizacao_da_hipotonia, "global") ~ "Global",
      str_detect(caracterizacao_da_hipotonia, "axial com") ~ "Axial com Hipertonia apendicular",
      str_detect(caracterizacao_da_hipotonia, "axial") ~ "Axial",
      TRUE ~ NA_character_
    ),
    hipotonia_tipo = factor(hipotonia_tipo, levels = c("Não", "Global", "Axial", "Axial com Hipertonia apendicular")),
    
    declinio_classificacao = case_when(
      str_detect(declinio_cognitivo, "^n") ~ "Não",
      str_detect(grau_do_declinio_cognitivo, "leve") ~ "Leve",
      str_detect(grau_do_declinio_cognitivo, "grave") ~ "Grave",
      TRUE ~ NA_character_
    ),
    
    alteracao_subs_branca = case_when(
      str_detect(alteracao_de_substancia_branca_supratentorial, "^s") ~ "Sim",
      TRUE ~ "Não"
    ),
    
    sexo = str_to_upper(str_sub(sexo, 1, 1)),
    
    # --- 5. LIMPEZA FINAL DE BINÁRIOS ---
    across(any_of(c(colunas_binarias_originais, 
                    "uso_baclofeno", "uso_diazepam_nitra", "uso_biperideno", 
                    "uso_triexifenidil", "uso_clorpromazina", "uso_clonidina", 
                    "alteracao_subs_branca")), 
           ~ factor(case_when(
             str_detect(as.character(.x), regex("^s|^y", ignore_case = TRUE)) ~ "Sim",
             str_detect(as.character(.x), regex("^n", ignore_case = TRUE)) ~ "Não",
             TRUE ~ NA_character_
           ), levels = c("Não", "Sim")))
  ) %>%
  
  # --- 6. LIMPEZA DE NATURALIDADE ---
  mutate(
    temp_nat = naturalidade %>%
      str_remove("\\(.*\\)") %>%       
      str_replace_all("/", "-") %>%    
      str_squish(),                    
    temp_nat = str_replace(temp_nat, "-so$", "-sp") 
  ) %>%
  separate(
    col = temp_nat, 
    into = c("cidade_limpa", "uf_limpa"), 
    sep = "\\s*-\\s*", 
    extra = "merge", 
    fill = "right"
  ) %>%
  mutate(
    cidade_limpa = str_to_title(cidade_limpa),
    uf_limpa = str_to_upper(uf_limpa)
  )

todas_colunas_binarias <- c(
  colunas_binarias_originais,
  "uso_baclofeno", "uso_diazepam_nitra", "uso_biperideno", 
  "uso_triexifenidil", "uso_clorpromazina", "uso_clonidina",
  "alteracao_subs_branca"
)

# --- 5. CRIAÇÃO DAS TABELAS ESTATÍSTICAS ---

# --- TABELA 1: Descritiva ---
tabela1 <- dados_formatados %>%
  select(
    idade_recrutamento, idade_consulta_anos, sexo, uf_limpa, 
    diagnostico_pre_sintomatico, idade_inicio_sintomas_anos,
    evento_desencadeante_cat, consaguineidade, familiar_com_ga1
  ) %>%
  tbl_summary(
    type = list(
      idade_inicio_sintomas_anos ~ "continuous",
      any_of(todas_colunas_binarias) ~ "dichotomous",
      sexo ~ "dichotomous"
    ),
    value = list(
      sexo ~ "F", 
      any_of(todas_colunas_binarias) ~ "Sim"
    ), 
    missing = "no", 
    label = list(
      idade_recrutamento ~ "Idade no Recrutamento (anos)",
      idade_consulta_anos ~ "Idade na 1ª Consulta (anos)",
      sexo ~ "Sexo Feminino",
      uf_limpa ~ "Estado de Origem (UF)",
      diagnostico_pre_sintomatico ~ "Diagnóstico Pré-Sintomático",
      idade_inicio_sintomas_anos ~ "Idade Início Sintomas (anos)",
      evento_desencadeante_cat ~ "Evento Desencadeante",
      consaguineidade ~ "Consanguinidade",
      familiar_com_ga1 ~ "Histórico Familiar GA1"
    ),
    statistic = list(all_continuous() ~ "{median} ({p25}-{p75})", all_categorical() ~ "{n} ({p}%)"),
    digits = all_categorical() ~ c(0, 1)
  ) %>%
  minha_config_tbl()

# --- TABELA 2: Sexo x Clínico ---
tabela2 <- dados_formatados %>%
  select(
    sexo,
    idade_inicio_sintomas_anos, evento_desencadeante_cat, consaguineidade, familiar_com_ga1,
    macrocrania, crise_encefalopatica, disturbio_do_movimento,
    distonia, escala_distonia, coreoatetose, mioclonias,
    sinais_piramidais, hipotonia_tipo, epilepsia, ataxia,
    declinio_classificacao, neuropatia_periferica, inicio_insidioso
  ) %>%
  tbl_summary(
    by = sexo,
    type = list(
      escala_distonia ~ "continuous", 
      idade_inicio_sintomas_anos ~ "continuous",
      any_of(todas_colunas_binarias) ~ "dichotomous"
    ),
    value = list(any_of(todas_colunas_binarias) ~ "Sim"), 
    missing = "no", 
    label = list(
      idade_inicio_sintomas_anos ~ "Idade Início Sintomas",
      evento_desencadeante_cat ~ "Evento Desencadeante",
      escala_distonia ~ "Escala Distonia (Burke)",
      hipotonia_tipo ~ "Tipo de Hipotonia",
      declinio_classificacao ~ "Declínio Cognitivo",
      neuropatia_periferica ~ "Neuropatia Periférica",
      inicio_insidioso ~ "Início Insidioso"
    )
  ) %>%
  add_p(
    test = list(all_continuous() ~ "wilcox.test", all_categorical() ~ teste_fisher_robusto),
    test.args = all_continuous() ~ list(exact = FALSE) 
  ) %>%
  minha_config_tbl()

# --- TABELA 3: Sintomas x Clínico (3 GRUPOS) ---
tabela3 <- dados_formatados %>%
  select(
    grupo_sintomas,
    idade_inicio_sintomas_anos, evento_desencadeante_cat, consaguineidade,
    macrocrania, crise_encefalopatica, disturbio_do_movimento,
    distonia, escala_distonia, coreoatetose, mioclonias,
    declinio_classificacao
  ) %>%
  tbl_summary(
    by = grupo_sintomas,
    type = list(
      escala_distonia ~ "continuous", 
      idade_inicio_sintomas_anos ~ "continuous",
      any_of(todas_colunas_binarias) ~ "dichotomous"
    ),
    value = list(any_of(todas_colunas_binarias) ~ "Sim"), 
    missing = "no",
    label = list(
      escala_distonia ~ "Escala Distonia",
      declinio_classificacao ~ "Declínio Cognitivo"
    )
  ) %>%
  add_p(test = list(all_continuous() ~ "kruskal.test", all_categorical() ~ teste_fisher_robusto)) %>%
  minha_config_tbl()

# --- TABELA 4: Tratamento x Sintomas (3 GRUPOS) ---
tabela4 <- dados_formatados %>%
  select(
    grupo_sintomas,
    fez_dieta_restritiva, uso_l_carnitina, tratamento_pra_distonia,
    uso_baclofeno, uso_diazepam_nitra, uso_biperideno, 
    uso_triexifenidil, uso_clorpromazina, uso_clonidina,
    anticonvulsivante, neurocirurgia, ressonancia
  ) %>%
  tbl_summary(
    by = grupo_sintomas,
    type = list(any_of(todas_colunas_binarias) ~ "dichotomous"),
    value = list(any_of(todas_colunas_binarias) ~ "Sim"), 
    missing = "no",
    label = list(
      fez_dieta_restritiva ~ "Dieta Restritiva",
      uso_l_carnitina ~ "Uso L-Carnitina",
      uso_baclofeno ~ "Baclofeno",
      uso_diazepam_nitra ~ "Diazepam/Nitrazepam",
      uso_biperideno ~ "Biperideno",
      neurocirurgia ~ "Realizou Neurocirurgia",
      ressonancia ~ "Alt. Ressonância"
    )
  ) %>%
  add_p(test = list(all_categorical() ~ teste_fisher_robusto)) %>%
  minha_config_tbl()

# --- TABELA 5: Tratamento x Sexo ---
tabela5 <- dados_formatados %>%
  select(
    sexo,
    fez_dieta_restritiva, uso_l_carnitina, tratamento_pra_distonia,
    uso_baclofeno, uso_diazepam_nitra, uso_biperideno, 
    uso_triexifenidil, uso_clorpromazina, uso_clonidina,
    anticonvulsivante, neurocirurgia
  ) %>%
  tbl_summary(
    by = sexo,
    type = list(any_of(todas_colunas_binarias) ~ "dichotomous"),
    value = list(any_of(todas_colunas_binarias) ~ "Sim"), 
    missing = "no",
    label = list(
      fez_dieta_restritiva ~ "Dieta Restritiva",
      uso_l_carnitina ~ "Uso L-Carnitina",
      uso_baclofeno ~ "Baclofeno",
      uso_diazepam_nitra ~ "Diazepam/Nitrazepam"
    )
  ) %>%
  add_p(test = list(all_categorical() ~ teste_fisher_robusto)) %>%
  minha_config_tbl()

# --- 6. EXPORTAÇÃO (WORD E EXCEL) ---
doc_final <- save_as_docx(
  "Tabela 1 - Descritiva" = as_flex_table(tabela1),
  "Tabela 2 - Clínico x Sexo" = as_flex_table(tabela2),
  "Tabela 3 - Clínico x Sintomas" = as_flex_table(tabela3),
  "Tabela 4 - Tratamento x Sintomas" = as_flex_table(tabela4),
  "Tabela 5 - Tratamento x Sexo" = as_flex_table(tabela5),
  path = "saida/Tabelas_Portfolio_Mock.docx"
)

# Exportar Excel com Rodapé
lista_tabelas_excel <- list(
  "Tab1_Descritiva" = converter_para_excel_com_rodape(tabela1),
  "Tab2_Clinico_Sexo" = converter_para_excel_com_rodape(tabela2),
  "Tab3_Clinico_Sintomas" = converter_para_excel_com_rodape(tabela3),
  "Tab4_Trat_Sintomas" = converter_para_excel_com_rodape(tabela4),
  "Tab5_Trat_Sexo" = converter_para_excel_com_rodape(tabela5)
)
write_xlsx(lista_tabelas_excel, path = "saida/Tabelas_Portfolio_Mock.xlsx")

print("Script executado com sucesso! Arquivos gerados na pasta 'saida'.")
