import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zenjourney/string_extension.dart';
import 'package:zenjourney/views/home/edit_habit.dart';

class HabitTrackingScreen extends StatefulWidget {
  const HabitTrackingScreen({super.key});

  @override
  State<HabitTrackingScreen> createState() => _HabitTrackingScreenState();
}

class _HabitTrackingScreenState extends State<HabitTrackingScreen> {
  final firestore = FirebaseFirestore.instance;
  final firebaseAuth = FirebaseAuth.instance; 

  final TextEditingController _habitNameController = TextEditingController();
  final TextEditingController _habitDescriptionController =
      TextEditingController();
  String? _selectedTrack;
  bool _isLoading = false;

  final List<String> _tracksList = [
    'Fitness',
    'Sono',
    'Alimentação',
    'Hobbies',
    'Social'
  ];

  final List<Map<String, dynamic>> _newHabitsList = [];

  @override
  void initState() {
    super.initState();
    fetchHabitsFromFirestore();
  }

  void deletarHabito(String trackName, String habitID, int index) async{
    final userUID = FirebaseAuth.instance.currentUser?.uid;
    if(userUID != null){
      try{
        await FirebaseFirestore.instance
        .collection('users')
        .doc(userUID)
        .collection('tracks')
        .doc(trackName)
        .collection('habits')
        .doc(habitID)
        .delete();

        
        setState(() {
          _newHabitsList.removeAt(index);
        });
      }catch(e){
        print("Erro ao deletar hábito: $e");
      }
    } else {
      setState(() {
        _newHabitsList.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffe0e6ea),
      body: Stack(
        children: [Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Parte Superior
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.only(top: 30),
                    decoration: BoxDecoration(
                      color: const Color(0xFF448D9C),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Olá, ${FirebaseAuth.instance.currentUser!.displayName}',
                          style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'Raleway',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
              const SizedBox(height: 10),
              // Parte Inferior
              Expanded(
                child: Column(
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hábitos faltantes para hoje: ${_newHabitsList.length}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'Raleway',
                            color: Color(0xFF193339),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Listagem de Hábitos
                    Expanded(
                      child: ListView.builder(
                        itemCount:
                            _newHabitsList.length, // Número de hábitos do dia
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () {
                              // Mostrar pop-up com detalhes do hábito
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: IconButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            icon: const Icon(
                                              Icons.close,
                                              color: Color(0xFF193339),
                                            ),
                                            tooltip: 'Fechar',
                                          ),
                                        ),
                                        Text(
                                          _newHabitsList[index]['name'],
                                          textAlign: TextAlign.start,
                                        ),
                                      ],
                                    ),
                                    content: SingleChildScrollView(
                                      child: ListBody(
                                        children: <Widget>[
                                          Text(_newHabitsList[index]['description']),
                                          SizedBox(height: 20),
                                          Text( _newHabitsList[index]['track'].toString().toCapitalized,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Raleway',
                                              color: Color(0xFF193339),
                                            ),
                                          ),
                                        ],
                                      )
                                    ),
                                    actions: [
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditHabitView(
                                                habitId: _newHabitsList[index]['id'],
                                                habitName: _newHabitsList[index]['name'],
                                                habitDescription: _newHabitsList[index]['description'],
                                                habitTrack: _newHabitsList[index]['track'],
                                                //onHabitUpdated: fetchHabitsFromFirestore,
                                              )
                                            )
                                          );
                                        },
                                        icon: Icon(Icons.edit, color: Color(0xFF193339)),
                                        tooltip: 'Editar',
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Color(0xFF193339)),
                                        onPressed: () {
                                          // Exibir mensagem de confirmação antes de deletar
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text("Confirmar Deleção"),
                                                content: Text("Você tem certeza que deseja deletar este hábito?"),
                                                actions: [
                                                  TextButton(
                                                    child: Text("Cancelar"),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text("Deletar"),
                                                    onPressed: () {
                                                      final trackName = _newHabitsList[index]['track'];
                                                      final habitID = _newHabitsList[index]['id'];
                                                      deletarHabito(trackName, habitID, index); //deleção de hábtios sugeridos com vinculação firestore
                                                      Navigator.of(context).pop();
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  );
                                },
                              ).then((value) {
                                fetchHabitsFromFirestore();
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),                             
                                color: _newHabitsList[index]['isCompleted']
                                    ? Color(0xFFB8FFC7)
                                    : Colors.white,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                        SizedBox(
                                          child : Text(
                                            _newHabitsList[index]['name'],
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'Raleway',
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF193339),
                                            ),
                                            maxLines: null,
                                            overflow: TextOverflow.visible,
                                          ),
                                        ),
                                      const SizedBox(height: 5),
                                    ],
                                  ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(                                  
                                        icon: Image.asset(
                                          _newHabitsList[index]['isCompleted']? 'assets/icons/check.png': 'assets/icons/uncheck.png', // Altera o ícone com base no estado                                   
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _newHabitsList[index]['isCompleted'] = !_newHabitsList[index]['isCompleted']; // Alterna o estado
                                            changeActualState(
                                              _newHabitsList[index]['track'],
                                              _newHabitsList[index]['id'],
                                              _newHabitsList[index]['isCompleted']
                                              );
                                          });
                                          // Atualizar estado do checkbox
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if(_isLoading)
          Container(
            color: Colors.black.withOpacity(0.0),
            child: Center(
              child: CircularProgressIndicator() 
              ),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _createHabit(context);
          // Adicionar novo hábito
        },
        backgroundColor: const Color(0xFF448D9C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> fetchHabitsFromFirestore() async {
  try {
    final String uid = FirebaseAuth.instance.currentUser?.uid ?? "anonymous";
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);

    // Limpa a lista local antes de carregar os novos dados
    setState(() {
      _newHabitsList.clear();
      _isLoading = true;
    });

    // Para cada trilha, busque os hábitos sugeridos
    final tracksSnapshot = await userDocRef.collection('tracks').get();
    for (var trackDoc in tracksSnapshot.docs) {
      final trackName = trackDoc.id; // Nome da trilha
      final habitsSnapshot = await trackDoc.reference.collection('habits').get();
      for (var habitDoc in habitsSnapshot.docs) {
        final data = habitDoc.data();
        _newHabitsList.add({
          'name': data['name'], // Nome do hábito
          'track': trackName,    // Nome da trilha
          'description': data['description'] ?? 'Sem descrição', // Descrição
          'isCompleted': data['isCompleted'], // booleano que representa o estado do hábito
          'id': data['id']
        });
      }
    }
    setState(() {
      _isLoading = false;
    }); // Atualiza a tela com os dados carregados
  } catch (e) {
    print("Erro ao carregar hábitos do Firestore: $e");
  }
}

  void _createHabit(BuildContext context) {
  setState(() {
    _selectedTrack = null;
  });

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Novo Hábito',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF448D9C),
                  ),
                ),
                Text(
                  'Crie seus próprios hábitos para ter uma experiência personalizada',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 18,
                    color: Color(0xFF193339),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Hábito',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 18,
                      color: Color(0xFF193339),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                TextField(
                  controller: _habitNameController,
                  cursorColor: Color(0xFF193339),
                  inputFormatters: [LengthLimitingTextInputFormatter(45)],
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelText: 'Nome do Hábito',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Color(0xFF193339),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Trilha',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 18,
                      color: Color(0xFF193339),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedTrack,
                  hint: const Text('Selecione a trilha'),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedTrack = newValue;
                    });
                  },
                  items: _tracksList.map((String track) {
                    return DropdownMenuItem<String>(
                      value: track,
                      child: Text(track),
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Color(0xFF193339),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Descrição',
                    style: TextStyle(
                      fontFamily: 'Raleway',
                      fontSize: 18,
                      color: Color(0xFF193339),
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                TextField(
                  controller: _habitDescriptionController,
                  maxLines: 4,
                  cursorColor: Color(0xFF193339),
                  inputFormatters: [LengthLimitingTextInputFormatter(116)],
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Color(0xFF193339),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF193339),
                            fixedSize: Size.fromHeight(50),
                          ),
                          child: Text(
                            'Voltar',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Raleway',
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: ElevatedButton(
                          onPressed: () async {
                            if (await addHabit(
                              _habitNameController.text,
                              _selectedTrack,
                              _habitDescriptionController.text,
                            )) {
                              Navigator.pop(context);
                            } else {
                              Fluttertoast.showToast(
                                msg: "Campos não preenchidos",
                                gravity: ToastGravity.TOP,
                                timeInSecForIosWeb: 2,
                                backgroundColor: Color(0xFF193339),
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF448D9C),
                            fixedSize: Size.fromHeight(50),
                          ),
                          child: Text(
                            'Salvar',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Raleway',
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
  Future<void> changeActualState(habitTrack, habitId, isCompleted) async{
        try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await firestore
            .collection('users')
            .doc(userId)
            .collection('tracks')
            .doc(habitTrack)
            .collection('habits')
            .doc(habitId)
            .update({
              'isCompleted':isCompleted
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> addHabit(habitName, habitTrack, habitDescription) async {
    String name = habitName.trim();
    String description = habitDescription.trim();

    if (name.isEmpty || habitTrack == null || description.isEmpty) {
      return false;
    }

    User? currentUser = firebaseAuth.currentUser;
    DocumentReference trackRef = firestore.collection('users').doc(currentUser!.uid).collection('tracks').doc(habitTrack.toLowerCase());
    DocumentReference habitDoc = trackRef.collection('habits').doc();
    String habitID = habitDoc.id;

    await habitDoc.set({
      'name':habitName,
      'description':habitDescription,
      'createdAt':Timestamp.now(),
      'updatedAt':Timestamp.now(),
      'isCompleted':false,
      'id': habitID,
    });
    fetchHabitsFromFirestore();
    _habitNameController.clear();
    _habitDescriptionController.clear();
    return true;
  }
}
