# Fueling Frontiers: Mars Station

**Documento de design do jogo · Versão candidata 0.13.1-rc1 · Avaliação da mistura**

| Ficha | Descrição |
| --- | --- |
| Gênero | Simulação e gerenciamento de uma doca em 2D, para um jogador |
| Plataforma | Windows de 64 bits, com teclado e mouse |
| Projeto | Godot 4.6.1, GDScript e renderização de compatibilidade |
| Público | Estudantes de 10 a 18 anos e jogadores que gostam de desafios de lógica e precisão |
| Equipe | Júlio César Duarte da Rosa, Rafael da Rocha da Silva e Paulo Guilherme Richeski Padilha |

## História e objetivo

**O último posto de abastecimento de Marte.** Em 2187, uma falha na rede de distribuição deixa a Mars Station como o último posto capaz de atender as naves que cruzam Marte. A fila cresce em órbita e as missões perdem suas janelas de lançamento. O jogador acaba de ser contratado para assumir a doca.

O menu apresenta a crise. Na chegada da primeira nave, a ARIA informa o pedido de 100 UF, e o primeiro balão orienta o jogador a pegar o bico na bomba. Lia, Davi e Íris são as três opções de operador e usam os mesmos equipamentos. Atender bem os pilotos rende créditos para melhorar a bomba, instalar a válvula automática e adquirir o sensor de mistura.

A matemática aparece onde uma medida muda o resultado da operação. Uma proporção determina o ajuste do misturador, uma diferença de níveis determina quanto óleo repor e uma medida do encaixe determina qual vedação instalar.

## O primeiro atendimento

O menu oferece um guia de controles e um treino sem limite de tempo. ARIA acompanha uma encomenda de 100 UF na proporção 3 para 1. A nave precisa de três partes de A para uma de B. O jogador ajusta A para 75% e vê B completar os outros 25%.

Na doca, seis balões acompanham as ações de pegar o bico na bomba, encaixá-lo na nave, ajustar a mistura, ligar a bomba, observar o tanque e interromper o fluxo. A dica aponta para o equipamento ou o controle da etapa atual. O treino ajuda a parar no volume correto. Concluí-lo libera os contratos cronometrados.

## Um turno na doca

Cada turno tem seis contratos. Antes de ligar a bomba, o operador lê o manifesto, confere o prazo e trava a mangueira no bocal da nave. O medidor mostra quanto combustível já entrou. A vazão fina facilita parar perto da marca.

| Nave | Pedido e decisão |
| --- | --- |
| Cargueiro | Embarca 350 UF. O operador precisa reservar tempo para encher o tanque. |
| Resgate | Pede 150 UF e começa com prazo de 30 segundos. |
| Pesquisa | Pede 200 UF, exige concluir em vazão fina e admite um erro de mistura menor. |

A nave recebe o combustível quando o operador encerra o fluxo. Nos contratos, o jogo avalia a mistura, o desvio de volume e as condições do pedido. Um erro aparece no resultado em pontos percentuais ou em UF. Esgotar o prazo ou transbordar também pode comprometer o atendimento.

### Composição efetivamente entregue

Cada vez que a bomba injeta combustível, o tanque recebe a quantidade de A correspondente ao ajuste daquele momento. A porcentagem avaliada na entrega é **100 × volume acumulado de A ÷ volume total no tanque**. A vazão fina e a sujeira do filtro alteram o volume que entra por segundo. Mover o controle com o fluxo parado não muda o combustível já entregue. A classificação, o diagnóstico e a recompensa usam a composição acumulada. O contrato de Pesquisa aceita um desvio de até 1 ponto percentual; os demais, até 2. A tolerância de volume nos contratos é de 3%.

No treino sem cronômetro, o operador pode experimentar de novo. Quando encerra um tanque com pelo menos 97 UF e a composição está incorreta, a ARIA informa a porcentagem obtida, esvazia o tanque de treino e permite repetir sem cobrança. O novo salvamento guarda o volume de A e o volume total para retomar o atendimento.

### Resultado do teste solicitado na devolutiva docente

