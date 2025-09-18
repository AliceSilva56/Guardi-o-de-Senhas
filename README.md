# 📖 Guardião de Senhas – Roadmap

💙 Últimas Atualizações 16/09/2025

- Configuração e implementação da Perguntas de segurança.

- Verificação se os arquivos existentes são realmente necessários.

- Configuração da pasta para os arquivos de backup.

- Implementação da biometria no modo confidencial.

💙 Últimas Atualizações 15/09/2025

- Verificar/Concertar o campo de  pergunta no registro flow, está com pouco espaço, Colocar tratativa de erros especifica, para campos vazios e etc. (Melhorar)

- Biometria aplicada com sucesso.

- Após o primeiro contato do usário ao aplicativo o App vai para tela de login.

💙 Últimas Atualizações 11/09/2025

- tive que concertar o salvamento da adição de senhas.

💙 Últimas Atualizações 10/09/2025

- Atualização do importar, para que o app receba as senhas do PDF.

- O backup importar e exportar esta funcionando.

- Configuração da funcionalidade que mostra o último backup realizado.

- Configuração das funcionalidades de backup por PDF, todas as senhas aparecem com suas informações passadas pelo usuário.

💙 Últimas Atualizações 09/09/2025

- Configuração do backup por PDF (Mas o PDF está indo vazio, verificar qual é o problema)

💙 Últimas Atualizações 05/09/2025

- Concerte os erros do backup e exportação para pdf.

💙 Últimas Atualizações 04/08/2025

- Tentei adicionar o backup, mas só dava erro na importação desistir, e coloquei para só exportar por pdf com as informações de nome, e-mail, senhas salvas no app(modo normal e modo confidencial).


💙 Últimas Atualizações 02/08/2025

- Colocar o a visualização de senha em todos os campos que pede senhas

- Fazer a troca de tema funcionar.

- Backup importar e exportar não esta funcionando de verdade, fazer funcionar.

💙 Últimas Atualizações 01/08/2025

- Limpar dados - quero que apareça uma mensagem dizendo que somente após 30 dias os dados (Nome, e-mail, senhas salvas no app(modo normal e modo confidencial)) serão completamente apagados e realmente apagar após 30 dias.

-  Melhorar o register_screen.dart (mantido simples).

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

---

💛 (EM DESENVOLVIMENTO) 🎬 Fluxo de Apresentação & Registro

1. Desenvolver tela de apresentação inicial. (Já desenvolvida)

2. Melhorar a tela de registro por etapas: ( Já desenvolvida mas melhorar)

Adicionar animações (intro + registro).

Possibilidade de trocar imagens por vídeos curtos para cada etapa.

---

# ✅ Etapas de Teste – Guardião de Senhas
🔐 Registro e Login

 ✅ Testar fluxo de registro com senha mestra + pergunta de segurança.

 ✅ Verificar validação de campos vazios e mensagens de erro.

 ✅ Após primeiro acesso, confirmar se vai para a tela de login.

 ✅ Conferir se o app chama o usuário pelo nome registrado (registro e main_screen).

 Verificar se as configuração recebe a senha mestra, nome, pergunta é passada pelo registro flow.

# 🔑 Senhas (Normal e Confidencial)

 Adicionar senha no modo normal e conferir salvamento.

 Adicionar senha no modo confidencial (com categorias) e verificar se não aparece no modo normal.

 Testar ver, editar e excluir senha nos dois modos.

 Testar biometria no modo confidencial.

 Conferir se mudança de senha mestra é reconhecida corretamente.

# 📂 Backup e PDF

 Exportar backup em PDF e verificar se todas as senhas aparecem.

 Importar backup por PDF e checar se dados retornam ao app.

 Conferir mensagem e registro do “último backup realizado”.

 Testar backup também no navegador (web), verificando download do PDF.

 Validar configuração da pasta de backup no dispositivo.

# 🎨 Interface e Experiência

 Conferir tamanho dos avatares no celular.

 Verificar se fontes/frases estão legíveis (modo normal e confidencial).

 Ativar modo confidencial → checar se cores/vibe mudam corretamente.

 Trocar tema claro/escuro e validar se funciona em todas as telas.

# ⚙️ Configurações e Extras

 Testar tela de alteração de senha mestra.

 Conferir se a opção “Limpar dados” só apaga após 30 dias.

 Validar se ao perguntar sobre biometria aparecem opções corretas.

 Confirmar que não existe mais a função de mudar background.

 Verificar se a navegação não duplica mais a main_screen.dart.
