# Reboot_Remoto
Gerenciador de Reinício Remoto (Powershell)

⚠️ Projeto experimental criado como parte dos meus estudos em Powershell.
Ainda em evolução, mas já utilizado internamente para automatizar reinícios de múltiplas máquinas na empresa.

Descrição

Este script permite gerenciar reinícios remotos de várias máquinas de forma simples e prática, com interface gráfica:

Agendamento de reinícios para qualquer horário.
Reinício imediato, quando necessário.
Cancelamento de reinícios já agendados.
Monitoramento do status de cada máquina (Aguardando, Reiniciando, Concluído, Offline, Erro).

Ele foi desenvolvido para automatizar tarefas repetitivas e reduzir o risco de esquecimentos ou erros durante a manutenção de PCs.

Funcionalidades
Interface amigável em Windows Forms.
Suporte a nomes de host ou IPs.
Atualização em tempo real do status de cada máquina.
Verificação rápida de máquinas offline sem travar a aplicação.
Reinícios executados de forma assíncrona, mantendo a UI responsiva.
Como usar
Abra o PowerShell com permissões administrativas.

Execute o script:

.\RRemote.ps1
Na interface:
Digite o nome ou IP da máquina no campo "Máquina".
Escolha a data/hora para reinício ou use o botão "Reiniciar Agora".
Você pode adicionar várias máquinas na lista e iniciar todos os agendamentos de uma vez.
Reinícios podem ser cancelados a qualquer momento.
Exemplo de uso

Imagine que você precisa reiniciar 10 computadores de uma equipe após uma atualização de software.
Com este script, você pode:

Adicionar todas as máquinas à lista.
Programar reinícios para um horário estratégico (ex.: fora do expediente).
Acompanhar o progresso em tempo real e cancelar qualquer reinício se necessário.

Tudo sem precisar ficar manualmente acessando cada PC.

Observações
Este é um projeto experimental, ainda em desenvolvimento.
Requer PsExec para executar os reinícios remotamente.
Testado em ambiente Windows com permissões administrativas.
Use com cuidado em ambientes de produção; é recomendado testar primeiro em máquinas não críticas.
Licença

Este projeto é open-source para fins de estudo e aprendizado.
Sinta-se à vontade para adaptar, melhorar ou sugerir alterações.
