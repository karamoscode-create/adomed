// lib/screens/marketplace/checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:adomed_app/theme/app_theme.dart';
import 'package:adomed_app/models/cart_model.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  
  late Future<DocumentSnapshot> _userFuture;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();

    if (currentUser != null) {
      _userFuture = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).get();
      _userFuture.then((snapshot) {
        if (snapshot.exists && mounted) {
          final data = snapshot.data() as Map<String, dynamic>;
          _nameController.text = data['fullName'] ?? '';
          _addressController.text = data['address'] ?? '';
          _phoneController.text = data['phoneNumber'] ?? '';
        }
      });
    } else {
      // Pour éviter une erreur si l'utilisateur n'est pas connecté, on initialise avec un Future vide
      _userFuture = Future.value(null);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _processOrder(CartModel cart) async {
    if (currentUser == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : Utilisateur non connecté.')),
      );
      return;
    }
    
    final orderItems = cart.items.values.map((item) => {
      'productId': item.product.id,
      'name': item.product.name,
      'quantity': item.quantity,
      'price': item.product.price,
    }).toList();

    await FirebaseFirestore.instance
      .collection('users')
      .doc(currentUser!.uid)
      .collection('orders')
      .add({
        'items': orderItems,
        'totalPrice': cart.totalPrice,
        'status': 'En attente',
        'date': Timestamp.now(),
        'deliveryAddress': _addressController.text,
        'phoneNumber': _phoneController.text,
      });

    _sendWhatsAppMessage(cart);
  }

  void _sendWhatsAppMessage(CartModel cart) async {
    final String whatsappPhoneNumber = '2250704044643';
    
    String productsList = '';
    cart.items.values.forEach((item) {
      productsList += '- ${item.product.name} (Qté: ${item.quantity}) = ${item.product.price * item.quantity} FCFA\n';
    });

    final String message = 
      "Bonjour Adomed,\n\n"
      "Je voudrais passer la commande suivante :\n\n"
      "$productsList\n"
      "*Total : ${cart.totalPrice.toStringAsFixed(0)} FCFA*\n\n"
      "Nom du client : ${_nameController.text}\n"
      "Adresse de livraison : ${_addressController.text}\n"
      "Numéro de téléphone : ${_phoneController.text}\n\n"
      "Merci !";

    final String encodedMessage = Uri.encodeComponent(message);
    final Uri url = Uri.parse("https://wa.me/$whatsappPhoneNumber?text=$encodedMessage");

    if (await launchUrl(url, mode: LaunchMode.externalApplication)) {
      cart.clear();
      if(mounted) Navigator.pop(context);
    } else {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // On met listen: true ici pour que le total se mette à jour lors de la suppression
    final cart = Provider.of<CartModel>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Validation de la commande'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Récapitulatif de votre panier', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            
            // MODIFICATION : Utilisation de ListView.builder pour la liste des produits
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final cartItem = cart.items.values.toList()[index];
                
                // NOUVEAUTÉ : Le widget Dismissible permet de faire glisser pour supprimer
                return Dismissible(
                  key: Key(cartItem.product.id), // Clé unique pour chaque élément
                  direction: DismissDirection.endToStart, // Glissement de droite à gauche
                  onDismissed: (direction) {
                    // Action lors de la suppression
                    Provider.of<CartModel>(context, listen: false).remove(cartItem.product.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${cartItem.product.name} a été retiré du panier.')),
                    );
                  },
                  // Arrière-plan qui s'affiche lors du glissement
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Supprimer', style: TextStyle(color: Colors.white)),
                        SizedBox(width: 8),
                        Icon(Icons.delete, color: Colors.white),
                      ],
                    ),
                  ),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      // NOUVEAUTÉ : Affichage de l'image du produit
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset( // On utilise Image.asset car les URLs sont des chemins locaux
                          cartItem.product.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                        ),
                      ),
                      title: Text(cartItem.product.name),
                      subtitle: Text('Qté: ${cartItem.quantity} - ${(cartItem.product.price * cartItem.quantity).toStringAsFixed(0)} FCFA'),
                    ),
                  ),
                );
              },
            ),
            
            const Divider(height: 32),
            
            Text('Vos coordonnées', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            
            FutureBuilder<DocumentSnapshot>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nom Complet'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Adresse de livraison'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Numéro de téléphone'),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                );
              }
            ),

            const Divider(height: 32),

            Text('Mode de paiement', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text(
              'Pour finaliser, vous serez redirigé vers WhatsApp pour confirmer votre commande et organiser le paiement.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            
            const SizedBox(height: 32),
            
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: Text('Finaliser via WhatsApp (${cart.totalPrice.toStringAsFixed(0)} FCFA)'),
                onPressed: () {
                  if (cart.totalItems > 0) {
                    _processOrder(cart);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Votre panier est vide.')),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}