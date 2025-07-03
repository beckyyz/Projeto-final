# 📚 Documentação CRUD - Diário de Viagens

Este documento explica como usar todas as funcionalidades CRUD (Create, Read, Update, Delete) implementadas no app de Diário de Viagens.

## 🏗️ Arquitetura

O projeto está organizado em camadas:

### 📁 Estrutura de Diretórios
```
lib/
├── models/           # Modelos de dados
├── services/         # Lógica de negócio e CRUD
├── utils/           # Utilitários e exemplos
├── telas/           # Interfaces do usuário
└── widgets/         # Componentes reutilizáveis
```

### 🧩 Camadas de Serviços

1. **Serviços Básicos**: Operações CRUD independentes
   - `UserService` - Gerenciamento de usuários
   - `TripService` - Gerenciamento de viagens
   - `NoteService` - Gerenciamento de anotações
   - `PhotoService` - Gerenciamento de fotos
   - `StorageService` - Persistência local
   - `AuthService` - Autenticação

2. **Serviços Relacionais**: Operações CRUD com relações
   - `UserDataService` - CRUD completo para dados do usuário

## 🎯 Funcionalidades CRUD Implementadas

### 👤 **USUÁRIOS**

#### Operações Básicas (UserService)
```dart
// Criar usuário
final userId = await UserService.createUser(
  name: 'João Silva',
  email: 'joao@email.com',
);

// Obter usuário atual
final user = await UserService.getCurrentUser();

// Atualizar perfil
await UserService.updateCurrentUserProfile(
  name: 'João Santos',
  profileImagePath: '/path/to/image.jpg',
);

// Deletar usuário
await UserService.deleteCurrentAccount();
```

#### Operações Relacionais (UserDataService)
```dart
// Criar viagem para usuário atual
final tripId = await UserDataService.createTripForCurrentUser(
  title: 'Viagem ao Japão',
  destination: 'Tóquio',
  description: 'Aventura cultural',
);

// Obter viagens do usuário
final trips = await UserDataService.getCurrentUserTrips();

// Obter estatísticas completas
final stats = await UserDataService.getCurrentUserCompleteStats();
```

### ✈️ **VIAGENS**

```dart
// Criar viagem
final trip = TripService.createTrip(
  title: 'Aventura nos Alpes',
  destination: 'Suíça',
  description: 'Montanhas nevadas',
);
await TripService.addTrip(trip);

// Buscar viagens
final allTrips = await TripService.getAllTrips();
final searchResults = await TripService.searchTrips('montanha');

// Atualizar viagem
await TripService.updateTripData(
  tripId: trip.id,
  title: 'Novo título',
);

// Deletar viagem
await TripService.deleteTrip(trip.id);
```

### 📝 **ANOTAÇÕES**

```dart
// Criar anotação
final noteId = await NoteService.createNote(
  tripId: tripId,
  title: 'Dia 1',
  content: 'Chegamos ao hotel...',
  tags: ['dia1', 'hotel'],
);

// Buscar anotações
final tripNotes = await NoteService.getNotesByTripId(tripId);
final searchResults = await NoteService.searchNotes('hotel');
final tagNotes = await NoteService.getNotesByTag('dia1');

// Atualizar anotação
await NoteService.updateNoteContent(
  noteId: noteId,
  title: 'Novo título',
  content: 'Novo conteúdo',
);

// Deletar anotação
await NoteService.deleteNote(noteId);
```

### 📸 **FOTOS**

```dart
// Criar registro de foto
final photoId = await PhotoService.createPhoto(
  tripId: tripId,
  path: '/storage/photo.jpg',
  caption: 'Vista incrível',
  latitude: -23.5505,
  longitude: -46.6333,
);

// Buscar fotos
final tripPhotos = await PhotoService.getPhotosByTripId(tripId);
final recentPhotos = await PhotoService.getRecentPhotos();

// Atualizar foto
await PhotoService.updatePhotoCaption(photoId, 'Nova legenda');

// Deletar foto
await PhotoService.deletePhoto(photoId);
```

## 🔐 **AUTENTICAÇÃO**

```dart
// Registrar usuário
final success = await AuthService.register(
  email: 'user@email.com',
  password: '123456',
  name: 'Nome do Usuário',
);

// Fazer login
final loggedIn = await AuthService.login(
  email: 'user@email.com',
  password: '123456',
);

// Logout
await AuthService.logout();

// Verificar se está logado
final isLoggedIn = await AuthService.isLoggedIn();
```

## 📊 **ESTATÍSTICAS E RELATÓRIOS**

