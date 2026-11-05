# Registro de alterações

## Revisão documental — 05/11/2026 (projeto 0.9.3)

- README e GDD alinhados ao saldo inicial e de reinício de **0 CR**, preservando o progresso já salvo.
- Sensor holográfico documentado com **pistas qualitativas**, sem percentuais da mistura ideal.
- Documentado o ajuste de centralização do painel de pausa.
- Esclarecida a progressão contínua e a ausência de botão para repetir apenas um atendimento.
- Registrada a limitação: sair de uma nave ativa ainda pode descartar o atendimento sem penalidade automática.
- Checklist atualizado com cenários de regressão para as alterações recentes.
- **Testes independentes ainda pendentes**; mudanças de documentação não equivalem a validação prática na Godot.

## v0.9.3 — Pacote de avaliação acadêmica (N2)

- README completo: instalação, execução, controles, regras, limitações e links reais.
- GDD atualizado em `docs/GDD.md`.
- Checklist independente em `docs/CHECKLIST_VALIDACAO.md`.
- Correção do fluxo de transbordamento crítico, evitando avaliação e penalidade duplicadas.
- Proteção contra registro repetido de falhas por nave.
- Nenhuma alteração de recursos gráficos, layout ou economia foi necessária nesta atualização.
- **Validação pendente:** abrir no Godot 4.7 e executar os testes do checklist.

# Changelog profissional

## v0.9.2 — Integração visual consolidada

- Reconstruído o menu principal diretamente em `MainMenu.tscn`; o visual novo não depende mais de criação dinâmica por script.
- Adicionados à cena principal: painel de operações, status da estação, estatísticas, tutorial, confirmação de reset e identidade visual de Marte.
- Oficina de upgrades redesenhada diretamente em `UpgradeMenu.tscn`.
- Elementos centrais do HUD profissional foram adicionados diretamente em `Gameplay.tscn`.
- Mantidos contratos especiais, classificação por precisão, atalhos, pausa, estatísticas e salvamento local.
- Removidos scripts de apresentação antigos que ficaram obsoletos após a migração para cenas estáticas.
- Tipagem endurecida nos scripts novos para reduzir erros de inferência no Godot 4.7.

## v0.9.1

- Correção do erro de inferência da variável `radius` no antigo protótipo de backdrop procedural.

## v0.9.0

- Primeira rodada de evolução de produto e gameplay.
