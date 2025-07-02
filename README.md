# # 📱 Diário de Viagens - Travel Journal App

Um aplicativo Flutter completo para registrar e organizar suas viagens, com sistema de autenticação, galeria de fotos e muito mais!

## ✨ Funcionalidades

### 🔐 **Sistema de Autenticação**
- **Splash Screen Animada** com transições suaves
- **Onboarding** interativo para novos usuários
- **Tela de Login** com validação de email e senha
- **Tela de Registro** para novos usuários
- **Logout** seguro com limpeza de sessão
- **Persistência de sessão** - usuário permanece logado

### 🗺️ **Gerenciamento de Viagens**
- **Criar novas viagens** com título, destino e descrição
- **Visualizar detalhes** de cada viagem
- **Lista organizada** de todas as viagens
- **Navigation drawer** para acesso rápido

### 📸 **Galeria de Fotos**
- **Seleção múltipla** de fotos da galeria
- **Preview das fotos** antes de salvar
- **Galeria em grid** na tela de detalhes
- **Visualização em tela cheia** com zoom
- **Adicionar/remover fotos** de viagens existentes
- **Armazenamento local** das imagens

### 🎨 **Interface e UX**
- **Design Material** moderno e responsivo
- **Animações fluidas** e transições suaves
- **Validação de formulários** com feedback visual
- **Tooltips informativos** em todos os botões
- **Loading states** durante operações
- **Tratamento de erros** com mensagens claras

## 🚀 Como Executar

### Pré-requisitos
- Flutter SDK (versão 3.8.0 ou superior)
- Dart SDK
- Android Studio / VS Code
- Emulador Android ou dispositivo físico

### Instalação
1. Clone o repositório:
```bash
git clone https://github.com/seu-usuario/Projeto-final.git
cd Projeto-final
```

2. Instale as dependências:
```bash
flutter pub get
```

3. Execute o aplicativo:
```bash
flutter run
```

## 📦 Dependências

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  image_picker: ^1.0.4      # Seleção de fotos
  path_provider: ^2.1.1     # Gerenciamento de arquivos
  shared_preferences: ^2.2.2 # Persistência de dados
  lottie: ^3.1.0            # Animações (futura implementação)
```

## 🏗️ Estrutura do Projeto

```
lib/
├── main.dart                 # Arquivo principal com todas as telas
├── models/
│   └── trip.dart            # Modelo de dados da viagem
├── screens/
│   ├── splash_screen.dart   # Tela de splash animada
│   ├── onboarding_screen.dart # Tela de apresentação
│   ├── login_screen.dart    # Tela de login
│   ├── register_screen.dart # Tela de registro
│   ├── home_screen.dart     # Tela principal
│   ├── trip_details.dart    # Detalhes da viagem
│   └── photo_view.dart      # Visualização de fotos
└── assets/
    └── images/              # Imagens do aplicativo
```

## 🔄 Fluxo do Aplicativo

1. **Splash Screen** → Verificação do status do usuário
2. **Onboarding** → Para usuários primeiro acesso
3. **Login/Registro** → Autenticação do usuário
4. **Home** → Lista de viagens
5. **Detalhes** → Visualização e edição da viagem
6. **Fotos** → Galeria e visualização

## 🎯 Funcionalidades Futuras

- [ ] Integração com APIs de mapas
- [ ] Backup na nuvem
- [ ] Compartilhamento de viagens
- [ ] Geolocalização automática
- [ ] Filtros e busca avançada
- [ ] Exportação para PDF
- [ ] Tema escuro/claro
- [ ] Multi-idiomas

## 🔧 Configuração de Permissões

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

### iOS (ios/Runner/Info.plist)
```xml
<key>NSCameraUsageDescription</key>
<string>Este app precisa acessar a câmera para tirar fotos das viagens</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Este app precisa acessar a galeria para selecionar fotos das viagens</string>
```

## 🐛 Solução de Problemas

### Erro de permissões
- Verifique se as permissões estão configuradas corretamente
- No Android, aceite as permissões quando solicitado

### Problemas com fotos
- Certifique-se de que o dispositivo tem espaço suficiente
- Verifique se a galeria tem fotos disponíveis

### Erro de dependências
```bash
flutter clean
flutter pub get
```

## 📱 Screenshots

[Adicione screenshots do aplicativo aqui]

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👨‍💻 Desenvolvedor

Desenvolvido com ❤️ usando Flutter

---

**Nota**: Este é um projeto educacional/demonstrativo. Para uso em produção, considere implementar:
- Autenticação real com backend
- Criptografia de dados sensíveis
- Validações de segurança adicionais
- Testes automatizados

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
