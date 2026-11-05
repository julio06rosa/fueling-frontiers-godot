# Fueling Frontiers: Mars Station

**Jogo 2D de gerenciamento e precisão em uma estação de abastecimento espacial**  
**Versão do projeto:** `0.9.3` · **Engine:** Godot 4.7 · **Linguagem:** GDScript · **Situação:** protótipo jogável em desenvolvimento

> **Entrega acadêmica — Atividade 001 (N2, parte 1).** Este guia foi escrito para que uma pessoa que não participou do desenvolvimento consiga obter o projeto, iniciá-lo e compreender suas regras. O projeto é disponibilizado como código-fonte Godot; **não há executável pronto incluído nesta versão**.

## 1. Apresentação do jogo

Em **Fueling Frontiers: Mars Station**, você opera uma doca de abastecimento em Marte. Naves chegam com solicitações que especificam uma **proporção entre dois componentes de combustível**, um **volume-alvo** e um **prazo**. Sua tarefa é preparar a mistura, ligar a bomba e interromper o abastecimento na quantidade correta antes que o tempo se esgote.

Atendimentos bem-sucedidos rendem créditos e aumentam a reputação da estação. Erros e atrasos geram penalidades. Os créditos podem ser usados para melhorar os equipamentos, tornando os próximos contratos mais fáceis de administrar.

**Gênero:** simulação e gerenciamento com desafio de precisão.  
**Formato:** jogo 2D, individual, para teclado e mouse.  
**Ciclo principal:** receber contrato → interpretar requisitos → ajustar mistura → abastecer → avaliar resultado → melhorar a estação → atender outra nave.

## 2. Requisitos para executar

| Requisito | Orientação |
|---|---|
| **Engine** | **Godot Engine 4.7**, edição padrão (GDScript), preferencialmente a mesma versão usada na configuração do projeto |
| **Sistema operacional** | Computador com Windows, Linux ou macOS e uma instalação compatível da Godot 4.7; a execução nessas plataformas deve ser validada em cada ambiente |
| **Entrada** | Teclado e mouse |
| **Resolução de referência** | 1280 × 720 pixels (configuração do projeto) |
| **Linguagem** | GDScript, integrado à Godot; não requer Python, Node.js ou compilador C# |
| **Git** | Opcional. Necessário apenas se desejar clonar via terminal; também é possível baixar um ZIP |
| **Internet** | Necessária para obter Godot e baixar o projeto; não há serviço on-line exigido pela lógica do jogo |

**Onde obter a engine:** <https://godotengine.org/download>.

> **Compatibilidade:** o arquivo `project.godot` indica recursos da linha **4.7**. Não é recomendável abrir o projeto em versões anteriores e salvar seus arquivos sem antes criar uma cópia. Não foram informadas especificações mínimas de hardware nem realizados testes de todas as plataformas nesta documentação.

## 3. Como baixar o projeto

Escolha **uma** das alternativas abaixo.

### Opção A — Clonar com Git

1. Instale o Git, caso não o possua: <https://git-scm.com/downloads>.
2. Abra um terminal na pasta em que deseja guardar o jogo.
3. Execute:

```bash
git clone https://github.com/julio06rosa/fueling-frontiers-godot.git
cd fueling-frontiers-godot
```

### Opção B — Baixar sem Git

1. Acesse <https://github.com/julio06rosa/fueling-frontiers-godot>.
2. Clique em **Code → Download ZIP**.
3. Extraia o conteúdo em uma pasta de sua preferência.
4. Verifique se a pasta extraída contém **`project.godot`** e **`MainMenu.tscn`**.

> **Importante:** para baixar a versão avaliada, utilize a branch **`main`** depois que o grupo incorporar a documentação e as alterações finais. Se estiver verificando uma proposta de alteração em outra branch, selecione-a antes de baixar.

## 4. Instalação e configuração do ambiente

