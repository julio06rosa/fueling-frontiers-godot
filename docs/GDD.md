# GDD — Fueling Frontiers: Mars Station

**Game Design Document (Documento de Design de Jogo)**  
**Documentação:** GDD da versão jogável 0.9.3  
**Atualização:** 05/11/2026 · **Status:** documentação revisada e alinhada ao código; validação independente de execução pendente

| Campo | Descrição |
|---|---|
| Jogo | Fueling Frontiers: Mars Station |
| Gênero | Simulação / gerenciamento / precisão |
| Plataforma-alvo | Computador, por meio do editor Godot; compatibilidade multiplataforma ainda sujeita a teste |
| Engine | Godot 4.7 (configuração declarada em `project.godot`) |
| Linguagem | GDScript |
| Modo | Um jogador |
| Interface | 2D, teclado e mouse |
| Versão do projeto | 0.9.3 |
| Integrantes do grupo | Júlio César Duarte da Rosa; Rafael da Rocha da Silva; Paulo Guilherme Richeski Padilha |

## 1. Visão geral e proposta

**Fueling Frontiers: Mars Station** coloca o jogador na função de operador de uma estação de abastecimento localizada em Marte. Cada nave que chega apresenta um pedido específico de combustível, envolvendo **proporção química entre dois componentes**, **volume-alvo** e **tempo limite**.

O desafio é interpretar informações, configurar o misturador e controlar uma bomba de abastecimento com precisão suficiente para satisfazer o contrato. A cada atendimento, o jogador pode melhorar ou prejudicar a saúde econômica e a reputação de sua estação.

### Experiência pretendida

- Desafiar atenção, interpretação de proporções e tomada de decisão sob pressão de tempo.
- Oferecer retorno imediato por ações corretas e incorretas.
- Criar uma progressão curta e repetível, baseada em dinheiro, reputação e upgrades.
- Apresentar uma ambientação de ficção científica com naves, hangar, sons e interface de operação.

### Público e acessibilidade

Destinado a usuários capazes de operar jogos de computador com teclado e mouse. O game exibe texto e valores numéricos em português. Não há, na versão atual, evidência de remapeamento de atalhos ou de recursos completos de acessibilidade; o suporte deve ser avaliado em testes futuros.

## 2. Conceito e fantasia do jogador

**Papel:** operador de abastecimento da doca marciana.  
**Ambiente:** estação industrial espacial com naves de diversas origens.  
**Desafio central:** transformar um pedido técnico em uma mistura e um volume corretos antes do prazo.  
**Recompensa:** créditos, reputação, classificação de precisão, evolução da estação e continuidade de atendimentos.

## 3. Pilares do design

1. **Precisão:** ajustar a proporção correta e parar a bomba na quantidade pedida.
2. **Pressão controlada:** cada contrato possui um tempo máximo de atendimento.
3. **Feedback claro:** HUD, barras, estados de mistura, mensagens da ARIA, créditos e reputação refletem o resultado.
4. **Progressão:** o desempenho permite comprar melhorias e assumir contratos mais exigentes.

## 4. Fluxo de jogo (core loop)

```text
MENU PRINCIPAL
   ├── COMO JOGAR (ajuda resumida)
   ├── OFICINA DE UPGRADES
   ├── REINICIAR PROGRESSO (após confirmação; zera tudo)
   └── INICIAR TURNO / CONTINUAR OPERAÇÕES
          ↓
    NAVE EM APROXIMAÇÃO
          ↓
    LEITURA DO MANIFESTO
          ↓
    AJUSTE DA MISTURA
          ↓
    BOMBA LIGADA: MONITORAR VOLUME E TEMPO
          ↓
    BOMBA DESLIGADA OU CONDIÇÃO DE FALHA
          ↓
    VALIDAÇÃO E RECOMPENSA / PENALIDADE
          ↓
    NAVE PARTE → CHEGA OUTRA NAVE
```

O botão **Pausar / Menu** ou a tecla **Esc** abre a tela de pausa, pela qual o jogador pode continuar, acessar a oficina ou voltar ao menu.

