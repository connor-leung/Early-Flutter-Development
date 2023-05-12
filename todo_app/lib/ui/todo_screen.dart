import 'package:flutter/material.dart';
import 'package:todoapp/model/todo_item.dart';
import 'package:todoapp/util/database_client.dart';

class ToDoScreen extends StatefulWidget {
  @override
  _ToDoScreenState createState() => _ToDoScreenState();
}

class _ToDoScreenState extends State<ToDoScreen> {
  final TextEditingController _textEditingController = new TextEditingController();
  var db = new DatabaseHelper();
  final List<ToDoItem> _itemList = <ToDoItem>[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _readToDoList();
  }


  void _handleSubmitted(String text) async {
    _textEditingController.clear();

    ToDoItem toDoItem = new ToDoItem(text, DateTime.now().toIso8601String());
    int savedItemId = await db.saveItem(toDoItem);

    ToDoItem addedItem = await db.getItem(savedItemId);

    setState(() {
      _itemList.insert(0, addedItem);

    });

    print("Item saved id: $savedItemId");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Column(
        children: <Widget>[
          new Flexible(
              child: new ListView.builder(
                  padding: new EdgeInsets.all(8.0),
                  reverse: false,
                  itemCount: _itemList.length,
                  itemBuilder: (_, int index) {
                    return Card(
                      color: Colors.white10,
                      child: new ListTile(
                        title: _itemList[index],
                        onLongPress: () => debugPrint(""),
                        trailing: new Listener(
                          key: new Key(_itemList[index].itemName),
                          child: new Icon(Icons.remove_circle,
                          color: Colors.redAccent,),
                          onPointerDown: (pointerEvent) => debugPrint(""),
                        ),
                      ),
                    );
                  }),
          ),
          new Divider(
            height: 1.0,
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
          tooltip: 'Add Item',
          backgroundColor: Colors.greenAccent,
          child: ListTile(
            title: Icon(Icons.add),
          ),
          onPressed: _showFormDialog),
    );
  }

  void _showFormDialog() {
    var alert = new AlertDialog(
      content: new Row(
        children: <Widget>[
          new Expanded(
              child: new TextField(
                controller: _textEditingController,
                autofocus: true,
                decoration: new InputDecoration(
                  labelText: "Item",
                  hintText: "eg, Buy flowers",
                  icon: new Icon(Icons.note_add)
                ),
              ))
        ],
      ),
      actions: <Widget>[
        new FlatButton(
            onPressed: () {
              _handleSubmitted(_textEditingController.text);
              _textEditingController.clear();
            },
            child: Text("Save")),
        new FlatButton(onPressed: () => Navigator.pop(context),
            child: Text("Cancel"))
      ],
    );
    showDialog(context: context,
       builder:(_) {
         return alert;
    });
  }

  _readToDoList() async {
    List items = await db.getItems();
     items.forEach((item) {
       ToDoItem toDoItem = ToDoItem.map(items);
       print("Db items: ${toDoItem.itemName}");
     });
  }
}
