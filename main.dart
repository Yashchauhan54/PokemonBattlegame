import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';

void main() {
  runApp(PokemonApp());
}

class PokemonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon TCG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SplashScreen(),
    );
  }
}
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/bg.png"),
            fit: BoxFit.cover,
          )))
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String apiUrl = "https://api.pokemontcg.io/v2/cards";
  Map<String, dynamic>? card1;
  Map<String, dynamic>? card2;
  String winner = "";
  TextEditingController _searchController = TextEditingController();
  List<dynamic> filteredCards = [];

  Future<void> fetchRandomCards() async {
    var result = await http.get(Uri.parse(apiUrl),
        headers: {"X-Api-Key": "220f2e49-4814-40a5-8f97-df57eb83374e"});
    List<dynamic> cards = json.decode(result.body)['data'];

    final randomCards = (cards..shuffle()).take(2).toList();
    setState(() {
      card1 = randomCards[0];
      card2 = randomCards[1];
      winner = _determineWinner(card1!, card2!);
    });
  }

  String _determineWinner(Map<String, dynamic> card1, Map<String, dynamic> card2) {
    final hp1 = int.tryParse(card1['hp'] ?? '0') ?? 0;
    final hp2 = int.tryParse(card2['hp'] ?? '0') ?? 0;

    if (hp1 > hp2) {
      return card1['name'];
    } else if (hp2 > hp1) {
      return card2['name'];
    } else {
      return 'Draw';
    }
  }

  void _searchCards(String query) {
    // Filter logic for search. Replace with actual filtering logic
    setState(() {
      filteredCards = []; // You can add filtering logic here
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pokémon Game Cards'),
        backgroundColor: const Color.fromARGB(255, 21, 180, 37),
        foregroundColor: Colors.white,
        elevation: 8,
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              width: 200,
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  _searchCards(query);
                },
                decoration: InputDecoration(
                  hintText: "Search Pokémon",
                  hintStyle: TextStyle(color: Colors.white),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.5),
                  suffixIcon: Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Spacer(),
            Center(
              child: Container(
                margin: EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: fetchRandomCards,
                  child: Text(
                    'PLAY HERE!!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 7, 216, 14),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shadowColor: Colors.black,
                    elevation: 10,
                  ),
                ),
              ),
            ),
            Spacer(),
            if (card1 != null && card2 != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: CardDisplay(card: card1!),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: CardDisplay(card: card2!),
                  ),
                ],
              ),
            if (winner.isNotEmpty)
  Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      padding: const EdgeInsets.all(8.0), // Add some space inside the box
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 21, 20, 20).withOpacity(0.5),
        border: Border.all(
          color: Colors.lightBlueAccent, // Border color
          width: 2.0, // Border width
        ),
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
      ),
      child: Text(
        'Winner: $winner',
        style: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.bold,
          color: const Color.fromARGB(255, 37, 244, 51),
        ),
      ),
    ),
  ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredCards.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CachedNetworkImage(
                      imageUrl: filteredCards[index]['images']['small'],
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      fit: BoxFit.cover,
            
                    ),
                    title: Text(
                      filteredCards[index]['name'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      'HP: ${filteredCards[index]['hp'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardDisplay extends StatelessWidget {
  final Map<String, dynamic> card;

  CardDisplay({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 21, 20, 20).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 4, 239, 20),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.0),
            blurRadius: 2,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CachedNetworkImage(
            imageUrl: card['images']['large'],
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
            width: 240,
            height: 240, // Enlarged image size
          ),
          SizedBox(height: 5),
          Text(
            card['name'],
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  offset: Offset(1.0, 1.0),
                  blurRadius: 2.0,
                  color: const Color.fromARGB(255, 231, 227, 227),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'HP: ${card['hp'] ?? 'N/A'}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
