output$graphs <- renderUI({
  
  # Create lists that will give the select options to the respective language
  list_trabalho_graph <- list('Trabalho' = structure(c("TT"), .Names = c(i18n()$t("Trabalho Total"))))
  list_saude_graph <- list('Saúde' = structure(c("ST", "SB", "SM", "SA"), 
                                               .Names = c(i18n()$t("Saúde Total"),
                                                          i18n()$t("Saúde Baixa"),
                                                          i18n()$t("Saúde Média"),
                                                          i18n()$t("Saúde Alta"))))
  list_edu_graph <- list('Educação' = structure(c("ET", "EI", "EF", "EM"), 
                                                .Names = c(i18n()$t("Educação Total"),
                                                           i18n()$t("Educação Infantil"),
                                                           i18n()$t("Educação Fundamental"),
                                                           i18n()$t("Educação Média"))))
  
  list_types_graphs_palma <- list('Razão de Desigualdade' = 
                                    structure(c("palma_renda", "palma_cor"), 
                                              .Names = c(i18n()$t("Desigualdade por renda (Razão de Palma)"),
                                                         i18n()$t("Desigualdade por cor"))))
  
  list_types_graphs_dumbell <- list('Desigualdade à atividade mais próxima' = 
                                      structure(c("dumbell_renda", "dumbell_cor"), 
                                                .Names = c(i18n()$t("Desigualdade por renda"),
                                                           i18n()$t("Desigualdade por cor"))))
  # Translate the name of lists accordingly
  names(list_trabalho_graph) <-c(i18n()$t("Trabalho"))
  names(list_saude_graph) <-c(i18n()$t("Saúde"))
  names(list_edu_graph) <-c(i18n()$t("Educação"))
  names(list_types_graphs_palma) <-c(i18n()$t("Razão de Desigualdade"))
  names(list_types_graphs_dumbell) <- c(i18n()$t("Desigualdade de acesso à atividade mais próxima"))
  
  
  
  # Start proper UI here 
  tagList(
    
    
    # 1) PLOT SELECTION -----------------------------------------------------
    
    pickerInput(inputId = "graph_type",
                label = label_with_info(label = i18n()$t("Escolha o gráfico:"),
                                        tooltip_id = "q15_graph"),
                choices = c(list_types_graphs_palma, list_types_graphs_dumbell),
                selected = "palma_renda",
                width = '100%'),
    div(
      bsPopover(id = "q15_graph", 
                title = sprintf("<strong>%s</strong>", i18n()$t("Gráficos")),
                content = HTML(i18n()$t(includeHTML('www/popovers/popover_graph.html'))),
                placement = "left",
                trigger = "hover",
                options = list(container = "body"))
    ),
    
    # 2) MODE SELECTION -----------------------------------------------------
    
    radioGroupButtons(inputId = "modo_todos_graph",
                      label = h1(i18n()$t("Escolha o modo de transporte:")), 
                      choices = c("<i class=\"fas fa-bus fa-2x\"></i>" = "tp", 
                                  "<i class=\"fas fa-walking fa-2x\"></i>" = "caminhada",
                                  "<i class=\"fas fa-bicycle fa-2x\"></i>" = "bicicleta"),
                      selected = "tp",
                      individual = TRUE,
                      justified = TRUE
    ),
    
    # 3) ACTIVITY SELECTION -------------------------------------------------------
    
    # IF GRAPH TYPE IS OF PALMA_RENDA OR PALMA_COR, ALL ACITIVITIES WILL BE AVAILABLE
    
    conditionalPanel(condition = "graphs_cma.indexOf(input.graph_type) > -1",
                     pickerInput(inputId = "atividade_graph_cum",
                                 label = label_with_info(label = i18n()$t("Escolha a atividade"), 
                                                         tooltip_id = "q3_graph"),
                                 choices = c(list_trabalho_graph, list_saude_graph, list_edu_graph),
                                 selected = "TT")),
    
    # IF GRAPH TYPE IS OF DUMBELL, ONLY HEALTH AND EDUCATIONAL ACTIVITIES WILL BE AVAILABLE
    
    conditionalPanel(condition = "graphs_tmi.indexOf(input.graph_type) > -1",
                     pickerInput(inputId = "atividade_graph_tmi",
                                 label = label_with_info(label = i18n()$t("Escolha a atividade"), 
                                                         tooltip_id = "q4_graph"),
                                 choices = c(list_saude_graph, list_edu_graph),
                                 selected = "ST")),
    div(
      bsPopover(id = "q3_graph", 
                title = sprintf("<strong>%s</strong>", i18n()$t("Atividades")),
                content = HTML(i18n()$t(includeHTML("www/popovers/popover_activity.html"))),
                placement = "top",
                trigger = "hover",
                options = list(container = "body"))
    ),
    div(
      bsPopover(id = "q4_graph", 
                title = sprintf("<strong>%s</strong>", i18n()$t("Atividades")),
                content = HTML(i18n()$t(includeHTML("www/popovers/popover_activity.html"))),
                placement = "top",
                trigger = "hover",
                options = list(container = "body"))
    ),
    
    
    # 4) TIME THRESHOLD SELECTION -------------------------------------------------------
    
    # IF MODE IS 'TP' (PUBLIC TRANSPORT), TIME THRESHOLD RANGES BETWEEN 30 AND 120 EVERY 30 
    # IF MODE IS 'CAMINHADA' OR 'BIKE' (WALK OU BIKE), TIME THRESHOLD RANGES BETWEEN 15 AND 60 EVERY 15 
    
    conditionalPanel(condition = "graphs_cma.indexOf(input.graph_type) > -1 && input.modo_todos_graph == 'tp'",
                     sliderInput(inputId = "tempo_tp_graph",
                                 label = h1(i18n()$t("Escolha o tempo de viagem:")),
                                 min = 30, max = 120,
                                 step = 30, value = 30,
                                 animate = animationOptions(interval = 2000),
                                 post = " min",
                                 width = '100%')),
    conditionalPanel(condition = "graphs_cma.indexOf(input.graph_type) > -1 && modos_ativos.indexOf(input.modo_todos_graph) > -1",
                     sliderInput(inputId = "tempo_ativo_graph",
                                 label = h1(i18n()$t("Escolha o tempo de viagem:")),
                                 min = 15, max = 60,
                                 step = 15, value = 15,
                                 animate = animationOptions(interval = 2000),
                                 post = " min",
                                 width = '100%')),
    
    # 5) ADITIONAL INFORMATION AT THE BOTTOM OF THE PANEL ------------------------
    
    hr(),
    tagList(i18n()$t('Mais informações podem ser encontradas na seção de resultados do'), 
            shiny::a('Texto para Discussão', href=i18n()$t('https://www.ipea.gov.br/acessooportunidades/publication/2019_td2535/')))
    
  )
  
  
  
})