# Fueling Frontiers: Mars Station

**Fueling Frontiers: Mars Station** é um jogo 2D de simulação e gerenciamento desenvolvido em **Godot**, com **GDScript**, como projeto acadêmico do curso de Engenharia de Software.

O jogador assume a operação de uma estação de abastecimento em Marte. A cada atendimento, uma nave chega com um manifesto de carga: dois componentes de combustível, uma proporção exigida, um volume solicitado e um tempo limite. É preciso interpretar os dados, preparar a mistura e interromper o abastecimento no momento certo.

O desempenho determina os **créditos**, a **reputação** e a possibilidade de adquirir melhorias para a estação. Os atendimentos são contínuos: não há uma opção para reiniciar individualmente uma nave após um erro.

## Informações do projeto

| Item | Descrição |
|---|---|
| **Gênero** | Simulação, gerenciamento e precisão |
| **Engine** | Godot 4.7 (versão configurada no projeto) |
| **Linguagem** | GDScript |
| **Plataforma-alvo** | Computador |
| **Jogadores** | Um jogador |
| **Versão do projeto** | 0.9.3 |
| **Estado** | Em desenvolvimento |

O código-fonte é disponibilizado para execução no editor Godot. Ainda não há executável independente no repositório.

## 1. Instalação e execução

### Requisitos

