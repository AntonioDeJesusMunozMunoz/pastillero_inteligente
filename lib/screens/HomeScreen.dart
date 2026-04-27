import 'package:flutter/material.dart';


/*PLACEHOLDER*/
//TODO reemplazar con una BDD local///
//Nombre y edad del onboarding
Map<String, dynamic> patientData = {
  'nombre': 'María González',
  'edad': 72,
};

//Lee el nombre, la dosis y la siguiente hora, puede ser un select order by horaDeTomar
//Basicamente voy a tener guardado cada hora de tomar
//En otra tabla el nombre y la dosis de la pildora
Map<String, dynamic> nextPillData = {
  'nombre': 'Paracetamol',
  'dosis': '500mg · 1 tableta',
  'horaDeTomar': "8:00 PM", //esto sera una DATE de sql
  'hora' : "6:00 PM"
};


Map<int, List<(String, int, int)>> testDict = {//relaciona las horas con las pastilas que se debió tomar y si la tomó
  0:  [('Ibuprofeno', 0, 0),   ('Paracetamol', 1, 70),  ('Skibidi Sigma', 2, 0)],//2: tomo, 1: tomo tarde, 0:no tomo
  6:  [('Ibuprofeno', 2, 0)],
  8:  [('Paracetamol', 2, 0)],
  12: [('Ibuprofeno', 1, 200), ('Skibidi Sigma', 2, 0)],
  16: [('Paracetamol', 2, 0)],
  18: [('Ibuprofeno', 2, 0)],
};

/*TEMA*/
const Color _bg       = Color(0xFF07101E);
const Color _surface  = Color(0xFF0D1929);
const Color _card     = Color(0xFF132035);
const Color _cardHigh = Color(0xFF1A2D47);
const Color _sky      = Color(0xFF38BDF8);
const Color _indigo   = Color(0xFF818CF8);
const Color _emerald  = Color(0xFF34D399);
const Color _amber    = Color(0xFFFBBF24);
const Color _rose     = Color(0xFFF87171);
const Color _text     = Color(0xFFE2E8F0);
const Color _textSub  = Color(0xFF94A3B8);
const Color _textDim  = Color(0xFF475569);
const Color _divider  = Color(0xFF1E2D42);


/*ROOT*/
// class PillDispenserMonitor extends StatelessWidget {
//   const PillDispenserMonitor({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.dark().copyWith(
//         scaffoldBackgroundColor: _bg,
//         colorScheme: const ColorScheme.dark(primary: _sky, surface: _surface),
//       ),
//       home: const HomeScreen(),
//     );
//   }
// }


/*HOMESCREEN*/
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(//para que no se acerque mucho a los bordes
        child: CustomScrollView(//porque le vamos a poner efectos 
          physics: const BouncingScrollPhysics(),//como este
          slivers: [//widgets pero un poquito mejores para scroll
            _buildAppBar(),

            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverList(
                
                /*MAIN COLUMN*/
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 18),
                  const _PatientCard(),
                  const SizedBox(height: 14),
                  const _NextPillCard(),
                  const SizedBox(height: 14),
                  const _SectionLabel("Resumen de Hoy"),
                  const _SummaryRow(),
                  const SizedBox(height: 12),
                  const _HistorialList(),
                  const SizedBox(height: 26),
                  const SizedBox(height: 12),
                  const SizedBox(height: 32),
                ]),

              ),
            ),

          ],
        ),
      ),
    );
  }

  /*MAIN APPBAR*/
  SliverAppBar _buildAppBar() => SliverAppBar(
    backgroundColor: _bg,
    elevation: 0,
    floating: true,
    titleSpacing: 18,

    /*Main row for appbar*/
    title: Row(
      children: [
        /*The pill, will eventually be the app icon*/
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_sky.withOpacity(0.25), _indigo.withOpacity(0.2)],
            ),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: _sky.withOpacity(0.3), width: 1),
          ),
          child: const Icon(Icons.medication_rounded, color: _sky, size: 20),
        ),

        const SizedBox(width: 12),

        /*The text next to the pill*/
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('PillMonitor',
              style: TextStyle(color: _text, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            Text('Panel del Cuidador',
              style: TextStyle(color: _textDim, fontSize: 10.5, fontWeight: FontWeight.w500, letterSpacing: 0.2)),
          ],
        ),

        Spacer(),

        /*Settings Button*/
        InkWell(
            onTap: () => {},
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Icon(Icons.settings),
          ),
        ),
      ],
    ),
  );


}

/////////////
//HELPERS////
/////////////