**Decisão de design:** os atendimentos são contínuos e não há botão para repetir apenas uma nave que apresentou erro. Um atendimento finalizado gera consequências no saldo, na reputação e nas estatísticas. **Reiniciar Progresso** é uma opção separada que redefine a evolução inteira do jogador. Na versão atual, sair durante um atendimento não concluído ainda permite abandoná-lo sem penalidade, pois o pedido ativo não é salvo; essa limitação está descrita nas seções 12 e 14.

## 5. Objetivos e condições de resultado

**Objetivo imediato:** atender cada nave com uma mistura e um volume dentro das tolerâncias, antes do fim do prazo.  
**Objetivo contínuo:** construir uma estação bem-sucedida, acumular créditos, manter a reputação, adquirir upgrades e completar sequências de atendimentos. Os recursos e as estatísticas são preservados ao fechar e reabrir o jogo, mas a nave em andamento não é retomada.

**Vitória em um atendimento:** desligar a bomba com mistura e volume válidos.  
**Derrota em um atendimento:** mistura inadequada, volume fora da tolerância, prazo esgotado ou transbordamento crítico.  
**Fim de jogo global:** **não implementado**. O protótipo não possui campanha fechada nem tela final de vitória ou game over permanente. Depois de um resultado, outra nave pode chegar.

## 6. Mecânicas principais

### 6.1 Pedidos e contratos

Cada nave possui identificação, origem, nomes de componentes de combustível e um pedido gerado a partir de combinações. Os volumes regulares possíveis no código são **100, 150, 200, 250 ou 300 UF**. O prazo é sorteado aproximadamente entre **40 e 65 segundos**.

Razões regulares implementadas: **1:1, 2:1, 3:1, 4:1, 3:2, 1:3**. A origem e o nome da nave variam para diversificar os atendimentos.

### 6.2 Mistura química

O jogador ajusta a porcentagem do **componente A** (0% a 100%); a quantidade de B é complementar.

**Fórmula de referência:**

```text
Porcentagem de A = A / (A + B) × 100
Porcentagem de B = 100 − porcentagem de A
```

Exemplo: proporção **3:2** → A = **60%** e B = **40%**.

**Tolerância de aprovação:** diferença máxima de **2 pontos percentuais** entre a porcentagem escolhida para A e a porcentagem solicitada. A interface apresenta aviso de mistura estável ou instável.

### 6.3 Bomba e volume

A bomba é acionada por botão ou barra de espaço. Enquanto ligada, o volume abastecido aumenta conforme a vazão. O jogador deve interrompê-la perto do volume-alvo.

**Tolerância:** volume dentro de **±3%** do pedido ao desligar a bomba.

**Limite crítico:** o código trata volume de **115% ou mais** do alvo como transbordamento grave. A rotina evita chamar simultaneamente a validação comum e a penalidade crítica; é necessário **confirmar em teste de regressão** que apenas uma penalidade é registrada.

### 6.4 Tempo

O cronômetro corre quando a nave aguarda ou está sendo abastecida. Ao chegar a zero, o atendimento falha e a nave parte. Durante a pausa do gameplay, o tempo não avança.

### 6.5 Máquina de estados das naves

| Estado técnico | Comportamento |
|---|---|
| `APPROACHING` | Nave se aproxima da doca; bomba indisponível |
| `WAITING` | Nave atracada; jogador pode ajustar mistura e iniciar abastecimento |
| `REFUELING` | Bomba em funcionamento; volume e tempo são atualizados |
| `DEPARTING` | Resultado processado; nave deixa a doca e outra será gerada |

A lógica-base está em `Gameplay.gd`; a camada de apresentação e progressão expandida está em `GameplayEnhanced.gd`.

## 7. Economia, reputação e avaliação

### 7.1 Valores iniciais

- **Créditos iniciais:** **0** em uma nova campanha ou após **Reiniciar Progresso**. Um salvamento existente mantém o saldo anteriormente adquirido.
- **Reputação inicial:** 50% (valor interno `0.5`).
- **Upgrades iniciais:** nenhum.

### 7.2 Resultado bem-sucedido

