📌 Guardião de Senhas – Roadmap de Correções e Novas Funcionalidades

Última revisão: Organização das cores do app


---

🐞 Correções Necessárias

[ ] Verificar bug na inicialização: Quando o app inicia, ele parece entrar duas vezes na main_screen.dart. Ao clicar na seta, ele sai como se tivesse sido carregado em duplicidade.

Investigar se o problema está no Navigator, rotas ou no ciclo de vida do widget.




---

🖥 Tela de Apresentação e Registro

1. Tela de Apresentação

[ ] Melhorar o design da tela inicial, deixando mais amigável, chamativa e coerente com a vibe do app.

[ ] Integrar animações sutis e transições suaves.



2. Tela de Registro

[ ] Exibir no primeiro contato com o app.

[ ] Criar um fluxo visualmente integrado com a tela de apresentação.





---

📂 main_screen.dart

3.1 Estrutura

[ ] Garantir que a tela principal seja carregada apenas uma vez na inicialização.


3.2 Modo Confidencial

[ ] Ao ativar:

Alterar completamente a cor e o estilo visual do aplicativo, mas mantendo o estilo.

Exibir apenas senhas confidenciais.



3.3 Configurações

[ ] Implementar:

Autenticação biométrica (digital).

Perguntas de segurança para recuperação de acesso.

Troca de imagem de fundo com integração aos assets registrados no pubspec.yaml.




---

🗂 Prioridade de Implementação

1. Corrigir o bug de carregamento duplo da main_screen.dart.


2. Desenvolver nova tela de apresentação + registro amigável e integrada.


3. Implementar Modo Confidencial com tema diferenciado.


4. Adicionar segurança extra (biometria + perguntas).


5. Suporte para mudança de background.