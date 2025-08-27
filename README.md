# 📖 Guardião de Senhas – Roadmap


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

- 💛 Colocar para reconhecer a mudança de senha do modo confidencial

- ❤️ Verificar se os arquvos existentes são realmente necessários.

- 💚 Talvez tirar a entrada por Biometria(Pensar melhor sobre a implementação).

- 💛 Concertar o campo de  pergunta no registro flow, está com pouco espaço, Colocar tratativa de erros especifica, para campos vazios e etc.

- 💛 Mudar o tamanho dos avatar do perfil pois está grande demais no celular

- 💛 No celular diminuir o tamanho da frase ou da letra pois não da para ver (modo normal e confidencial).
 
- 💛 Ligar a troca de senhas do modo confidencia

- 💛 Fazer a troca de tema funcionar.

- ❤️ Backup importar e exportar não esta funcionando de verdade, fazer funcionar.

- ❤️ Limpar dados - quero que apareça uma mensagem dizendo que somente após 30 dias os dados (Nome, e-mail, senhas salvas no app(modo normal e modo confidencial)) serão completamente apagados e realmente apagar após 30 dias.


- 💛 Melhorar o register_screen.dart (mantido simples).

- 💚 Colocar para mostrar as mesma categorias do modo normal no modo confidencial também(Talvez).

- ❤️ Após o primeiro contato do usário ao aplicativo deve ir para tela de login, acredito que vamos fazer ela receber o usuário com boas-vindas de voltas e mas algo com mais personalização.

---

❤️ (COMEÇAR) 🔧 Correções Necessárias

Bug de navegação: ao iniciar, o app mostra uma seta e sai, como se entrasse duas vezes na main_screen.dart.

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



# 💛 Desenvolvimento da documentação do projeto Guardião de senhas

📖 Estrutura da Documentação – Guardião de Senhas

- 1. Capa e Identificação

    Nome do projeto: Guardião de Senhas

    Logo (se já tiver definida)

    Autor(es) / Equipe de desenvolvimento

    Data e versão do documento

- 2. Resumo Executivo (Abstract)

    Pequeno parágrafo explicando o que é o app, para quem é e qual problema resolve.

    Exemplo: “O Guardião de Senhas é um aplicativo seguro desenvolvido em Flutter/Dart para Android e Web, que organiza senhas em pastas, protege informações com criptografia e oferece um modo confidencial.”

- 3. Introdução

    Contexto: por que esse app é necessário? (Problema de segurança, dificuldade de organizar senhas, etc.)

    Objetivo principal do projeto.

    Público-alvo (usuários comuns, empresas, estudantes, etc.)

- 4. Levantamento de Requisitos

    A) Funcionais

    Criar pastas de senhas.

    Adicionar/editar/excluir senhas.

    Modo confidencial (senha extra/biometria).

    Backup/restauração de dados.

    Busca e filtros.

    B) Não funcionais

    Criptografia local.

    Performance responsiva.

    Interface intuitiva e moderna.

    Suporte multiplataforma (Android + Web).

- 5. Tecnologias Utilizadas

    Linguagem: Dart

    Framework: Flutter

    Banco local: Hive

    Segurança: Criptografia AES/biometria

    Arquitetura: (ex: MVC, MVVM ou Clean Architecture, se aplicou)

    Controle de versão: Git/GitHub

    Design: Figma (se usou)

- 6. Arquitetura e Estrutura do Projeto

    Diagrama de pastas (ex: lib/screens, lib/services, lib/models etc).

    Explicação da separação de responsabilidades.

    Fluxo do app (tela inicial → seleção de pasta → lista de senhas → modo confidencial → configurações).

    Diagrama simples de caso de uso ou fluxo do usuário.

- 7. Design e Tema

    Paleta de cores escolhida (ex: azul profundo, violeta, dourado – Dark Tech).

    Fontes e estilo visual.

    Printscreen/mockups das telas principais:

    Login/entrada

    Tela principal (pastas)

    Tela de senhas

    Tela confidencial

    Configurações

- 8. Implementação

    Breve descrição de como cada módulo funciona (ex: PasswordService, SettingsService, MainScreen, etc).

    Explicação sobre como a criptografia/localStorage foram implementados.

    Integração com biometria (caso aplicável).

    Diferença entre modo normal e modo confidencial.

- 9. Testes

    Estratégia de testes (unitários, integração, manuais).

    Principais cenários testados:

    Criar senha e salvar.

    Entrar no modo confidencial.

    Recuperar backup.

    Acessar versão web.

- 10. Resultados

    O que o app já entrega.

    Principais conquistas do desenvolvimento (segurança, multiplataforma, interface clara).

    Prints do app em execução (Android + Web).

- 11. Limitações

    O que ainda não foi implementado.

    Restrições técnicas (ex: só funciona offline, backup limitado, etc.).

- 12. Trabalhos Futuros / Melhorias

    Sincronização em nuvem.

    Compartilhamento seguro.

    Extensão para navegador.

    Notificações de expiração de senha.

- 13. Conclusão

    Retomar o objetivo inicial.

    Mostrar como o app atingiu o propósito.

    Ressaltar o diferencial: segurança local, criptografia, interface Dark Tech e simplicidade.

- 14. Referências

    Documentações oficiais (Flutter, Hive, criptografia).

    Artigos/links que ajudaram no desenvolvimento.

    Repositório GitHub do projeto.