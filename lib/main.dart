import 'package:flutter/material.dart';

void main() {
  runApp(const TravelJournalApp());
}

class TravelJournalApp extends StatelessWidget {
  const TravelJournalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Diário de Viagens',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: const Color(0xFFf0f4f8),
      ),
      home: const TravelJournalHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Trip {
  final String id;
  final String title;
  final String destination;
  final DateTime date;
  final String description;
  final String imagePath;

  Trip({
    required this.id,
    required this.title,
    required this.destination,
    required this.date,
    required this.description,
    required this.imagePath,
  });
}

class TravelJournalHome extends StatefulWidget {
  const TravelJournalHome({super.key});

  @override
  State<TravelJournalHome> createState() => _TravelJournalHomeState();
}

class _TravelJournalHomeState extends State<TravelJournalHome> {
  final List<Trip> _trips = [
    Trip(
      id: '1',
      title: 'Férias de Verão',
      destination: 'Fernando de Noronha',
      date: DateTime(2023, 7, 15),
      description: 'Primeira visita às praias paradisíacas',
      imagePath: 'assets/images/noronha.jpeg',
    ),
    Trip(
      id: '2',
      title: 'Aventura na Montanha',
      destination: 'Everest',
      date: DateTime(2023, 5, 22),
      description: 'Trilhas incríveis e paisagens deslumbrantes',
      imagePath: 'assets/images/everest.jpeg',
    ),
  ];

  // Controladores para os campos do formulário
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    // Limpar os controladores quando o widget for destruído
    _titleController.dispose();
    _destinationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _addNewTrip() {
    // Limpar os campos ao abrir o modal
    _titleController.clear();
    _destinationController.clear();
    _descriptionController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nova Viagem',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _destinationController,
                decoration: const InputDecoration(
                  labelText: 'Destino',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Validar se os campos obrigatórios foram preenchidos
                  if (_titleController.text.isEmpty || 
                      _destinationController.text.isEmpty) {
                    // Mostrar mensagem de erro
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Por favor, preencha o título e o destino'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Criar nova viagem
                  final newTrip = Trip(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _titleController.text,
                    destination: _destinationController.text,
                    date: DateTime.now(),
                    description: _descriptionController.text,
                    imagePath: 'assets/images/default.jpeg', // Imagem padrão
                  );

                  // Adicionar à lista e atualizar a interface
                  setState(() {
                    _trips.add(newTrip);
                  });

                  // Fechar o modal
                  Navigator.pop(ctx);
                },
                child: const Text('Salvar Viagem'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _viewTripDetails(Trip trip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailsScreen(trip: trip),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diário de Viagens'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        // Botão personalizado para abrir o drawer com tooltip
        leading: Builder(
          builder: (context) => Tooltip(
            message: 'Abrir menu de navegação',
            child: IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add),
            onPressed: () {},
            tooltip: 'Nova Anotação',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Minhas Viagens',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  // Ícone com tooltip para voltar
                  Tooltip(
                    message: 'Voltar para tela principal',
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            ..._trips.map((trip) => ListTile(
                  leading: const Icon(Icons.flight_takeoff),
                  title: Text(trip.title),
                  subtitle: Text(trip.destination),
                  onTap: () {
                    Navigator.pop(context); // Fecha o drawer
                    _viewTripDetails(trip);
                  },
                )),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Adicionar Nova Viagem'),
              onTap: () {
                Navigator.pop(context); // Fecha o drawer
                _addNewTrip();
              },
            ),
          ],
        ),
      ),
      body: _trips.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma viagem registrada!\nClique no + para adicionar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: _trips.length,
              itemBuilder: (ctx, index) {
                final trip = _trips[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(trip.imagePath),
                    ),
                    title: Text(
                      trip.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(trip.destination),
                        const SizedBox(height: 4),
                        Text(
                          '${trip.date.day}/${trip.date.month}/${trip.date.year}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _viewTripDetails(trip),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewTrip,
        tooltip: 'Adicionar Viagem',
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class TripDetailsScreen extends StatelessWidget {
  final Trip trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(trip.title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        // Botão personalizado para voltar com tooltip
        leading: Builder(
          builder: (context) => Tooltip(
            message: 'Voltar',
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                trip.imagePath,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              trip.destination,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${trip.date.day}/${trip.date.month}/${trip.date.year}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Descrição:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              trip.description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            const Text(
              'Anotações:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Card(
              child: ListTile(
                leading: Icon(Icons.notes),
                title: Text('Dia 1: Chegada ao destino'),
                subtitle: Text('Voo tranquilo, hotel confortável'),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Nova Anotação',
        child: const Icon(Icons.note_add),
      ),
    );
  }
}