- Recompensa-base: **2 créditos por UF** solicitada (`volume_alvo × 2`).
- Bônus de velocidade: **+100 créditos** se restar mais da metade do tempo inicial.
- Reputação: **+5 pontos percentuais**, limitada a 100%.
- Bônus de sequência: **25 créditos por acerto anterior consecutivo**, com limite adicional de **125 créditos** por atendimento.
- Contrato Elite concluído: **+150 créditos** adicionais.

### 7.3 Resultado malsucedido

- Erro comum após parada e validação: **−150 créditos** e **−8 pontos percentuais** de reputação.
- Tempo esgotado ou falha crítica: regra de **−200 créditos** e **−10 pontos percentuais** de reputação; o caminho de transbordamento exige teste de regressão específico.
- Créditos não ficam negativos; a reputação permanece entre 0% e 100%.

### 7.4 Qualidade de atendimento

Atendimentos bem-sucedidos recebem classificação conforme o erro de mistura e o erro percentual do volume:

| Nota | Erro máximo de mistura | Erro máximo de volume |
|---|---:|---:|
| **S** | 0,35 ponto percentual | 0,60% |
| **A** | 0,80 ponto percentual | 1,25% |
| **B** | 1,40 ponto percentual | 2,10% |
| **C** | Demais acertos válidos | Demais acertos válidos |

A classificação é verificada de cima para baixo: atribui-se a primeira nota em que **as duas condições** sejam satisfeitas.

## 8. Progressão e upgrades

A oficina é acessível pelo menu principal e pelo menu de pausa. Três melhorias estão implementadas:

| Melhoria | Níveis | Custo | Resultado |
|---|---:|---|---|
| **Bomba de alta vazão** | 0 → 3 | 500, 1.000 e 1.500 CR | Vazão `40 + 20 × nível` UF/s |
| **Válvula automática** | Disponível / comprada | 800 CR | Para no volume pedido |
| **Sensor holográfico (HUD auxiliar)** | Disponível / comprado | 400 CR | Informa qual componente está em excesso ou confirma uma mistura aceitável, **sem revelar porcentagens exatas** |

O jogador não pode comprar melhorias sem créditos suficientes. As aquisições são registradas no save local. A vazão inicial é **40 UF/s** e pode chegar a **100 UF/s** com os três níveis da bomba.

**Comportamento do sensor:** sem o upgrade, a interface incentiva o cálculo da proporção; com o upgrade adquirido, indica **excesso do componente A ou B** se a proporção estiver incorreta, ou confirma **proporção correta** quando a diferença for de até 2 pontos percentuais. A dica não substitui o raciocínio do jogador.

### Contratos Elite

Na lógica atual, contratos Elite podem aparecer quando há **pelo menos três atendimentos bem-sucedidos no turno** e o número da nave recebida é múltiplo de três. Esses contratos utilizam proporções adicionais **5:2, 2:5, 5:3 e 3:5**, além do bônus de 150 créditos em caso de sucesso.

## 9. Interface, HUD e navegação

### Menu principal (`MainMenu.tscn`)

Disponibiliza iniciar/continuar, oficina, tela **Como Jogar**, reinício com confirmação e saída. Exibe ainda créditos, reputação, patente e estatísticas da estação.

### Gameplay (`Gameplay.tscn`)

O painel apresenta manifesto (nave, origem, fórmula, volume), misturador com slider, botão de bomba, tempo restante, créditos, reputação, mensagens de estado/ARIA, visual da nave e indicações adicionais do contrato.

### Oficina (`UpgradeMenu.tscn`)

Apresenta as melhorias, custos e estados de disponibilidade. Impede compras inválidas por falta de recursos ou nível máximo.

### Pausa

Permite continuar o atendimento, acessar a oficina ou voltar ao menu; usa **Esc** ou o botão de interface. O painel foi ajustado no código para centralização no overlay e tamanho de **500 × 420**. A alteração precisa de conferência visual no ambiente de entrega.

**Atenção:** navegar à oficina ou ao menu durante um atendimento não salva a nave, o cronômetro nem o volume parcial. Ao voltar ao gameplay, um novo pedido começa; uma penalidade por abandono **não está implementada**.

## 10. Controles

