# Copilot Instructions for Guardião de Senhas

## Visão Geral do Projeto
- Aplicativo Flutter para gerenciamento seguro de senhas, com suporte a biometria, backup em PDF e múltiplas plataformas (Android, iOS, Web, Desktop).
- Estrutura principal em `lib/`:
  - `models/`: Modelos de dados (usuário, senha, etc.)
  - `screens/`: Telas da aplicação (registro, login, alteração de senha, etc.)
  - `services/`: Serviços de autenticação, backup, biometria, etc.
  - `theme/`: Temas e estilos customizados.
  - `utils/`: Utilitários e funções auxiliares.

## Fluxos e Convenções
- O fluxo de registro e apresentação inicial é dividido em etapas, com animações e possibilidade de vídeos curtos.
- A senha mestra, nome e pergunta de segurança são definidos no registro e validados no login.
- Mudança de senha mestra deve ser reconhecida em todo o app.
- Biometria é usada para senhas confidenciais e pode ser ativada/desativada nas configurações.
- Backups são feitos em PDF, com suporte a importação/exportação e funcionamento no navegador.
- A opção “Limpar dados” só apaga informações após 30 dias.

## Workflows de Desenvolvimento
- **Build/Test:**
  - Use `flutter pub get` para instalar dependências.
  - Use `flutter run` para rodar o app.
  - Use `flutter test` para rodar testes (se existirem).
- **Debug:**
  - Debug padrão do Flutter funciona para todas as plataformas suportadas.
- **Assets:**
  - Imagens e fontes em `assets/` (subpastas: `animation/`, `icon/`, `logo/`, `fonts/`).
  - Para customizar splash/launch screen, edite os assets em `ios/Runner/Assets.xcassets/`.

## Padrões Específicos
- Use animações e transições suaves entre etapas do registro e telas principais.
- Trate erros de campos vazios no registro e login.
- Sempre valide a senha mestra e a pergunta de segurança antes de permitir acesso.
- Siga o padrão de temas claros/escuros definidos em `theme/`.
- Utilize serviços de autenticação e backup via classes em `services/`.

## Integrações e Dependências
- Dependências Flutter declaradas em `pubspec.yaml`.
- Integração com biometria via plugins (ex: `local_auth`).
- Backup/exportação em PDF via plugins (ex: `printing`).

## Exemplos de Arquivos-Chave
- `lib/screens/change_password_screen.dart`: Tela de alteração de senha mestra.
- `lib/services/`: Serviços de autenticação, backup, biometria.
- `assets/animation/`: Imagens de apresentação e registro.

## Observações
- Documentação adicional pode ser vinculada à central de ajuda do app.
- Ajustes de cores e temas devem ser feitos conforme padrões definidos.

---

Se necessário, consulte o `README.md` para detalhes de etapas de teste e próximos passos.