O projeto **não possui dependências externas declaradas** além da própria Godot. Não há pacotes adicionais, banco de dados, API ou credenciais para configurar.

1. Baixe e abra a **Godot 4.7**.
2. No **Gerenciador de Projetos** da Godot, escolha **Importar**.
3. Localize a pasta clonada ou extraída e selecione o arquivo **`project.godot`**.
4. Confirme a importação e abra o projeto no editor.
5. Permita que a Godot finalize a leitura/importação inicial dos recursos, se solicitado.
6. Verifique se o editor mostra a cena principal do projeto sem mensagens impeditivas de erro.

A cena inicial configurada é **`res://MainMenu.tscn`**, definida no arquivo `project.godot`.

## 5. Como iniciar e executar o jogo

### Execução pelo editor (recomendada)

1. Com o projeto aberto na Godot, pressione **F5** ou clique em **Executar Projeto** (ícone de reprodução no canto superior direito).
2. Aguarde a janela do jogo abrir na tela inicial **Fueling Frontiers: Mars Station**.
3. No menu principal, escolha **Iniciar Turno** (ou **Continuar Operações**, caso já exista progresso).
4. Acompanhe a chegada da nave e siga as instruções da seção **7. Como jogar uma partida**.

**Se o F5 não funcionar:** confirme se a versão da Godot é compatível e se o arquivo `project.godot` foi importado. Consulte a aba **Saída / Depurador** para ler o erro completo. Não é necessário abrir uma cena avulsa para iniciar: use **Executar Projeto (F5)**.

### Execução pelo terminal (opcional)

Com o executável da Godot acessível pelo comando `godot` e o terminal aberto na pasta do projeto:

```bash
godot --path .
```

Dependendo do sistema, o executável pode ter outro nome; nesse caso, substitua `godot` pelo nome/caminho instalado. **A execução pelo editor é o procedimento de referência para esta entrega.**

## 6. Menu principal

| Opção | Função |
|---|---|
| **Iniciar Turno / Continuar Operações** | Abre a doca e inicia o atendimento de naves |
| **Oficina de Upgrades** | Permite comprar melhorias com os créditos disponíveis |
| **Como Jogar** | Mostra um painel com orientações resumidas sobre mistura, bomba e atalhos |
| **Reiniciar Progresso** | Exibe confirmação para apagar os dados salvos e começar com valores iniciais |
| **Sair** | Fecha o jogo |

O menu também mostra informações da estação: créditos, reputação, posição/patente e estatísticas de atendimento. O painel **Como Jogar** é uma ajuda rápida, **não substitui este guia completo**.

## 7. Como jogar uma partida — passo a passo

1. **Inicie o turno.** No menu, clique em **Iniciar Turno**. Uma nave aparecerá e se aproximará da doca.
2. **Leia o manifesto da nave.** Observe a fórmula solicitada, o volume em **UF** (unidades de combustível) e o tempo restante.
3. **Converta a proporção em porcentagem.** Se o pedido for **3 partes de A para 1 parte de B**, o total é 4 partes: **A = 75%** e **B = 25%**.
4. **Ajuste a mistura.** Use o controle deslizante na tela ou as teclas **Q / E** para definir a porcentagem do componente A. O percentual de B é calculado automaticamente como `100% − A`.
5. **Espere a nave atracar** e **ative a bomba** pelo botão na interface ou com **Espaço**.
6. **Monitore o tanque e o cronômetro.** A bomba abastece continuamente enquanto estiver ligada. A faixa correta de volume admite uma tolerância de **3% para mais ou para menos** do valor solicitado.
7. **Desligue a bomba** próximo ao volume-alvo usando novamente o botão ou **Espaço**. O jogo avalia imediatamente a mistura e o volume. Se possuir a melhoria da válvula automática, o bombeamento é interrompido no alvo.
8. **Leia o resultado.** Em caso de acerto, você recebe créditos e reputação; em caso de falha, há penalidades. A nave parte e a próxima chega automaticamente.
9. **Evolua a estação.** Use a **Oficina de Upgrades** no menu para comprar melhorias entre os atendimentos.

