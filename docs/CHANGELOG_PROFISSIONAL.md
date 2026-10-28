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