### Estatísticas de Usuário
```dart
final stats = await UserDataService.getCurrentUserCompleteStats();
// Retorna informações sobre viagens, anotações, fotos e atividade
```

### Estatísticas de Viagens
```dart
final tripStats = await TripService.getTripsStats();
// Total de viagens, destinos únicos, fotos, etc.
```

### Estatísticas de Anotações
```dart
final noteStats = await NoteService.getNotesStats();
// Total de anotações, tags mais usadas, etc.
```

### Estatísticas de Fotos
```dart
final photoStats = await PhotoService.getPhotosStats();
// Total de fotos, tamanho, localização, etc.
```

## 🔍 **BUSCA E FILTROS**

### Busca Global
```dart
// Buscar viagens por destino
final trips = await TripService.searchTrips('tokyo');

// Buscar anotações por conteúdo
final notes = await NoteService.searchNotes('hotel');

// Buscar usuários por nome
final users = await UserService.searchUsersByName('joão');
```

### Filtros Específicos
```dart
// Viagens recentes
final recentTrips = await TripService.getRecentTrips(limit: 5);

// Anotações por tag
final taggedNotes = await NoteService.getNotesByTag('planejamento');

// Fotos com localização
final photosWithLocation = await PhotoService.getPhotosWithLocation();
```

## 🧪 **EXEMPLOS DE USO**

### Exemplo Básico
```dart
import 'package:sua_app/utils/crud_examples.dart';

// Mostrar guia de uso
CrudExamples.mostrarGuiaDeUso();

// Executar exemplo de workflow completo
await CrudExamples.exemploWorkflowCompleto();
```

### Exemplo Completo com Usuário
```dart
import 'package:sua_app/utils/user_crud_examples.dart';

// Executar fluxo completo do usuário
await UserCrudExamples.exemploFluxoCompleto();

// Ou executar todos os exemplos
await UserCrudExamples.executarTodosExemplos();
```

## 🛡️ **TRATAMENTO DE ERROS**

Todos os métodos CRUD têm tratamento de erro adequado:

```dart
try {
  final trips = await UserDataService.getCurrentUserTrips();
  // Usar dados...
} catch (e) {
  print('Erro ao obter viagens: $e');
  // Tratar erro adequadamente
}
```

### Tipos de Erro Comuns
- `Exception('Usuário não está logado')` - Operação requer autenticação
- `Exception('Viagem não encontrada')` - ID inválido
- `Exception('Email já está em uso')` - Conflito de dados
- `Exception('Viagem não pertence ao usuário')` - Acesso negado

## 🔄 **FLUXO RECOMENDADO**

### 1. Inicialização do App
```dart
// Verificar se usuário está logado
final isLoggedIn = await UserService.isLoggedIn();
if (isLoggedIn) {
  // Ir para tela principal
} else {
  // Ir para tela de login
}
```

### 2. Criação de Dados
```dart
// Sempre criar dados através do UserDataService para manter relações
final tripId = await UserDataService.createTripForCurrentUser(...);
final noteId = await UserDataService.createNoteForCurrentUser(...);
final photoId = await UserDataService.createPhotoForCurrentUser(...);
```

### 3. Leitura de Dados
```dart
// Usar métodos específicos do usuário
final trips = await UserDataService.getCurrentUserTrips();
final notes = await UserDataService.getCurrentUserNotes();
final photos = await UserDataService.getCurrentUserPhotos();
```

### 4. Exclusão de Dados
```dart
// Deletar através do UserDataService para limpar relacionamentos
await UserDataService.deleteCurrentUserTrip(tripId);
await UserDataService.deleteCurrentUserNote(noteId);
await UserDataService.deleteCurrentUserPhoto(photoId);
```

## 📱 **INTEGRAÇÃO COM UI**

### Em Telas do Flutter
```dart
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Trip> _trips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    try {
      final trips = await UserDataService.getCurrentUserTrips();
      setState(() {
        _trips = trips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Mostrar erro para usuário
    }
  }

  // ... resto da implementação
}
```

## 🚀 **PRÓXIMOS PASSOS**

1. **Sincronização**: Implementar sync com backend
2. **Offline**: Melhorar funcionalidades offline
3. **Cache**: Implementar cache inteligente
4. **Notificações**: Adicionar notificações push
5. **Compartilhamento**: Permitir compartilhar viagens
6. **Backup**: Implementar backup automático

## 📞 **Suporte**

Para dúvidas sobre implementação:
1. Consulte os exemplos em `lib/utils/`
2. Verifique a documentação dos serviços
3. Use o método `mostrarGuiaDeUso()` para orientações rápidas

---

**Última atualização**: Julho 2025
**Versão**: 1.0.0
