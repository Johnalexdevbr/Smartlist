import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SmartListApp());
}

class SmartListApp extends StatelessWidget {
  const SmartListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartList',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6c5ce7)),
        useMaterial3: true,
        fontFamily: 'sans-serif',
      ),
      home: const WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6c5ce7), Color(0xFFa29bfe)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_basket_rounded, size: 100, color: Colors.white),
            ),
            const SizedBox(height: 30),
            const Text(
              "Bem-vindo ao\nSmartList",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6c5ce7),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              child: const Text("COMEÇAR FEIRA", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemCompra {
  String nome;
  int quantidade;
  double preco;
  bool noCarrinho;
  TextEditingController precoCtrl;
  FocusNode focusNode;

  ItemCompra({
    this.nome = "",
    this.quantidade = 1,
    this.preco = 0.0,
    this.noCarrinho = false,
  })  : precoCtrl = TextEditingController(text: preco > 0 ? preco.toString() : ""),
        focusNode = FocusNode();

  double get subtotal => quantidade * preco;

  IconData get icone {
    String n = nome.toLowerCase();
    if (n.contains("carne") || n.contains("frango")) return Icons.kebab_dining;
    if (n.contains("pao") || n.contains("bolo")) return Icons.bakery_dining;
    if (n.contains("fruta") || n.contains("banana") || n.contains("maca")) return Icons.apple;
    if (n.contains("limpeza") || n.contains("sabao")) return Icons.cleaning_services;
    if (n.contains("bebida") || n.contains("suco") || n.contains("refri")) return Icons.local_drink;
    return Icons.shopping_cart_outlined;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<ItemCompra> _itens = [];
  double orcamentoLimite = 1000.0;
  final TextEditingController _limitCtrl = TextEditingController();

  double get _totalGeral => _itens.fold(0, (sum, item) => sum + item.subtotal);

  void _adicionarItem() {
    setState(() {
      final novoItem = ItemCompra();
      _itens.insert(0, novoItem);
      Future.delayed(const Duration(milliseconds: 100), () => novoItem.focusNode.requestFocus());
    });
  }

  void _removerItem(int index) {
    setState(() => _itens.removeAt(index));
  }

  void _editarOrcamento() {
    _limitCtrl.text = orcamentoLimite.toString();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Definir Limite Mensal"),
        content: TextField(
          controller: _limitCtrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            prefixText: "R\$ ",
            hintText: "Ex: 500.00",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                orcamentoLimite = double.tryParse(_limitCtrl.text.replaceAll(',', '.')) ?? orcamentoLimite;
              });
              Navigator.pop(ctx);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  void _limparTudo() {
    if (_itens.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Limpar lista?"),
        content: const Text("Isso apagará todos os itens atuais."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Não")),
          TextButton(
            onPressed: () {
              setState(() => _itens.clear());
              Navigator.pop(ctx);
            },
            child: const Text("Sim, limpar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _finalizarCompra() {
    if (_itens.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text("Finalizar Feira"),
          ],
        ),
        content: Text(
          "Deseja salvar esta compra de R\$ ${_totalGeral.toStringAsFixed(2).replaceFirst('.', ',')} no histórico?",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Revisar")),
          ElevatedButton(
            onPressed: () async {
              // SALVANDO NO FIREBASE
              await FirebaseFirestore.instance.collection('historico').add({
                'data': DateTime.now(),
                'total': _totalGeral,
                'itens': _itens.map((i) => {'nome': i.nome, 'preco': i.preco, 'qtd': i.quantidade}).toList(),
              });

              setState(() => _itens.clear());
              if (mounted) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Compra arquivada com sucesso! ✅"),
                    backgroundColor: Color(0xFF6c5ce7),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text("Confirmar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progresso = (_totalGeral / orcamentoLimite).clamp(0.0, 1.0);
    Color statusColor = progresso >= 1.0
        ? Colors.red
        : (progresso > 0.8 ? Colors.orange : const Color(0xFF6c5ce7));

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text("SmartList - Minha Feira",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: const Color(0xFF6c5ce7),
        centerTitle: true,
        elevation: 5,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryPage()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
            onPressed: _limparTudo,
          )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                border: Border.all(color: progresso >= 1.0 ? Colors.red.withOpacity(0.3) : Colors.transparent),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Resumo do Orçamento", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
                      GestureDetector(
                        onTap: _editarOrcamento,
                        child: Row(
                          children: [
                            Text("R\$ ${orcamentoLimite.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6c5ce7))),
                            const SizedBox(width: 4),
                            const Icon(Icons.edit_note, size: 20, color: Color(0xFF6c5ce7)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progresso,
                    backgroundColor: Colors.grey.shade100,
                    color: statusColor,
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("${(progresso * 100).toInt()}% utilizado",
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      Text("Restam R\$ ${(orcamentoLimite - _totalGeral).clamp(0, orcamentoLimite).toStringAsFixed(2)}",
                          style: const TextStyle(color: Colors.black38, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _itens.isEmpty
              ? SliverFillRemaining(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_checkout_outlined, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text("Nenhum item na lista ainda.", style: TextStyle(color: Colors.grey.shade400, fontSize: 16)),
              ],
            ),
          )
              : SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final item = _itens[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: item.noCarrinho ? 0.6 : 1.0,
                    child: Card(
                      elevation: 0,
                      color: item.noCarrinho ? Colors.grey.shade100 : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: item.noCarrinho ? Colors.transparent : Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: GestureDetector(
                                onTap: () => setState(() => item.noCarrinho = !item.noCarrinho),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: item.noCarrinho ? Colors.green.withOpacity(0.1) : const Color(0xFF6c5ce7).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    item.noCarrinho ? Icons.check : item.icone,
                                    color: item.noCarrinho ? Colors.green : const Color(0xFF6c5ce7),
                                    size: 24,
                                  ),
                                ),
                              ),
                              title: TextField(
                                focusNode: item.focusNode,
                                decoration: const InputDecoration(hintText: "Nome do item...", border: InputBorder.none),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  decoration: item.noCarrinho ? TextDecoration.lineThrough : null,
                                  color: item.noCarrinho ? Colors.grey : Colors.black87,
                                ),
                                onChanged: (v) => setState(() => item.nome = v),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                                onPressed: () => _removerItem(index),
                              ),
                            ),
                            const Divider(height: 1, thickness: 0.5),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 18),
                                        onPressed: () => setState(() { if(item.quantidade > 1) item.quantidade--; }),
                                      ),
                                      Text("${item.quantidade}", style: const TextStyle(fontWeight: FontWeight.bold)),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 18, color: Color(0xFF6c5ce7)),
                                        onPressed: () => setState(() => item.quantidade++),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: item.precoCtrl,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      prefixText: "R\$ ",
                                      labelText: "Preço Unit.",
                                      labelStyle: const TextStyle(fontSize: 12),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    ),
                                    onChanged: (v) => setState(() => item.preco = double.tryParse(v.replaceAll(',', '.')) ?? 0.0),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "Subtotal: R\$ ${item.subtotal.toStringAsFixed(2).replaceFirst('.', ',')}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: item.noCarrinho ? Colors.grey : const Color(0xFF6c5ce7)
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: _itens.length,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _adicionarItem,
        backgroundColor: const Color(0xFF6c5ce7),
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text("ITEM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 35),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, spreadRadius: 5)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("TOTAL DA COMPRA", style: TextStyle(color: Colors.black38, fontWeight: FontWeight.bold, fontSize: 10)),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: statusColor
                  ),
                  child: Text("R\$ ${_totalGeral.toStringAsFixed(2).replaceFirst('.', ',')}"),
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _finalizarCompra,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6c5ce7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              icon: const Icon(Icons.task_alt),
              label: const Text("CONCLUIR", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text("Histórico de Compras", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF6c5ce7),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('historico').orderBy('data', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Erro ao carregar histórico"));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 80, color: Colors.grey),
                  Text("Nenhuma compra finalizada ainda.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final DateTime date = (data['data'] as Timestamp).toDate();
              final double total = data['total'] ?? 0.0;
              final List itens = data['itens'] ?? [];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ExpansionTile(
                  leading: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF6c5ce7)),
                  title: Text(
                    "Feira - ${DateFormat('dd/MM/yyyy').format(date)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("${itens.length} itens - R\$ ${total.toStringAsFixed(2).replaceFirst('.', ',')}"),
                  children: [
                    const Divider(),
                    ...itens.map((i) => ListTile(
                      dense: true,
                      title: Text(i['nome'] ?? 'Sem nome'),
                      trailing: Text("${i['qtd']}x - R\$ ${i['preco'].toStringAsFixed(2)}"),
                    )).toList(),
                    const SizedBox(height: 10),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}