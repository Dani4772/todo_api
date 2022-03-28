// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'form.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _ratingController = TextEditingController();


  CollectionReference books = FirebaseFirestore.instance.collection('books');
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['name'];
      _yearController.text = documentSnapshot['year'].toString();
      _ratingController.text = documentSnapshot['rating'].toString();
    }
    else{
      _nameController.clear();
      _yearController.clear();
      _ratingController.clear();

    }
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  controller: _yearController,
                  decoration: InputDecoration(
                    labelText: 'Year',
                  ),
                ),
                TextField(
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  controller: _ratingController,
                  decoration: const InputDecoration(
                    labelText: 'rating',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? name = _nameController.text;
                    final int? year =
                    int.tryParse(_yearController.text);
                    final double? rating =
                    double.tryParse(_ratingController.text);
                    if (name != null && year != null) {
                      if (action == 'create') {
                        await books.add({"name": name, "year": year,"rating": rating});
                      }
                      if (action == 'update') {
                        // Update the product
                        await books
                            .doc(documentSnapshot!.id)
                            .update({"name": name, "year": year,"rating": rating});
                      }
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }
  Future<void> _deleteProduct(String productId) async {
    await books.doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('You have successfully deleted a product')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FireBase booK product'),
        actions: [
          TextButton(onPressed: (){
            FirebaseAuth.instance.signOut();
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginDemo()));

          }, child: Text('Sign Out',style: TextStyle(color: Colors.white),))
        ],
      ),
      body: StreamBuilder(
        stream: books.orderBy('rating',descending: true).snapshots(),

        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                streamSnapshot.data!.docs[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: Text(documentSnapshot['rating'].toString()),
                    title: Text(documentSnapshot['name']),
                    subtitle: Text(documentSnapshot['year'].toString()),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () =>
                                  _createOrUpdate(documentSnapshot)),
                          IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteProduct(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: Icon(Icons.add),
      ),
    );
  }
}