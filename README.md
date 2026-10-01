# Fueling Frontiers: Mars Station

> 🚧 **Status:** em desenvolvimento

**Fueling Frontiers: Mars Station** é um jogo 2D desenvolvido em **Godot** com **GDScript**. O jogador atua em uma estação de abastecimento em Marte e precisa preparar misturas de combustível, controlar o volume abastecido e atender diferentes naves antes que o tempo acabe.

O projeto foi desenvolvido para praticar lógica de programação, organização de scripts, estados de jogo, interface, regras de negócio e sistemas de progressão.

## 🎮 Principais funcionalidades

- Sistema de chegada, atendimento, abastecimento e partida de naves.
- Misturas de combustível com diferentes proporções entre componentes.
- Controle de volume com margem de tolerância para o abastecimento.
- Sistema de créditos e reputação com recompensas e penalidades.
- Limite de tempo por atendimento.
- Sistema de upgrades com níveis e custos progressivos.
- Upgrade de velocidade da bomba de combustível.
- Válvula automática para interromper o abastecimento no volume correto.
- HUD auxiliar para indicar a proporção ideal da mistura.
- Contratos Elite com proporções mais avançadas e bônus adicionais.
- Sistema de sequência de acertos com recompensas progressivas.
- Feedback visual de volume, estabilidade da mistura e tempo restante.
- Efeitos sonoros e trilha ambiente gerados programaticamente.
- Visual das naves, personagem e elementos da estação desenhados pelo próprio Godot.

## 🛠️ Tecnologias e conceitos

- **Godot Engine 4.x**
- **GDScript**
- Programação orientada a objetos
- Herança de scripts
- Máquina de estados
- Eventos e sinais
- UI / HUD
- Regras de negócio e validações
- Sistema de economia e progressão
- Áudio procedural
- Git e GitHub

## 🧠 Como funciona o jogo

Cada nave chega à estação com requisitos diferentes de combustível. O jogador precisa:

1. Identificar a proporção solicitada entre os componentes.
2. Ajustar a mistura pelo painel de controle.
3. Ativar a bomba de combustível.
4. Monitorar o volume do tanque e o tempo restante.
5. Interromper o abastecimento próximo ao volume solicitado.

Um atendimento correto aumenta os **créditos** e a **reputação**. Mistura incorreta, volume inadequado, transbordamento ou tempo esgotado geram penalidades.

## ⬆️ Sistema de upgrades

Os créditos obtidos durante as partidas podem ser usados para melhorar a estação:

- **Velocidade da bomba:** aumenta a vazão de combustível em níveis progressivos.
- **Válvula automática:** interrompe o abastecimento ao atingir o volume alvo.
- **HUD auxiliar:** exibe a proporção ideal dos componentes.

## ⭐ Mecânicas adicionais

Após o avanço no jogo, podem surgir **Contratos Elite**, que utilizam proporções mais complexas e oferecem bônus extras.

O projeto também possui um sistema de **sequência de acertos**, recompensando atendimentos corretos consecutivos.

## 🎮 Controles

- **Setas direcionais:** movimentação do personagem.
- **Mouse:** interação com botões, controles de mistura e menus.

## ▶️ Como executar

### Pré-requisitos

- Godot Engine 4.x compatível com o projeto.

### Execução

1. Clone este repositório:

```bash
git clone https://github.com/SEU-USUARIO/fueling-frontiers-godot.git
```

2. Abra o **Godot**.
3. Importe o arquivo `project.godot`.
4. Abra o projeto.
5. Execute com **F5** para iniciar pelo menu principal.

Também é possível executar diretamente a cena `Gameplay.tscn` pelo editor.

## 📁 Estrutura principal

```text
fueling-frontiers-godot/
├── project.godot
├── MainMenu.tscn
├── MainMenu.gd
├── Gameplay.tscn
├── Gameplay.gd
├── GameplayEnhanced.gd
├── GameManager.gd
├── Player.tscn
├── Player.gd
├── PlayerVisual.gd
├── ShipVisual.gd
├── SoundManager.gd
├── UpgradeMenu.tscn
├── UpgradeMenu.gd
├── UpgradePresentation.gd
└── docs/
```

## 🔄 Estado atual

O projeto já possui uma base jogável e os principais sistemas estão implementados. Ele continua em desenvolvimento, com foco em melhorias de gameplay, interface, balanceamento e acabamento visual.

## 🗺️ Próximos passos

- Revisar e balancear economia, tempo e dificuldade.
- Ampliar a variedade de contratos e naves.
- Melhorar feedbacks visuais e animações.
- Criar tela de resultados/estatísticas.
- Adicionar persistência de progresso.
- Preparar uma versão executável para demonstração.

## 📚 Objetivo do projeto

Este projeto faz parte do meu portfólio de desenvolvimento e tem como objetivo aplicar, na prática, conceitos de programação, lógica, arquitetura de jogos, interfaces e organização de código utilizando Godot e GDScript.
