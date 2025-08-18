📖 Guardião de Senhas – Roadmap

🟢 Última atualização

Adicionadas imagens do Elfo Guardião na tela de intro e registro.

Textos do registro agora têm mais personalidade e narrativa.

O aplicativo inicia perguntando se o usuário já possui conta:

Sim → vai para tela de Login.

Não → vai para tela de Cadastro.




---

🔧 Próximas tarefas

🐞 Correções

Verificar o motivo de o app, ao iniciar, mostrar uma seta de navegação e depois sair (como se entrasse duas vezes na main_screen.dart).

Observação: parece que isso ocorre apenas quando se entra pelo cadastro → confirmar e corrigir.


Ajustar a definição das cores de texto nas telas:

registro_guardiao_flow.dart

elf_intro_screen.dart
→ No modo claro o texto deve ser preto.
→ No modo escuro o texto deve ser branco.




---

👤 Personalização do Usuário

Chamar o usuário pelo nome informado após o registro.

Exibir esse nome dentro da main_screen.dart.




---

🎬 Fluxo de Apresentação & Registro

1. Criar uma tela de apresentação inicial.

Adicionar animações (intro + registro).

Se possível, criar vídeos curtos para cada etapa do registro.

Ajustar fundo do registro:

Ou usar fundos similares às imagens do elfo.

Ou remover completamente os fundos das imagens (transparência).






---

🛡️ Main Screen

3.1 Modo Confidencial

Quando ativado, o app deve mudar totalmente de cor e vibe.

Exibir apenas as senhas confidenciais.


3.2 Configurações

Implementar:

Biometria (impressão digital / reconhecimento facial).

Perguntas de segurança.


Adicionar opção para o sistema receber e trocar a imagem do background.



---

🔐 Tela de Login

4.1 Adicionar funcionalidade para mostrar/ocultar senha no campo de login.


---