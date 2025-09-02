# 📖 Guardião de Senhas – Roadmap

💙 Últimas Atualizações 02/08/2025

- Colocar o a visualização de senha em todos os campos que pede senhas

- 💛 Fazer a troca de tema funcionar.

- ❤️ Backup importar e exportar não esta funcionando de verdade, fazer funcionar.

💙 Últimas Atualizações 01/08/2025

- ❤️ Limpar dados - quero que apareça uma mensagem dizendo que somente após 30 dias os dados (Nome, e-mail, senhas salvas no app(modo normal e modo confidencial)) serão completamente apagados e realmente apagar após 30 dias.

- 💛 Melhorar o register_screen.dart (mantido simples).

💙 Últimas Atualizações 29/08/2025

- Mudei o tamanho dos avatar do perfil pois está grande demais no celular.

- No celular diminui o tamanho da frase ou da letra pois não da para ver (modo normal e confidencial).

- Coloquei para reconhecer a mudança de senha do modo confidencial.

- Bug de navegação: ao iniciar, o app mostra uma seta e sai, como se entrasse duas vezes na main_screen.dart.

- Coloquei para mostrar as mesma categorias do modo normal no modo confidencial e as demais funcionalidades(Ver senha, editar/excluir).

- Apaguei a funcionalidade de mudar background.


💙 Últimas Atualizações 27/08/2025

- Atualiza README.md com novas etapas e melhorias;

- Implementa salvamento da senha mestra no fluxo de registro.


💙 Últimas Atualizações 26/08/2025

- Atualização do código para que a tela de login, registro flow reconheça a mudança de senhas pelo settings service

- Criação do arquivo change_passaword_screen para dar o comando de mudar a senha mestra

💙 Últimas Atualizações 25/08/2025

- Criação do settings_services e algumas funcionalidas


💙 Últimas Atualizações 24/08/2025

- Acertar o campo de categoria do modo confidencial

- Concertar a tela que pergunta se quer biometria, pois esta somente com o 'não agora'

- Criação do arquivo para salvar as funcionalidades do settings


💙 Últimas Atualizações 23/08/2025

Fiz o sistema receber as coisas com enter também(Login, registro flow, registro)

Coloquei cor pra o modo claro na frase


💙 Últimas Atualizações 22/08/2025

Coloquei para o sistema receber e chamar o usuário pelo nome fornecido, no registro e também na tela principal

(CONCLUIDO) No Modo Confidencial

Alterei completamente as cores e vibe do app quando ativado, exibi apenas senhas confidenciais.

(CONCLUIDO)👤 Personalização do Usuário

Após o registro, chamar o usuário pelo nome informado.

Exibir o nome também dentro da main_screen.dart.

(Novo)

Concertei o erro das senhas confidenciais esta mostrando no modo normal e vice e versa, e mostrar as categorias no modo confidencial

 ---


# Próximas Etapas (❤️) Importante, (💛) Necessária e (💚) Opcional

Concertar erro do backup
- Erro ao criar backup
MissingPluginException(No implementation found for method getApplicationDocumentsDirectory on channel plugins.flutter.io/path_provider)
- Erro ao selecionar o arquivo: LatelinitializationError: field '_instance' has not been initialized.

- ❤️ Verificar se os arquivos existentes são realmente necessários.

- 💚 Talvez tirar a entrada por Biometria(Pensar melhor sobre a implementação).

- 💛 Verificar/Concertar o campo de  pergunta no registro flow, está com pouco espaço, Colocar tratativa de erros especifica, para campos vazios e etc.

- ❤️ Após o primeiro contato do usário ao aplicativo deve ir para tela de login, acredito que vamos fazer ela receber o usuário com boas-vindas de voltas e mas algo com mais personalização.

---

---

💛 (EM DESENVOLVIMENTO) 🎬 Fluxo de Apresentação & Registro

1. Desenvolver tela de apresentação inicial. (Já desenvolvida)

2. Melhorar a tela de registro por etapas: ( Em desenvolvimento)

Adicionar animações (intro + registro).

Possibilidade de trocar imagens por vídeos curtos para cada etapa.

---

❤️ (EM DESENVOLVIMENTO) 🛡️ Main Screen

- 3.1 Configurações

- Adicionar funcionalidades:

- Perfil

- Biometria (impressão digital).

- Perguntas de segurança.

- Backup

- Opção para trocar a imagem do background dinamicamente.

