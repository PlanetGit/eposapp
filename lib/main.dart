import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:printing/printing.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ePos Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'ePos Management'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.local_printshop),
            tooltip: 'EPos Print',
            onPressed: () {
              print("EPOS PRINT");
              Printing.layoutPdf(
                onLayout: buildPdf,
              );
            },
          ),
        ],
      ),
      body: _buildBody(context), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(context, data)).toList(),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data) {
    final record = Record.fromSnapshot(data);
    // final record = Record.fromMap(data);

    return Padding(
      key: ValueKey(record.name),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.name),
          trailing: Text(record.votes.toString()),
          onTap: () => record.reference.updateData({'votes': FieldValue.increment(1)}),
        ),
      ),
    );
  }

  FutureOr<List<int>> buildPdf(PdfPageFormat format) {
    final doc = pdf.Document();

    doc.addPage(
      pdf.Page(
        pageFormat: format,
        build: (pdf.Context context) {
          return pdf.ConstrainedBox(
            constraints: const pdf.BoxConstraints.expand(),
            child: pdf.FittedBox(
              child: pdf.Text(
                'Happy coding Flutter!',
              ),
            ),
          );
        },
      ),
    );

    return doc.save();
  }
}

class Record {
  final String name;
  final int votes;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference}) 
    : assert(map['name'] != null),
       assert(map['votes'] != null),
       name = map['name'],
       votes = map['votes'];
  
  Record.fromSnapshot(DocumentSnapshot snapshot) 
    : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record <$name:$votes>";
}