/*Label para sección*/ //ya está estilizado
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: _text, fontSize: 17,
      fontWeight: FontWeight.w700, letterSpacing: -0.3,
    ),
  );
}

/*Decoracion de cards*/
BoxDecoration _cardDecor({Color? borderColor, List<Color>? gradientColors}) => BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: gradientColors ?? [_card, _surface],
  ),
  borderRadius: BorderRadius.circular(24),
  border: Border.all(color: borderColor ?? _divider, width: 1),
);


/*Card de paciente*/
class _PatientCard extends StatelessWidget {
  const _PatientCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecor(
        borderColor: _sky.withOpacity(0.2),
        gradientColors: [
          _sky.withOpacity(0.12),
          _card.withOpacity(0.95),
        ],
      ),

      /*Main Row for card paciente*/
      child: Row(
        children: [
          // Nombre
          const SizedBox(width: 15),

          /*Datos del paciente*/
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patientData['nombre'],
                  style: const TextStyle(color: _text, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                const SizedBox(height: 3),
                Text('${patientData['edad']} años',
                  style: const TextStyle(color: _textSub, fontSize: 12.5)),
              ],
            ),
          ),
          
          _StatusBadge(label: 'Activo', color: _emerald),
        ],
      ),

    );
  }
}


/*Card de siguiente píldora*/
class _NextPillCard extends StatelessWidget {
  const _NextPillCard();

  String _formatTime(int mins) {
    if (mins >= 60) return '${mins ~/ 60}h ${mins % 60}m';
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final int mins = 100;
    final bool urgent = mins < 30;
    final accentColor = urgent ? _rose : _amber;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF152540), Color(0xFF0D1928)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _sky.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(color: _sky.withOpacity(0.07), blurRadius: 30, spreadRadius: 0, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _sky.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _sky.withOpacity(0.2)),
                ),
                child: const Text('PRÓXIMA DOSIS',
                  style: TextStyle(color: _sky, fontSize: 9.5, fontWeight: FontWeight.w800, letterSpacing: 1.6)),
              ),
              const Spacer(),
              const Icon(Icons.access_time_rounded, color: _textDim, size: 14),
              const SizedBox(width: 4),
              Text(nextPillData['hora'],
                style: const TextStyle(color: _textSub, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 20),
          // Main content
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _sky.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.medication_rounded, color: _sky, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nextPillData['nombre'],
                      style: const TextStyle(color: _text, fontSize: 24, fontWeight: FontWeight.w800,
                          letterSpacing: -0.6, height: 1)),
                    const SizedBox(height: 3),
                    Text(nextPillData['dosis'],
                      style: const TextStyle(color: _textSub, fontSize: 13)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_formatTime(mins),
                    style: TextStyle(
                      color: accentColor, fontSize: 28,
                      fontWeight: FontWeight.w800, letterSpacing: -1,
                    )),
                  Text('restantes',
                    style: TextStyle(color: accentColor.withOpacity(0.6), fontSize: 10.5)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Progress bar
          Stack(
            children: [
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: _divider,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              FractionallySizedBox(
                widthFactor: 1 - (mins / (24 * 60)).clamp(0.0, 1.0),
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [_sky, accentColor]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/*Renglón de resumen*/
class _SummaryRow extends StatelessWidget {
  const _SummaryRow();

  int _count(int status) => testDict.values// TODO aqui se usa testDict, reemplazar cuando ya tenga la BDD
      .expand((list) => list)
      .where((d) => d.$2 == status)
      .length;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatTile(label: 'Tomó',    value: _count(2), color: _emerald, icon: Icons.check_circle_rounded),
        const SizedBox(width: 10),
        _StatTile(label: 'Tarde',   value: _count(1), color: _amber,   icon: Icons.watch_later_rounded),
        const SizedBox(width: 10),
        _StatTile(label: 'No tomó', value: _count(0), color: _rose,    icon: Icons.cancel_rounded),
      ],
    );
  }
}


/*Tile unica (de las del resumen)*/
class _StatTile extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  const _StatTile({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color.withOpacity(0.7), size: 18),
          const SizedBox(height: 6),
          Text('$value',
            style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w800, height: 1)),
          const SizedBox(height: 3),
          Text(label,
            style: TextStyle(color: color.withOpacity(0.65), fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    ),
  );
}


/*Lista del historial*/
class _HistorialList extends StatelessWidget {
  const _HistorialList();

