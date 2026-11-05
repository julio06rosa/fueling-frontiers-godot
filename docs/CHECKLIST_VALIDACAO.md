# Checklist de validação — Atividade 001 (N2, parte 1)

**Projeto:** Fueling Frontiers: Mars Station · **Versão documentada:** 0.9.3  
**Objetivo:** orientar o teste de instalação e jogabilidade usando apenas o README, sem ajuda da equipe.  
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

## 7. Conferência dos requisitos da atividade

| O que a atividade pede | Onde encontrar |
|---|---|
| Repositório do projeto | [GitHub](https://github.com/julio06rosa/fueling-frontiers-godot) |
| Nome e descrição do jogo | Início do README |
| Programa, versão e requisitos | README — Informações do projeto e Como instalar e executar |
| Orientações para baixar e abrir | README — Como instalar e executar |
| Instruções para jogar | README — Como jogar, Controles e Regras e pontuação |
| GDD atualizado | [docs/GDD.md](GDD.md), com link também no README |
| Teste sem orientação dos desenvolvedores | Seções 1 a 6 deste checklist — ainda pendente de preenchimento |

## 8. Modelo de texto para a entrega (usar após a conferência do projeto)

> Repositório: https://github.com/julio06rosa/fueling-frontiers-godot  
> Guia de instalação, execução e uso: README.md, na página inicial do repositório.  
> GDD atualizado: `docs/GDD.md` — também acessível pelo link presente no README.  
> Versão do projeto: 0.9.3.

**Antes de enviar a atividade:** preencher o checklist com os resultados dos testes e conferir se os links do README e do GDD estão acessíveis.