No cenário controlado de 100 UF na proporção 3:1, entraram 95 UF com 25% de A e as últimas 5 UF com 75% de A. Isso soma 23,75 + 3,75 = **27,50 UF de A**. O ajuste final indicava 75%, mas o tanque continha apenas **27,5% de A**.

| Cenário | Resultado observado |
| --- | --- |
| 95 UF a 25% e 5 UF a 75% na versão 0.13.0 | Aprovado indevidamente. |
| Mesma operação na candidata, incluindo salvar e retomar após 95 UF | Recusado por um desvio de 47,5 pontos percentuais, com o volume correto. |
| 100 UF a 75%, controle movido para 25% antes de encerrar, sem novo fluxo | Aprovado. |
| 50 UF a 50% em vazão rápida e 50 UF a 100% em vazão fina | Aprovado com 75% de A no tanque. |
| Válvula automática, ajuste de 75% e fluxo que ultrapassaria a meta | Parou em 100 UF, com 75 UF de A contabilizadas. |
| Treino com mistura errada, seguido de nova tentativa correta | O treino esvaziou o tanque e permitiu concluir sem penalidade. |

A verificação acima é automatizada. A observação de 3 ou 4 pessoas que nunca jogaram continua pendente. [Roteiro e ficha de observação](OBSERVACAO_PRIMEIRA_PARTIDA.md)

## Tempestade e filtro

Antes do segundo pouso do turno, o radar avisa que uma frente de poeira se aproxima. Fechar a comporta mantém a nave em órbita até a rajada passar e protege o filtro. Liberar o pouso antecipa a chegada, mas deixa a poeira entrar. As lâminas da porta atravessam o vão e o som do vento acompanha o fechamento.

A sujeira aparece nas grades e reduz a vazão. Ao inspecionar o filtro, o jogador limpa as áreas afetadas com a escova e confere o resultado no equipamento. Outra ocorrência, a pressão oscilante, exige ajustar o colar do filtro. As bases e colisões da bomba e do filtro delimitam o caminho que o personagem percorre com a mangueira.

## Manutenção da nave

A escotilha sinaliza um serviço ocasional e a bomba aguarda a conclusão do reparo. No terceiro atendimento dos turnos ímpares, o serviço é de óleo. No sexto dos turnos pares, é de vedação.

| Serviço | Como o jogador resolve |
| --- | --- |
| Óleo | Lê o nível atual e a marca de serviço, dosa o que falta e confere o visor. De 0,75 L até 1,50 L faltam 750 mL. |
| Vedação | Retira o anel rompido, lê as extremidades do encaixe em uma régua e escolhe o diâmetro correspondente. Entre as marcas de 5 mm e 25 mm cabe o anel de 20 mm. |

## Progresso, oficina e retomada

A estação começa com 0 créditos e 50% de reputação. No primeiro turno, a meta é aprovar três das seis naves. A meta sobe para quatro no segundo turno e para cinco a partir do terceiro. Atingi-la rende 150 créditos extras. A missão opcional alterna entre notas A ou S, cargueiros aprovados e acertos consecutivos. Cumpri-la rende mais 100 créditos e uma insígnia.

Ao fim do turno, o relatório reúne aprovações, saldo e variação de reputação. O jogador decide quando iniciar o próximo turno. Na oficina, os três níveis de vazão custam 500, 1.000 e 1.500 créditos. A válvula automática custa 800 e o sensor de mistura custa 400.

O progresso fica no computador que executou o jogo. O salvamento guarda o personagem, o treino, o turno, as compras e os dados do atendimento em andamento, incluindo mangueira, mistura, tempo e volume. Pausar permite consultar as opções sem consumir o prazo. Reiniciar o progresso pelo menu exige confirmação.

## Controles e distribuição

Setas movimentam o personagem. **F** interage com o equipamento próximo. **Q/E** ajustam a mistura e **Shift** amplia o passo. **Espaço** aciona a bomba, **V** alterna a vazão e **Esc** pausa ou fecha uma inspeção. No radar, **1** fecha a doca e **2** libera o pouso. Os painéis de inspeção também aceitam o mouse.

O pacote para Windows contém o executável com os dados do jogo embutidos e instruções curtas. O README reúne o download, a execução pelo código-fonte e um roteiro para a primeira partida. [Abrir o README](../README.md)
