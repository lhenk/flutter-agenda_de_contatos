import 'dart:io';

import 'package:agenda_de_contatos/helpers/contact_helper.dart';
import 'package:agenda_de_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions { orderAz, orderZa }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            actions: <Widget>[
        PopupMenuButton<OrderOptions>(
        itemBuilder: (context)=><PopupMenuEntry<OrderOptions>>[
    const PopupMenuItem<OrderOptions>(
    child: Text("Ordenar A-Z"),
    value: OrderOptions.orderAz,
    ),
    const PopupMenuItem<OrderOptions>(
    child: Text("Ordenar Z-A"),
    value: OrderOptions.orderZa,
    )
    ],
    onSelected: _orderList,
    )
    ],
    title: Text("Contatos"),
    backgroundColor: Colors.red,
    centerTitle: true,
    ),
    backgroundColor: Colors.white,
    floatingActionButton: FloatingActionButton(
    onPressed: () {
    _showContactPage();
    },
    child: Icon(Icons.add),
    backgroundColor: Colors.red,
    ),
    body: ListView.builder(
    itemCount: contacts.length,
    itemBuilder: (context, index) {
    return _contactCard(context, index);
    },
    padding: EdgeInsets.all(10)),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
        onTap: () {
          //  _showContactPage(contact: contacts[index]);
          _showOptions(context, index);
        },
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: contacts[index].img != null
                              ? FileImage(File(contacts[index].img))
                              : AssetImage("images/person.png"))),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(contacts[index].name ?? "",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(contacts[index].email ?? "",
                          style: TextStyle(fontSize: 18)),
                      Text(contacts[index].phone ?? "",
                          style: TextStyle(fontSize: 18)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10),
                child:
                Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: FlatButton(
                        child: Text("Ligar",
                            style: TextStyle(color: Colors.red, fontSize: 20)),
                        onPressed: () {
                          launch("tel:${contacts[index].phone}");
                          Navigator.pop(context);
                        }),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: FlatButton(
                        child: Text("Editar",
                            style: TextStyle(color: Colors.red, fontSize: 20)),
                        onPressed: () {
                          Navigator.pop(context);
                          _showContactPage(contact: contacts[index]);
                        }),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: FlatButton(
                        child: Text("Excluir",
                            style: TextStyle(color: Colors.red, fontSize: 20)),
                        onPressed: () {
                          helper.deleteContact(contacts[index].id);
                          setState(() {
                            contacts.removeAt(index);
                            Navigator.pop(context);
                          });
                        }),
                  )
                ]),
              );
            },
          );
        });
  }

  void _orderList(OrderOptions result) {
    setState(() {
      switch (result) {
        case OrderOptions.orderAz:
          contacts.sort((a, b) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
          break;
        case OrderOptions.orderZa:
          contacts.sort((b, a) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });
          break;
      }
    });

  }
}