### Exemplo prático

**Pedido hipotético:** proporção **2:1** e volume de **150 UF**.

- Componente A: `2 ÷ (2 + 1) × 100 ≈ 66,7%`.
- Componente B: `1 ÷ (2 + 1) × 100 ≈ 33,3%`.
- Volume aceito: de **145,5 UF a 154,5 UF** (tolerância de ±3%).
- A mistura possui tolerância de **±2 pontos percentuais** em relação à porcentagem ideal de A.

O exemplo explica as regras; os pedidos reais são gerados pelo jogo e variam a cada nave.

## 8. Controles

| Entrada | Ação |
|---|---|
| **Mouse** | Navegar pelos menus, arrastar o ajuste de mistura e clicar no botão da bomba |
| **Q** | Diminuir a porcentagem do componente A em **1 ponto percentual** |
| **E** | Aumentar a porcentagem do componente A em **1 ponto percentual** |
| **Shift + Q** | Diminuir a porcentagem do componente A em **5 pontos percentuais** |
| **Shift + E** | Aumentar a porcentagem do componente A em **5 pontos percentuais** |
| **Espaço** | Ligar ou desligar a bomba quando uma nave estiver disponível para atendimento |
| **Esc** | Abrir/fechar a tela de pausa durante o gameplay |
| **Setas direcionais** | Movimentar o personagem operador no cenário |

**Observação:** a movimentação do operador não é um requisito para usar o painel de abastecimento. As principais ações do jogo são feitas pela interface e pelos atalhos. Durante a pausa, o cronômetro do atendimento não avança.

## 9. Regras, resultados e progressão

### Regras de acerto

Um atendimento é considerado **bem-sucedido quando, ao desligar a bomba**, as duas condições são verdadeiras:

- **Mistura correta:** diferença de até **2 pontos percentuais** em relação à porcentagem ideal do componente A.
- **Volume correto:** diferença de até **3% do volume solicitado**.

O tempo para cada atendimento é limitado. Deixar o tempo terminar ou ultrapassar o limite crítico de abastecimento (15% acima da meta) causa falha. A qualidade do atendimento correto pode receber classificação **S, A, B ou C**, de acordo com a precisão obtida.

### Recompensas e penalidades

- Atendimento bem-sucedido: recompensa em créditos proporcional ao volume, possível bônus por rapidez, aumento da reputação e possível bônus por sequência.
- Contratos **Elite**: podem aparecer após progresso no turno e oferecem maior dificuldade de proporção e bônus de créditos.
- Falha ao validar mistura/volume: perda de créditos e reputação.
- Tempo esgotado ou transbordamento crítico: penalidade mais severa.

**Valores definidos no código atual:** sucesso aumenta a reputação em **5 pontos percentuais**; falha comum reduz **8 pontos** e penaliza **150 créditos**; prazo esgotado/erro crítico reduz **10 pontos** e penaliza **200 créditos**. Os bônus e cálculos completos estão descritos no [GDD](docs/GDD.md).

### Vitória, derrota e continuidade

A versão atual trabalha com **vitória ou derrota por atendimento**, não com uma campanha fechada. Você progride ao manter bons resultados, acumular créditos, aumentar a reputação, adquirir melhorias e ampliar estatísticas da estação. **Ainda não há uma tela final de vitória global ou uma condição definitiva de fim de jogo**.

## 10. Melhorias disponíveis

| Melhoria | Efeito | Custo atual |
|---|---|---|
| **Bomba de alta vazão** | Aumenta a velocidade em **20 UF/s** a cada nível, até o nível 3 | **500 / 1.000 / 1.500 créditos** |
| **Válvula automática** | Interrompe o abastecimento ao atingir o volume solicitado | **800 créditos** |
| **Sensor holográfico / HUD auxiliar** | Mostra a porcentagem ideal da mistura no manifesto | **400 créditos** |