- **Godot Engine 4.7**, edição padrão. Consulte o [arquivo de versões da Godot](https://godotengine.org/download/archive/).
- Computador com teclado e mouse.
- Projeto baixado ou clonado deste repositório.

Não é necessário configurar servidor, banco de dados ou dependências externas. A execução em Windows, Linux e macOS ainda depende de validação específica em cada sistema.

### Baixar o projeto

**Opção A — ZIP**

1. Na [página do repositório](https://github.com/julio06rosa/fueling-frontiers-godot), selecione **Code > Download ZIP**.
2. Extraia o conteúdo em uma pasta.
3. Localize o arquivo `project.godot`.

**Opção B — Git**

```bash
git clone https://github.com/julio06rosa/fueling-frontiers-godot.git
```

### Abrir e jogar

1. Abra a Godot.
2. No gerenciador de projetos, selecione **Importar**.
3. Escolha o arquivo `project.godot` da pasta baixada.
4. Abra o projeto e pressione **F5** (ou **Executar Projeto**).
5. No menu principal, selecione **INICIAR TURNO** ou **CONTINUAR OPERAÇÕES**, conforme o histórico salvo.

A cena inicial configurada é `MainMenu.tscn`. Se ocorrer algum erro, confira a versão do editor e consulte o painel **Depurador** da Godot.

## 2. Como jogar

O objetivo de cada atendimento é entregar a quantidade solicitada de combustível com a proporção correta entre os componentes, respeitando o prazo.

1. **Receba a nave:** aguarde a aproximação e leia seu manifesto.
2. **Confira a fórmula:** identifique os componentes, a proporção e o volume em unidades de combustível (UF).
3. **Ajuste a mistura:** mova o controle deslizante ou use **Q/E** para regular o percentual do componente A. O componente B ocupa o percentual restante.
4. **Inicie a bomba:** clique no botão correspondente ou pressione **Espaço**.
5. **Monitore o abastecimento:** acompanhe o volume acumulado e o cronômetro.
6. **Pare a bomba:** desligue-a próximo do volume solicitado, a menos que tenha adquirido a válvula automática.
7. **Confira o resultado:** o jogo informa sucesso ou falha e atualiza os recursos da estação. Depois disso, outra nave chega.

**Exemplo de proporção:** um pedido de **3 partes do componente A para 1 parte do componente B** corresponde a **75% de A e 25% de B**.

A porcentagem de A pode ser calculada por:

```text
A (%) = A / (A + B) × 100
B (%) = 100 − A (%)
```

A interface também fornece feedback sobre a estabilidade da mistura. O sensor holográfico, quando comprado, acrescenta pistas sobre qual componente está em excesso, sem revelar a resposta numérica.

### Controles

| Controle | Ação |
|---|---|
| **Mouse** | Navegação, botões e ajuste da mistura |
| **Q** | Reduzir o componente A em 1 ponto percentual |
| **E** | Aumentar o componente A em 1 ponto percentual |
| **Shift + Q** | Reduzir o componente A em 5 pontos percentuais |
| **Shift + E** | Aumentar o componente A em 5 pontos percentuais |
| **Espaço** | Ligar ou desligar a bomba durante um atendimento |
| **Esc** | Pausar ou retomar a operação |
| **Setas direcionais** | Movimentar o personagem |

## 3. Regras, pontuação e consequências

Um atendimento é aprovado quando **ambas** as condições são atendidas:

- **Mistura:** erro de até **2 pontos percentuais** na proporção solicitada.
- **Volume:** diferença de até **3%** em relação ao volume pedido.

Os atendimentos concluídos dentro das tolerâncias recebem uma classificação de precisão **S, A, B ou C**. A qualidade da mistura e do volume determina a nota.

| Situação | Consequência prevista no código |
|---|---|
| Atendimento aprovado | **2 CR por UF** solicitada e **+5 pontos percentuais** de reputação |
| Conclusão com mais da metade do tempo restante | **+100 CR** adicionais |
| Acertos consecutivos no mesmo turno | Bônus progressivo de **25 CR** por acerto anterior, até **125 CR** |
| Contrato Elite concluído | **+150 CR** adicionais |
| Mistura ou volume fora da tolerância ao desligar a bomba | Penalidade de até **150 CR** e **−8 pontos percentuais** de reputação |
| Tempo esgotado ou transbordamento crítico | Penalidade de até **200 CR** e **−10 pontos percentuais** de reputação |

A expressão **“até”** aparece nas perdas de créditos porque o saldo não pode ficar negativo. A reputação permanece entre **0% e 100%**.

O **transbordamento crítico** acontece quando o volume alcança **115% do solicitado**. Contratos Elite podem surgir após pelo menos três atendimentos bem-sucedidos no turno e exigem proporções adicionais.

## 4. Oficina e melhorias

Todos os novos progressos começam com **0 créditos**, **50% de reputação** e **nenhuma melhoria**. Os créditos são obtidos por atendimentos bem-sucedidos e podem ser investidos na oficina.

| Melhoria | Custo | Benefício |
|---|---|---|
| **Bomba de alta vazão** | 500 / 1.000 / 1.500 CR, conforme o nível | Aumenta a vazão em três níveis |
| **Válvula automática** | 800 CR | Interrompe a bomba no volume solicitado |
| **Sensor holográfico** | 400 CR | Indica qual componente está em excesso ou quando a mistura está dentro da tolerância, **sem informar percentuais exatos** |

Os botões de compra ficam indisponíveis quando o jogador não tem saldo suficiente ou já alcançou o nível máximo. As melhorias compradas são preservadas no progresso salvo.

## 5. Progressão e salvamento

O jogo utiliza **salvamento local automático** para guardar créditos, reputação, melhorias e estatísticas, incluindo atendimentos concluídos, acertos, falhas e melhor sequência.

- **Continuar operações:** preserva o progresso acumulado de atendimentos anteriores.
- **Fechar e abrir o jogo:** recupera os dados persistidos no mesmo ambiente de execução.
- **Reiniciar progresso:** opção separada no menu principal, com confirmação, que redefine créditos para **0**, reputação para **50%**, remove as melhorias e zera as estatísticas.
- **Atendimento individual:** não há botão de “tentar novamente” para repetir uma nave e anular uma falha registrada.

**Limitação atual:** o estado de um atendimento em andamento (nave, cronômetro e volume parcial) não é persistido no arquivo de salvamento. Sair durante esse atendimento e voltar ao jogo pode iniciar outro pedido sem registrar automaticamente uma penalidade pelo abandono. Esse comportamento está identificado para evolução futura.

O salvamento é feito em `user://fueling_frontiers_save.cfg`, no diretório de dados do usuário gerenciado pela Godot.

## 6. Telas e navegação

| Tela | Função |
|---|---|
| **Menu principal** | Iniciar/continuar operações, acessar a oficina, consultar “Como Jogar”, verificar estatísticas, reiniciar progresso ou sair |
| **Gameplay** | Ler manifesto, preparar mistura, abastecer naves e consultar créditos, tempo e reputação |
| **Pausa** | Continuar turno, acessar oficina ou retornar ao menu principal |
| **Oficina** | Consultar custos e adquirir melhorias permanentes do progresso |

O painel de pausa foi ajustado para ficar centralizado na interface. **Pausar não faz o cronômetro do atendimento avançar.**

## 7. Desenvolvimento e limitações

A versão **0.9.3** já contém chegada e saída de naves, pedidos variáveis, controle da bomba, feedback da mistura, avaliações de precisão, contratos Elite, progressão econômica, oficina, áudio e salvamento local.

O projeto permanece em desenvolvimento. Entre os próximos pontos de atenção estão:

- Persistir ou tratar adequadamente os atendimentos interrompidos, evitando que abandonar uma operação elimine suas consequências.
- Refinar o balanceamento de dificuldade, ganhos e penalidades.
- Evoluir o tutorial e a variedade de contratos.
- Realizar e registrar testes independentes de instalação, jogabilidade e compatibilidade com sistemas operacionais.
- Preparar uma versão executável para demonstração, quando apropriado.

**Observação sobre validação:** as funcionalidades descritas foram conferidas na estrutura e no código do repositório; isso não substitui a execução de todos os cenários de teste na Godot.

## 8. Documentação complementar

- [**GDD — Game Design Document**](docs/GDD.md): visão do jogo, mecânicas, regras e planejamento.
- [**Checklist de validação**](docs/CHECKLIST_VALIDACAO.md): roteiro de testes de instalação e jogabilidade.
- [**Histórico de alterações**](docs/CHANGELOG_PROFISSIONAL.md): registro das evoluções do projeto.

## 9. Equipe

Projeto acadêmico desenvolvido por estudantes de **Engenharia de Software**:

- Júlio César Duarte da Rosa
- Rafael da Rocha da Silva
- Paulo Guilherme Richeski Padilha

**Atividade acadêmica:** N2 — Parte 1 — Entrega do projeto e da documentação.
