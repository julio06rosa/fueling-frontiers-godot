# Fueling Frontiers: Mars Station

**Fueling Frontiers: Mars Station** é um jogo 2D desenvolvido na Godot Engine, utilizando GDScript, como parte de um projeto acadêmico do curso de Engenharia de Software.

O jogador é responsável pelo abastecimento de naves em uma estação espacial localizada em Marte. Cada nave possui um pedido específico, com uma proporção de combustível, uma quantidade necessária e um tempo limite para concluir o atendimento.

O objetivo é realizar os abastecimentos corretamente, ganhar créditos, melhorar os equipamentos da estação e conseguir atender pedidos cada vez mais difíceis.

**Informações do projeto:**
- Engine: Godot 4.7
- Linguagem: GDScript
- Gênero: simulação e gerenciamento
- Plataforma: computador
- Versão atual: 0.9.3
- Status: em desenvolvimento

## Como instalar e executar

Para jogar, é necessário ter a Godot Engine 4.7 instalada. O projeto não precisa de banco de dados ou instalação de bibliotecas adicionais.

**1. Baixar o projeto**

Acesse o repositório no GitHub:

https://github.com/julio06rosa/fueling-frontiers-godot

Clique em **Code > Download ZIP** e extraia os arquivos em uma pasta do computador.

Também é possível clonar o repositório usando Git:

\`\`\`bash
git clone https://github.com/julio06rosa/fueling-frontiers-godot.git
\`\`\`

**2. Abrir na Godot**

1. Abra a Godot Engine 4.7.
2. Clique em **Importar** no gerenciador de projetos.
3. Selecione o arquivo \`project.godot\` dentro da pasta do jogo.
4. Abra o projeto no editor.

**3. Iniciar o jogo**

Com o projeto aberto, pressione **F5** ou clique em **Executar Projeto**.

A tela inicial será carregada e você poderá começar uma partida selecionando **Iniciar Turno**.

Caso o jogo apresente algum erro ao iniciar, confira se a versão da Godot está correta e consulte a aba de depuração do editor.

## Como jogar

O funcionamento do jogo é baseado no atendimento de naves que chegam à estação de abastecimento.

Cada nave informa a quantidade de combustível necessária, a proporção entre os componentes A e B e o tempo disponível.

Para realizar um atendimento:

1. Inicie uma partida pelo menu principal.
2. Aguarde a chegada da nave.
3. Observe a proporção de combustível solicitada.
4. Ajuste a mistura utilizando o controle na tela ou as teclas Q e E.
5. Ligue a bomba de combustível.
6. Acompanhe a quantidade abastecida e o tempo restante.
7. Desligue a bomba quando atingir o volume solicitado.
8. Confira o resultado do atendimento.

Por exemplo, se uma nave solicitar uma mistura de 3 partes de A para 1 parte de B, será necessário ajustar a mistura para **75% de A e 25% de B**.

É importante controlar tanto a mistura quanto o volume abastecido. Um erro pode causar perda de créditos e reputação.

## Controles

| Tecla | Função |
|---|---|
| Mouse | Navegar pelos menus e utilizar os controles na tela |
| Q | Diminuir a porcentagem do combustível A |
| E | Aumentar a porcentagem do combustível A |
| Shift + Q | Diminuir a porcentagem em 5 pontos |
| Shift + E | Aumentar a porcentagem em 5 pontos |
| Espaço | Ligar ou desligar a bomba |
| Esc | Pausar ou retomar o jogo |
| Setas direcionais | Movimentar o personagem |

## Regras e pontuação

Para concluir um atendimento com sucesso, o jogador precisa respeitar a proporção e a quantidade de combustível solicitadas.

O jogo permite uma margem de erro de **2 pontos percentuais na mistura** e **3% no volume abastecido**.

Os atendimentos são avaliados de acordo com a precisão, podendo receber as classificações S, A, B ou C.

Ao concluir um atendimento corretamente, o jogador recebe créditos e aumenta sua reputação. Erros, atrasos e abastecimentos acima do limite geram penalidades.

Também existem contratos mais difíceis, que oferecem recompensas maiores.

## Melhorias da estação

Os créditos recebidos podem ser utilizados na oficina para comprar melhorias.

| Melhoria | Função |
|---|---|
| Bomba de alta vazão | Aumenta a velocidade do abastecimento |
| Válvula automática | Interrompe o abastecimento ao atingir o volume solicitado |
| Sensor holográfico | Mostra a proporção ideal da mistura |

As melhorias ajudam o jogador a realizar os atendimentos com mais facilidade e precisão.

## Salvamento do progresso

O jogo salva automaticamente informações como créditos, reputação, melhorias adquiridas e estatísticas dos atendimentos.

No menu principal, também existe a opção **Reiniciar Progresso**, que permite começar novamente com os valores iniciais.

## Desenvolvimento do projeto

O jogo ainda está em desenvolvimento. Nesta versão, já é possível realizar atendimentos, utilizar melhorias, acompanhar a reputação da estação e salvar o progresso.

Algumas funcionalidades ainda podem receber ajustes, principalmente em relação ao balanceamento, à variedade dos contratos e à experiência de jogo.

Atualmente, o projeto é disponibilizado pelo código-fonte para execução na Godot, sem um executável independente.

## Documentação

Além deste README, o repositório contém documentos que apresentam mais detalhes sobre o projeto:

- [GDD — Game Design Document](docs/GDD.md): planejamento do jogo, mecânicas, regras e funcionalidades.
- [Checklist de validação](docs/CHECKLIST_VALIDACAO.md): etapas para conferir a instalação e o funcionamento do jogo.
- [Histórico de alterações](docs/CHANGELOG_PROFISSIONAL.md): principais mudanças realizadas durante o desenvolvimento.

## Integrantes

Projeto desenvolvido por acadêmicos do curso de **Engenharia de Software**:

- Júlio César Duarte da Rosa
- Rafael da Rocha da Silva
- Paulo Guilherme Richeski Padilha

**Atividade:** N2 — Parte 1 — Entrega do projeto e da documentação.
