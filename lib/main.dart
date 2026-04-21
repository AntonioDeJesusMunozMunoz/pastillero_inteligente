import 'package:flutter/material.dart';

void main() {
  runApp(const PillDispenserMonitor());
}

Color foregroundColor = Colors.blueGrey.shade600;
Color backgroundColor = Colors.blueGrey.shade200;
TextStyle baseTextStyle = TextStyle(
                            fontSize: 20
                          );

//Los datos se verian asi
Map testDict = {
  0: [("Ibuprofeno",0,0),("Paracetamol",1,70),("skibidi Sigma",2,0)],//hora:lista[(nombre,tomo(2), tomoTarde(1),noTomo(0),tiempoDeRetraso(minutos))]
  6: [("Ibuprofeno",2,0)],
  8: [("Paracetamol",2,0)],
  12:[("Ibuprofeno",1,200), ("Skibidi Sigma",2,0)],
  16:[("Paracetamol",2,0)],
  18:[("Ibuprofeno",2,0)]
};

var cardBoxDecoration = BoxDecoration(
                  color: foregroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(50))
                );
class PillDispenserMonitor extends StatelessWidget {
  const PillDispenserMonitor({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(backgroundColor: Colors.blueGrey.shade800,),
        body: Container(
              decoration: BoxDecoration(
              color: backgroundColor,
              ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //time until next pill card
                siguientePildoraCard(),

                //historial table
                Container(
                  decoration: cardBoxDecoration,
                  child: Column(
                    //children: testDict.values.map((key,value) => {return Text("")}).toList(),
                  ),
                ),
              ],
            ),
          ),
      )
    );
  }

Container siguientePildoraCard() {
  return Container(
              margin: EdgeInsets.symmetric(horizontal: 7, vertical: 15),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: cardBoxDecoration,
              child: Column(
                children: [
                  Text("Siguiente Pildora",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 30
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        "Paracetamol",
                        style: baseTextStyle,
                        ),
                        Text(
                          "8:03 PM", 
                          style: TextStyle(
                            color: Colors.orange.shade600,
                            fontSize: 30
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
  }
}