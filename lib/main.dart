import 'package:flutter/material.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carrinho de Compras',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.red),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.red,
        ),
      ),
      home: const MarioTacticsShop(title: 'Mario Tactics Shop'),
    );
  }
}

class MarioTacticsShop extends StatefulWidget {
  const MarioTacticsShop({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MarioTacticsShop> createState() => _MarioTacticsShopState();
}

class _MarioTacticsShopState extends State<MarioTacticsShop> {
  List<Map<String, dynamic>> _produtos = [];
  List<int> _itensNoCarrinho = [];

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<List<Map<String, dynamic>>> _carregarProdutos() async {
    String jsonString =
    await DefaultAssetBundle.of(context).loadString('assets/products.json');
    List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }

  void _addCarrinho(int productId) {
    setState(() {
      _itensNoCarrinho.add(productId);
    });
  }

  void _removerCarrinho(int productId) {
    setState(() {
      _itensNoCarrinho.remove(productId);
    });
  }

  void _limparCarrinho() {
    setState(() {
      _itensNoCarrinho.clear();
    });
  }

  double _calcularPrecoCarrinho() {
    double total = 0.0;
    for (int produtoID in _itensNoCarrinho) {
      var produto = _produtos.firstWhere((element) => element['id'] == produtoID);
      total += produto['price'];
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _carregarProdutos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Erro ao carregar os produtos'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Nenhum produto disponível'),
            );
          } else {
            _produtos = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _produtos.length,
                    itemBuilder: (BuildContext context, int index) {
                      var product = _produtos[index];
                      bool isInCart = _itensNoCarrinho.contains(product['id']);
                      return ListTile(
                        leading: Image.asset(
                          'assets/images/${product['id']}.png',
                          width: 50,
                          height: 50,
                        ),
                        title: Text(product['name']),
                        subtitle: Text('R\$ ${product['price']}'),
                        trailing: isInCart
                            ? IconButton(
                          icon: const Icon(Icons.remove_shopping_cart),
                          onPressed: () =>
                              _removerCarrinho(product['id']),
                        )
                            : IconButton(
                          icon: const Icon(Icons.add_shopping_cart),
                          onPressed: () => _addCarrinho(product['id']),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Total: R\$ ${_calcularPrecoCarrinho().toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Cupom de desconto',
                    border: OutlineInputBorder(),
                  ),
                ),
                ElevatedButton(
                  onPressed: _limparCarrinho,
                  child: const Text('Limpar Carrinho'),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