A velocidade-base da bomba é **40 UF/s**. As compras são salvas localmente.

## 11. Salvamento e reinício

O jogo registra automaticamente **créditos, reputação, upgrades e estatísticas** em um arquivo local criado pela Godot:

```text
user://fueling_frontiers_save.cfg
```

`user://` é um diretório de dados da aplicação gerenciado pela engine e **não** a pasta do repositório. Para começar uma nova estação, use **Reiniciar Progresso** no menu e confirme a operação. **Atenção:** o reinício apaga o progresso salvo da estação.

## 12. Limitações conhecidas da versão 0.9.3

- O jogo é entregue como **projeto da Godot**, sem instalador ou arquivo executável distribuído no repositório.
- O painel **Como Jogar** oferece instruções resumidas no menu; não há um tutorial guiado passo a passo dentro do atendimento.
- Ainda não existe **campanha com objetivo final, tela de vitória global ou tela de game over definitivo**.
- O conteúdo de contratos, naves e eventos ainda pode ser ampliado, assim como o balanceamento de economia e dificuldade.
- Não há dados de testes documentados para todas as versões de sistema operacional ou configurações de hardware; a entrega demanda uma validação prática no ambiente da avaliação.
- **Ponto para teste de regressão:** conferir o comportamento do transbordamento crítico para garantir que uma falha não desconte penalidades duplicadas.

Esses limites não impedem a proposta principal de atender naves e evoluir a estação, mas devem ser considerados na avaliação da versão atual.

## 13. Estrutura principal do repositório

```text
fueling-frontiers-godot/
├── project.godot               # Configuração da engine e cena de entrada
├── MainMenu.tscn / MainMenu.gd  # Cena e lógica do menu
├── Gameplay.tscn               # Cena de atendimento
├── Gameplay.gd                 # Regras básicas de abastecimento
├── GameplayEnhanced.gd         # Contratos, atalhos, classificação e pausa
├── GameManager.gd              # Economia, reputação, upgrades e saves
├── Player.tscn / Player.gd     # Personagem operador
├── PlayerVisual.gd             # Desenho auxiliar do personagem
├── ShipVisual.gd               # Representação visual das naves
├── UpgradeMenu.tscn / .gd      # Oficina de melhorias
├── SoundManager.gd             # Sons gerados por código
├── README.md                   # Este guia de instalação e uso
└── docs/
    ├── GDD.md                  # Documento de design do jogo
    ├── CHECKLIST_VALIDACAO.md  # Roteiro de teste independente
    ├── CHANGELOG_PROFISSIONAL.md
    └── NOTAS_DESENVOLVIMENTO.txt
```

## 14. Documentação complementar

- **[GDD — Game Design Document](docs/GDD.md):** visão, regras, sistemas, interface, fluxo de jogador e evolução planejada.
- **[Checklist de validação](docs/CHECKLIST_VALIDACAO.md):** roteiro reproduzível de instalação, execução e teste por alguém de fora da equipe.
- **[Changelog](docs/CHANGELOG_PROFISSIONAL.md):** registro das principais alterações de versões anteriores.

## 15. Equipe e contexto acadêmico

**Desenvolvedores identificados nos créditos atuais do menu:** Júlio César Duarte da Rosa e Rafael da Rocha da Silva.  
**Curso:** Engenharia de Software.  
**Atividade:** N2 — Parte 1 / Atividade 001 — Entrega do projeto e da documentação.

> **Nota de validação:** este material foi preparado a partir da leitura dos arquivos da versão `0.9.3` no GitHub. A documentação e seus comandos devem passar por um teste prático com Godot antes da entrega definitiva; não se afirma aqui que esse teste já foi realizado.