| Comando | Ação |
|---|---|
| Mouse | Menus, botão da bomba e ajuste pela barra |
| Q / E | Diminuir / aumentar o componente A em 1 ponto percentual |
| Shift + Q / E | Alterar em 5 pontos percentuais |
| Espaço | Alternar bomba ligada/desligada |
| Esc | Pausar ou retomar gameplay |
| Setas | Movimentar personagem pelo cenário |

Não é necessário estar fisicamente próximo da bomba para usar os controles da interface na implementação atual.

## 11. Direção de arte e áudio

**Tema visual:** ficção científica industrial, Marte, doca espacial e painéis eletrônicos com acentos turquesa/alaranjados. O projeto usa cenas `.tscn`, elementos geométricos e desenhos gerados por GDScript para personagens, naves e ambiente.  
**Áudio:** sinais de interface, passos, chegada de naves, bombeamento e resultados gerenciados em `SoundManager.gd`; a implementação usa sons gerados programaticamente.

## 12. Arquitetura técnica resumida

| Arquivo | Responsabilidade |
|---|---|
| `project.godot` | Configuração geral, autoloads e cena inicial |
| `MainMenu.gd` | Navegação e apresentação do menu |
| `Gameplay.gd` | Contratos regulares, estados, mistura, bomba, resultado |
| `GameplayEnhanced.gd` | Contratos Elite, sequências, classificação, atalhos e pausa |
| `GameManager.gd` | Estado persistente, créditos, reputação, upgrades e estatísticas |
| `UpgradeMenu.gd` | Compras e atualização da oficina |
| `Player.gd`, `PlayerVisual.gd`, `ShipVisual.gd` | Personagem e apresentação visual |
| `SoundManager.gd` | Efeitos de áudio e ambientação |

**Cena principal:** `res://MainMenu.tscn`.  
**Autoloads:** `GameManager` e `SoundManager`.  
**Persistência:** arquivo de configuração local `user://fueling_frontiers_save.cfg`, por meio de `ConfigFile`.

São gravados: **créditos, reputação, melhorias, número total de atendimentos, sucessos, falhas, melhor sequência, créditos recebidos acumulados e último resultado**. A gravação ocorre após atendimentos concluídos, falhas, compras e nas transições documentadas do gameplay para menu/oficina. A sequência de acertos **do turno atual** e o estado da nave ativa não são retomados após sair da cena de gameplay.

O menu principal possui uma opção de **Reiniciar Progresso** com confirmação. Ela chama `GameManager.reset_game()`: créditos voltam a **0**, reputação a **50%**, melhorias e estatísticas aos valores iniciais, e o novo estado é salvo.

## 13. Conteúdo implementado x planejado

| Componente | Situação na versão atual |
|---|---|
| Chegada e partida de naves | Implementado no código |
| Geração de pedidos e proporções | Implementado no código |
| Controle de bomba, volume e tempo | Implementado no código |
| Créditos, reputação e penalidades | Implementado no código |
| Upgrades e salvamento local | Implementado no código |
| Créditos iniciais e após reset em 0 CR | Implementado no código |
| Sensor com pistas sem porcentagens ideais | Implementado no código |
| Menu de pausa centralizado | Ajustado no código; validação visual pendente |
| Reiniciar apenas a nave atual após erro | Não previsto no design |
| Penalidade por abandonar atendimento ativo | Não implementada; risco de escapar das consequências |
| Retomar nave e cronômetro ao reabrir o jogo | Não implementado |
| Contratos Elite, streak e classificação | Implementado no código |
| Ajuda rápida “Como Jogar” no menu | Implementada na cena |
| Pausa | Implementada no código |
| Tutorial guiado dentro da partida | Não implementado |
| Campanha com metas e vitória global | Não implementada |
| Executável distribuível | Não incluído no repositório |
| Variedade expandida de eventos, contratos e recordes | Evolução futura |
| Teste independente documentado | Pendente de execução e registro |

**Importante:** “implementado no código” não equivale a “validado em execução”. O checklist separado orienta a verificação funcional.

## 14. Riscos, limitações e próximos incrementos

### 14.1 Decisões consolidadas de design

