# Checklist de validação — Atividade 001 (N2, parte 1)

**Projeto:** Fueling Frontiers: Mars Station · **Versão documentada:** 0.9.3  
**Objetivo:** comprovar que alguém fora da equipe consegue instalar e jogar usando apenas o README.  
**Status deste arquivo:** **roteiro pendente de execução**, não é um relatório de testes concluídos.

## 1. Registro da execução

Preencher **após realizar os testes**:

| Campo | Preenchimento |
|---|---|
| Nome de quem testou | ____________________ |
| Data e hora | ____________________ |
| Sistema operacional e versão | ____________________ |
| Godot (versão completa) | ____________________ |
| Branch / commit testado | ____________________ |
| Resultado geral | [ ] Aprovado  [ ] Aprovado com ressalvas  [ ] Reprovado |

> Recomendação: o teste principal deve ser feito por uma pessoa que **não participou da implementação**, idealmente usando uma pasta nova ou outro computador.

## 2. Verificação do repositório e arquivos

- [ ] O endereço <https://github.com/julio06rosa/fueling-frontiers-godot> abre sem pedir permissão indevida.
- [ ] A branch de entrega contém `project.godot`, `MainMenu.tscn` e os scripts necessários.
- [ ] O `README.md` está atualizado na branch que será enviada à professora.
- [ ] O GDD foi incorporado em `docs/GDD.md` e o link no README funciona.
- [ ] Este roteiro está disponível em `docs/CHECKLIST_VALIDACAO.md`.
- [ ] O repositório não contém arquivos temporários obrigatórios para rodar nem exige configuração secreta.

## 3. Instalação independente

- [ ] O testador obteve o projeto por `git clone` ou **Code → Download ZIP**.
- [ ] O arquivo `project.godot` foi localizado.
- [ ] O projeto foi importado e aberto com **Godot 4.7**.
- [ ] A importação não apresentou erro impeditivo.
- [ ] **F5** abriu a tela inicial do jogo.

## 4. Uso e mecânicas

- [ ] **Iniciar Turno** abre a cena de atendimento.
- [ ] Uma nave chega à doca e exibe proporção, volume e cronômetro.
- [ ] O slider ou as teclas **Q/E** ajustam a mistura.
- [ ] **Shift+Q/E** modifica a mistura em passos de 5 pontos percentuais.
- [ ] **Espaço** e o botão da interface ligam/desligam a bomba.
- [ ] Um abastecimento correto gera mensagem de sucesso e recompensa.
- [ ] Um abastecimento incorreto gera mensagem de falha e penalidade.
- [ ] **Esc** pausa e retoma o jogo; o temporizador não avança enquanto pausado.
- [ ] A tela **Como Jogar** abre e fecha corretamente no menu.
- [ ] **Oficina de Upgrades** abre; uma compra válida atualiza os créditos.
- [ ] Ao fechar e reabrir o jogo, os dados salvos continuam disponíveis.
- [ ] **Reiniciar Progresso** exige confirmação e realmente restaura os dados iniciais.

## 5. Testes de limite e regressão

- [ ] Parar a bomba fora da margem de ±3% de volume resulta em falha.
- [ ] Usar uma mistura com erro superior a 2 pontos percentuais resulta em falha.
- [ ] Deixar o cronômetro zerar resulta na penalidade prevista.
- [ ] **Teste crítico:** encher acima de 115% e confirmar se há **uma única penalidade** por atendimento. O comportamento foi corrigido no código desta versão; confirmar em teste real que não ocorre desconto duplicado.
- [ ] Verificar que não é possível comprar upgrade sem créditos suficientes.
- [ ] Validar que o jogo não depende de uma máquina que já possuía cache ou arquivos locais do desenvolvedor.

## 6. Resultado e evidências

| ID | Cenário | Resultado (OK/Falha/Pendente) | Evidência / observação |
|---|---|---|---|
| T01 | Clone ou ZIP e importação | Pendente | |
| T02 | Tela inicial e abertura por F5 | Pendente | |
| T03 | Atendimento correto | Pendente | |
| T04 | Atendimento incorreto | Pendente | |
| T05 | Atalhos e pausa | Pendente | |
| T06 | Upgrade, save e reinício | Pendente | |
| T07 | Transbordamento crítico | Pendente | |

**Sugestão de evidências:** capturas da tela inicial, do manifesto, da tela após um acerto e da oficina de upgrades; se houver erro, capturar a aba **Depurador** e registrar etapas de reprodução.

## 7. Matriz de atendimento aos critérios da professora

| Exigência da atividade | Onde localizar |
|---|---|
| 1. Link de repositório atualizado e público | README, seção 3; GitHub |
| 2. Guia escrito de instalação, execução e uso | README, seções 2 a 12 |
| 3. GDD atualizado e caminho | `docs/GDD.md`, referenciado no README, seção 14 |
| Nome e descrição do jogo | README, seção 1 |
| SO, programas e versões | README, seção 2 |
| Clonar / baixar | README, seção 3 |
| Dependências e ambiente | README, seção 4 |
| Comandos / opções da engine | README, seção 5 |
| Início de partida e controles | README, seções 6 a 8 |
| Objetivos, regras, sucesso/falha e progressão | README, seções 7, 9 e 10 |
| Limitações / não implementado | README, seção 12; GDD, seções 13 e 14 |
| Teste por terceiro sem explicação oral | Seções 1 a 6 deste checklist: **executar e preencher** |

## 8. Texto de entrega (usar somente depois da revisão e merge)

> Repositório: https://github.com/julio06rosa/fueling-frontiers-godot  
> Guia de instalação, execução e uso: README.md, na página inicial do repositório.  
> GDD atualizado: `docs/GDD.md` — também acessível pelo link presente no README.  
> Versão entregue: 0.9.3.

**Atenção:** este arquivo é material de apoio para revisão. A documentação só estará disponível publicamente nos links indicados **depois de ser enviada ao GitHub e incorporada à branch de entrega**.