  //helper para cambiar como escribo la hora
  static String _formatHour(int h) {
    if (h == 0)  return '12:00 AM';
    if (h < 12)  return '$h:00 AM';
    if (h == 12) return '12:00 PM';
    return '${h - 12}:00 PM';
  }

  @override
  Widget build(BuildContext context) {
    final keys = testDict.keys.toList()..sort();
    return Column(
      children: keys.map((h) => _HoraRow(hora: _formatHour(h), dosis: testDict[h]!)).toList(),
    );
  }
}


/*Stateful hora*/
class _HoraRow extends StatefulWidget {
  //lo que pide
  final String hora; //hora como str
  final List<(String, int, int)> dosis; //dosis (de testDict)
  const _HoraRow({required this.hora, required this.dosis});

  @override
  State<_HoraRow> createState() => _HoraRowState();
}

/*state de stateful hora*/
class _HoraRowState extends State<_HoraRow> with SingleTickerProviderStateMixin {
  bool _open = false;

  /*Variables que dependen de la dosis (de testdict)*/
  static Color  _color(int s) => s == 2 ? _emerald : s == 1 ? _amber : _rose;//cual color va a tener (bien,tarde,mal)
  static IconData _icon(int s) => s == 2 ? Icons.check_circle_rounded //cual icono va a tener (bien,tarde,mal)
    : s == 1 ? Icons.watch_later_rounded 
    : Icons.cancel_rounded; 

  /*Label automatica para dosis (de testdict)*/
  //dice tomo, no tomo o tomo tarde (y tiempo de delay)
  static String _label(int s, int delay) {
    if (s == 2) return 'Tomó a tiempo';
    if (s == 1) {
      final h = delay ~/ 60, m = delay % 60;
      return h > 0 ? 'Tarde  +${h}h ${m}m' : 'Tarde  +${m}m';
    }
    return 'No tomó';
  }

  /*flags helper*/
  bool get _allOk => widget.dosis.every((dosis) => dosis.$2 == 2); //checa si todos fueron tomadas a tiempo
  bool get _hasIssue => widget.dosis.any((dosis) => dosis.$2 == 0); //checa si minimo una no se tomó

  /*El color de la fila segun las flags de arriba*/
  Color get _rowBorderColor {
    if (_hasIssue) return _rose.withOpacity(0.2);//esto esta deprecado pero ps funciona
    if (!_allOk)   return _amber.withOpacity(0.2);
    return _divider;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _rowBorderColor),
      ),
      child: Column(
        children: [
          // ── Header ──
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Hour badge
                  Container(
                    width: 52, height: 44,
                    decoration: BoxDecoration(
                      color: _cardHigh,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.hora.split(':')[0],
                          style: const TextStyle(color: _sky, fontSize: 15, fontWeight: FontWeight.w800, height: 1),
                        ),
                        Text(
                          widget.hora.contains('AM') ? 'AM' : 'PM',
                          style: const TextStyle(color: _textDim, fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.hora,
                          style: const TextStyle(color: _text, fontSize: 14.5, fontWeight: FontWeight.w600)),
                        Text(
                          '${widget.dosis.length} medicamento${widget.dosis.length > 1 ? 's' : ''}',
                          style: const TextStyle(color: _textDim, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Status dots
                  Row(
                    children: widget.dosis.map((d) => Container(
                      width: 9, height: 9,
                      margin: const EdgeInsets.only(left: 5),
                      decoration: BoxDecoration(
                        color: _color(d.$2),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: _color(d.$2).withOpacity(0.4), blurRadius: 5)],
                      ),
                    )).toList(),
                  ),
                  const SizedBox(width: 10),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: _textDim, size: 20),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded Detail ──
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Divider(color: _divider, height: 1, indent: 16, endIndent: 16),
                ...widget.dosis.asMap().entries.map((e) {
                  final d = e.value;
                  final color = _color(d.$2);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: e.key < widget.dosis.length - 1
                          ? Border(bottom: BorderSide(color: _divider, width: 0.8))
                          : null,
                    ),
                    child: Row(
                      children: [
                        Icon(_icon(d.$2), color: color, size: 17),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(d.$1,
                            style: const TextStyle(color: _text, fontSize: 13.5, fontWeight: FontWeight.w500)),
                        ),
                        _StatusBadge(label: _label(d.$2, d.$3), color: color),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
 * Misc
 */

/*EL badge de status*/
//es nomas un texto rodeado por una caja transparentes con color en el borde
//╭──────────────╮
//│  • Activo    │   ← fondo verde claro, borde verde suave, texto verde
//╰──────────────╯

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Text(label,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
  );
}