1. **Sem repetição isolada de atendimento:** cada resultado já registrado gera ganhos ou penalidades; não haverá botão de reiniciar apenas a nave atual.
2. **Progressão acumulada:** saldo, reputação, compras e estatísticas permanecem disponíveis após fechar e reabrir o jogo.
3. **Reinício total intencional:** o botão Reiniciar Progresso, com confirmação, restaura o estado inicial sem créditos.
4. **Sensor como auxílio:** o item comprado fornece orientações, mas não a resposta percentual.

### 14.2 Limitações e riscos identificados

- **Saída durante atendimento:** voltar ao menu ou entrar na oficina descarta a nave ativa sem penalidade automática. Isso pode permitir evitar uma perda e enfraquecer a dinâmica de risco.
- **Salvamento parcial:** não existe retomada do volume, cronômetro e nave em curso; apenas dados acumulados persistem.
- **Balanceamento:** iniciar com 0 CR exige concluir atendimentos antes de comprar upgrades. O ritmo de progressão precisa ser avaliado.
- **Sem campanha terminal:** não há tela global de vitória nem game over permanente.
- **Teste e distribuição:** ainda faltam evidências independentes de importação, operação completa e compatibilidade; o repositório não contém executável.

### 14.3 Próximos incrementos propostos — ainda não implementados

1. Definir e implementar regra para abandonar uma nave: registrar falha ao sair da operação **ou** persistir o atendimento completo, evitando que o jogador burle uma penalidade.
2. Validar a economia começando em **0 CR**, especialmente progressão às primeiras melhorias e cenários com erros seguidos.
3. Testar o sensor holográfico com proporções comuns e contratos Elite, confirmando que não mostra porcentagens exatas.
4. Verificar a posição do menu de pausa em diferentes tamanhos de janela.
5. Confirmar em execução que tempo esgotado e transbordamento crítico geram apenas uma penalidade por nave.
6. Registrar testes independentes com capturas e observações, ampliar o tutorial e considerar uma versão executável.

## 15. Critérios de aceitação da entrega N2 — Parte 1

A entrega atende aos requisitos documentais quando: (a) o repositório está público e acessível; (b) o README informa como baixar, instalar/importar e executar o projeto; (c) o GDD atualizado está disponível em `docs/GDD.md` e tem link no README; (d) o grupo registra os testes e confirma que alguém de fora consegue jogar sem orientação dos desenvolvedores.

**Roteiro mínimo de validação na Godot 4.7:**

1. Baixar o ZIP ou clonar o repositório em pasta limpa; importar `project.godot` e executar com F5.
2. Usando apenas o README, concluir um abastecimento correto e observar a recompensa e a chegada de outra nave.
3. Provocar uma mistura incorreta, verificar o desconto e confirmar que não há opção de repetir aquela nave.
4. Pausar com Esc, conferir a centralização e verificar que o cronômetro não avança enquanto pausado.
5. Acumular créditos, adquirir uma melhoria, fechar/reabrir o jogo e confirmar que os dados são preservados.
6. Adquirir o sensor e verificar que oferece pistas sem mostrar os percentuais da solução.
7. Selecionar Reiniciar Progresso, confirmar e verificar **0 CR**, **50% de reputação** e ausência de upgrades.
8. Testar o transbordamento crítico e verificar que a penalidade não é aplicada duas vezes.

O arquivo `docs/CHECKLIST_VALIDACAO.md` contém campos para os registros. **O roteiro estar escrito não significa que os testes foram executados**; as evidências precisam ser preenchidas pelo grupo antes da submissão final.

## 16. Histórico desta revisão

**05/11/2026 — revisão do GDD, sem alterar o número de versão do jogo (0.9.3):**

- Corrigido saldo inicial, de reinício e de carregamento sem campo existente para **0 CR**.
- Documentado o novo sensor holográfico com dicas em vez de valores percentuais.
- Registrado o ajuste de centralização do menu de pausa.
- Diferenciados atendimentos consecutivos, progresso persistente e reinício completo.
- Formalizada a decisão de não permitir repetição isolada de atendimento.
- Identificado o risco de abandonar uma nave ativa sem penalidade automática.
- Atualizados os testes de aceitação e o backlog para a atividade acadêmica.

**Documentos complementares:** `README.md`, `docs/CHECKLIST_VALIDACAO.md` e `docs/CHANGELOG_PROFISSIONAL.md`.
