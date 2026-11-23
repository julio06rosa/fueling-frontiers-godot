# Fueling Frontiers: Mars Station

**Fueling Frontiers: Mars Station** é um jogo 2D de simulação e gerenciamento desenvolvido em **Godot**, com **GDScript**, como projeto acadêmico do curso de Engenharia de Software.

O jogador assume a operação de uma estação de abastecimento em Marte. A cada atendimento, uma nave chega com um manifesto de carga: dois componentes de combustível, uma proporção exigida, um volume solicitado e um tempo limite. É preciso interpretar os dados, preparar a mistura e interromper o abastecimento no momento certo.

O desempenho determina os **créditos**, a **reputação** e a possibilidade de adquirir melhorias para a estação. Os atendimentos são contínuos: não há uma opção para reiniciar individualmente uma nave após um erro.

## Como jogar

Abra o `project.godot` na Godot **4.6.1** e pressione **F5**. No Windows, você também pode extrair o ZIP do repositório e executar `Jogar_no_Windows.cmd`.

Escolha Lia, Davi ou Íris no menu e selecione **Treinar com a ARIA**. O primeiro pedido é de 100 UF na proporção de três partes de A para uma de B. Pegue a mangueira na bomba, conecte o bico sob a nave e regule o misturador para 75% de A. Observe o tanque para saber quando parar a bomba.

| Controle | Ação |
| --- | --- |
| Setas | Andar pela doca |
| F | Pegar ou conectar a mangueira, inspecionar o filtro ou abrir a escotilha de manutenção |
| Q / E | Ajustar a mistura |
| V | Alternar entre vazão rápida e fina |
| Espaço | Ligar ou parar a bomba |
| Esc | Pausar o turno ou fechar a inspeção |

## Turnos na estação

Cada turno tem seis atendimentos. Durante uma tempestade, fechar a comporta protege o filtro e faz a nave aguardar. Liberar o pouso permite recebê-la na poeira, mas pode exigir a limpeza das grades antes do abastecimento. Algumas naves também precisam de óleo ou de um anel de vedação. Use o visor ou a régua da escotilha para escolher a dose ou a peça.

Ao fim do turno, o relatório mostra os resultados. Os créditos podem ser usados na oficina para melhorar a bomba, instalar a válvula automática ou adquirir o sensor de mistura. O jogo salva o progresso localmente e permite retomar um atendimento em andamento.

## Documentação

- [Guia de controles, manutenção e missões](LEIA-ME.txt)
- [Documento de design do jogo](docs/GDD.md)
- [Checklist de validação](docs/CHECKLIST_VALIDACAO.md)
- [Histórico de desenvolvimento](docs/CHANGELOG_PROFISSIONAL.md)

## Equipe

Júlio César Duarte da Rosa, Rafael da Rocha da Silva e Paulo Guilherme Richeski Padilha.
