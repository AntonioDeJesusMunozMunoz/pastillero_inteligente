import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  COLORES  —  mismos que main.dart (HAY QUE MOVERLOS A theme.dart)
// ══════════════════════════════════════════════════════════════════════════════

const Color _bg       = Color(0xFF07101E);
const Color _surface  = Color(0xFF0D1929);
const Color _card     = Color(0xFF132035);
const Color _cardHigh = Color(0xFF1A2D47);
const Color _sky      = Color(0xFF38BDF8);
const Color _indigo   = Color(0xFF818CF8);
const Color _emerald  = Color(0xFF34D399);
const Color _rose     = Color(0xFFF87171);
const Color _text     = Color(0xFFE2E8F0);
const Color _textSub  = Color(0xFF94A3B8);
const Color _textDim  = Color(0xFF475569);
const Color _divider  = Color(0xFF1E2D42);

// ══════════════════════════════════════════════════════════════════════════════
//  MODELO
// ══════════════════════════════════════════════════════════════════════════════

class Medicamento {
  String nombre;
  int pastillasPorDosis;
  List<int> horas; // 0–23

  Medicamento({required this.nombre, this.pastillasPorDosis = 1, List<int>? horas})
      : horas = horas ?? [];
}

// ══════════════════════════════════════════════════════════════════════════════
//  ONBOARDING SCREEN  (4 pasos)
// ══════════════════════════════════════════════════════════════════════════════

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;
  static const int _total = 4;

  // Datos del paciente
  final _nameCtrl   = TextEditingController();
  final _ageCtrl    = TextEditingController();
  final _doctorCtrl = TextEditingController();

  // Medicamentos
  final List<Medicamento> _meds = [];

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _doctorCtrl.dispose();
    super.dispose();
  }

  void _next() => _pageCtrl.nextPage(
    duration: const Duration(milliseconds: 380),
    curve: Curves.easeInOutCubic,
  );

  void _back() => _pageCtrl.previousPage(
    duration: const Duration(milliseconds: 380),
    curve: Curves.easeInOutCubic,
  );

  bool get _canProceed => switch (_page) {
    0 => true,
    1 => _nameCtrl.text.trim().isNotEmpty && _ageCtrl.text.trim().isNotEmpty,
    2 => _meds.isNotEmpty && _meds.every((m) => m.horas.isNotEmpty),
    _ => true,
  };

  void _finish() {
    // TODO: persistir config (SharedPreferences / enviar a Cloudflare Worker)
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            _ProgressBar(current: _page, total: _total),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _WelcomePage(onStart: _next),
                  _PatientPage(
                    nameCtrl: _nameCtrl,
                    ageCtrl: _ageCtrl,
                    doctorCtrl: _doctorCtrl,
                    onChanged: () => setState(() {}),
                  ),
                  _MedicamentosPage(meds: _meds, onChanged: () => setState(() {})),
                  _ConfirmPage(
                    nombre: _nameCtrl.text,
                    edad: _ageCtrl.text,
                    doctor: _doctorCtrl.text,
                    meds: _meds,
                  ),
                ],
              ),
            ),
            if (_page > 0)
              _BottomNav(
                page: _page,
                total: _total,
                canProceed: _canProceed,
                onNext: _page == _total - 1 ? _finish : _next,
                onBack: _back,
              ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  PROGRESS BAR
// ══════════════════════════════════════════════════════════════════════════════

class _ProgressBar extends StatelessWidget {
  final int current, total;
  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
    child: Row(
      children: List.generate(total, (i) {
        final active = i <= current;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: active ? _sky : _divider,
              borderRadius: BorderRadius.circular(4),
              boxShadow: i == current
                  ? [BoxShadow(color: _sky.withOpacity(0.55), blurRadius: 7)]
                  : null,
            ),
          ),
        );
      }),
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  BOTTOM NAV
// ══════════════════════════════════════════════════════════════════════════════

class _BottomNav extends StatelessWidget {
  final int page, total;
  final bool canProceed;
  final VoidCallback onNext, onBack;
  const _BottomNav({
    required this.page, required this.total,
    required this.canProceed, required this.onNext, required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = page == total - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Row(
        children: [
          // Atrás
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _divider),
              ),
              child: const Icon(Icons.arrow_back_rounded, color: _textSub),
            ),
          ),
          const SizedBox(width: 12),
          // Siguiente / Empezar
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: canProceed ? 1.0 : 0.35,
              child: GestureDetector(
                onTap: canProceed ? onNext : null,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: canProceed
                        ? const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)])
                        : null,
                    color: canProceed ? null : _card,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: canProceed
                        ? [BoxShadow(color: _sky.withOpacity(0.32), blurRadius: 22, offset: const Offset(0, 5))]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      isLast ? 'Empezar' : 'Siguiente',
                      style: const TextStyle(
                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  PASO 0 — BIENVENIDA
// ══════════════════════════════════════════════════════════════════════════════

class _WelcomePage extends StatelessWidget {
  final VoidCallback onStart;
  const _WelcomePage({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(flex: 2),
          // Logo
          Container(
            width: 96, height: 96,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_sky.withOpacity(0.22), _indigo.withOpacity(0.18)],
              ),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: _sky.withOpacity(0.3), width: 1.5),
              boxShadow: [BoxShadow(color: _sky.withOpacity(0.18), blurRadius: 48)],
            ),
            child: const Icon(Icons.medication_rounded, color: _sky, size: 46),
          ),
          const SizedBox(height: 28),
          const Text('PillMonitor',
            style: TextStyle(
              color: _text, fontSize: 36, fontWeight: FontWeight.w800, letterSpacing: -1.5,
            )),
          const SizedBox(height: 10),
          const Text(
            'Configura el perfil del paciente y su horario de medicamentos para comenzar el monitoreo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textSub, fontSize: 15, height: 1.55),
          ),
          const Spacer(flex: 1),
          // Features
          ...[
            (Icons.person_rounded,              'Perfil del paciente',       'Nombre, edad y doctor'),
            (Icons.medication_liquid_rounded,    'Medicamentos',              'Pastillas, dosis y horarios'),
            (Icons.notifications_active_rounded, 'Alertas en tiempo real',   'Notificaciones vía FCM'),
          ].map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: _sky.withOpacity(0.09),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: _sky.withOpacity(0.18)),
                  ),
                  child: Icon(f.$1, color: _sky, size: 20),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(f.$2, style: const TextStyle(color: _text, fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(f.$3, style: const TextStyle(color: _textDim, fontSize: 12.5)),
                  ],
                ),
              ],
            ),
          )),
          const Spacer(flex: 1),
          GestureDetector(
            onTap: onStart,
            child: Container(
              width: double.infinity, height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: _sky.withOpacity(0.35), blurRadius: 26, offset: const Offset(0, 6))],
              ),
              child: const Center(
                child: Text('Comenzar configuración',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  PASO 1 — DATOS DEL PACIENTE
// ══════════════════════════════════════════════════════════════════════════════

class _PatientPage extends StatelessWidget {
  final TextEditingController nameCtrl, ageCtrl, doctorCtrl;
  final VoidCallback onChanged;
  const _PatientPage({
    required this.nameCtrl, required this.ageCtrl,
    required this.doctorCtrl, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          const _StepHeader(
            icon: Icons.person_rounded, step: '01',
            title: 'Perfil del Paciente',
            subtitle: 'Datos básicos de la persona a monitorear.',
          ),
          const SizedBox(height: 30),
          _Field(
            ctrl: nameCtrl, label: 'Nombre completo',
            hint: 'María González', icon: Icons.badge_rounded,
            onChanged: onChanged,
          ),
          const SizedBox(height: 14),
          _Field(
            ctrl: ageCtrl, label: 'Edad', hint: '72',
            icon: Icons.cake_rounded,
            keyboardType: TextInputType.number,
            formatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: onChanged,
          ),
          const SizedBox(height: 14),
          _Field(
            ctrl: doctorCtrl, label: 'Médico tratante (opcional)',
            hint: 'Dr. Ramírez', icon: Icons.local_hospital_rounded,
            onChanged: onChanged,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  PASO 2 — MEDICAMENTOS
// ══════════════════════════════════════════════════════════════════════════════

class _MedicamentosPage extends StatelessWidget {
  final List<Medicamento> meds;
  final VoidCallback onChanged;
  const _MedicamentosPage({required this.meds, required this.onChanged});

  Future<void> _openSheet(BuildContext ctx, {Medicamento? editing, int? index}) async {
    final result = await showModalBottomSheet<Medicamento>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMedSheet(editing: editing),
    );
    if (result == null) return;
    if (index != null) {
      meds[index] = result;
    } else {
      meds.add(result);
    }
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 28, 24, 0),
          child: _StepHeader(
            icon: Icons.medication_liquid_rounded, step: '02',
            title: 'Medicamentos',
            subtitle: 'Agrega cada pastilla con su dosis y horarios.',
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: meds.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.medication_outlined, color: _textDim, size: 56),
                      const SizedBox(height: 12),
                      const Text('Sin medicamentos',
                        style: TextStyle(color: _textSub, fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      const Text('Toca el botón de abajo para agregar',
                        style: TextStyle(color: _textDim, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: meds.length,
                  itemBuilder: (ctx, i) => _MedCard(
                    med: meds[i],
                    onEdit:   () => _openSheet(ctx, editing: meds[i], index: i),
                    onDelete: () { meds.removeAt(i); onChanged(); },
                  ),
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: GestureDetector(
            onTap: () => _openSheet(context),
            child: Container(
              width: double.infinity, height: 52,
              decoration: BoxDecoration(
                color: _sky.withOpacity(0.07),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _sky.withOpacity(0.28)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: _sky, size: 20),
                  SizedBox(width: 8),
                  Text('Agregar medicamento',
                    style: TextStyle(color: _sky, fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tarjeta de medicamento en la lista ───────────────────────────────────────

class _MedCard extends StatelessWidget {
  final Medicamento med;
  final VoidCallback onEdit, onDelete;
  const _MedCard({required this.med, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _sky.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.medication_rounded, color: _sky, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(med.nombre,
                  style: const TextStyle(color: _text, fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              IconButton(
                padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                icon: const Icon(Icons.edit_rounded, color: _textDim, size: 18),
                onPressed: onEdit,
              ),
              const SizedBox(width: 12),
              IconButton(
                padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                icon: Icon(Icons.delete_outline_rounded, color: _rose.withOpacity(0.8), size: 18),
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _MiniChip(
            icon: Icons.circle, iconSize: 7,
            label: '${med.pastillasPorDosis} pastilla${med.pastillasPorDosis > 1 ? 's' : ''} por dosis',
            color: _indigo,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: med.horas.map((h) => _MiniChip(
              icon: Icons.schedule_rounded,
              label: _fmtH(h),
              color: _emerald,
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// ── Bottom sheet para agregar / editar ───────────────────────────────────────

class _AddMedSheet extends StatefulWidget {
  final Medicamento? editing;
  const _AddMedSheet({this.editing});

  @override
  State<_AddMedSheet> createState() => _AddMedSheetState();
}

class _AddMedSheetState extends State<_AddMedSheet> {
  final _nameCtrl = TextEditingController();
  int _cantidad = 1;
  final Set<int> _horas = {};

  @override
  void initState() {
    super.initState();
    if (widget.editing case final e?) {
      _nameCtrl.text = e.nombre;
      _cantidad = e.pastillasPorDosis;
      _horas.addAll(e.horas);
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); super.dispose(); }

  bool get _valid => _nameCtrl.text.trim().isNotEmpty && _horas.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + bottomPad),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 14),
                width: 40, height: 4,
                decoration: BoxDecoration(color: _divider, borderRadius: BorderRadius.circular(4)),
              ),
            ),
            Text(
              widget.editing != null ? 'Editar medicamento' : 'Nuevo medicamento',
              style: const TextStyle(
                color: _text, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 22),

            // Nombre
            _Field(
              ctrl: _nameCtrl,
              label: 'Nombre del medicamento',
              hint: 'Paracetamol, Ibuprofeno...',
              icon: Icons.medication_rounded,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 22),

            // Cantidad
            const Text('Pastillas por dosis',
              style: TextStyle(color: _textSub, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                _RoundBtn(
                  icon: Icons.remove_rounded,
                  onTap: _cantidad > 1 ? () => setState(() => _cantidad--) : null,
                ),
                const SizedBox(width: 18),
                Text('$_cantidad',
                  style: const TextStyle(color: _text, fontSize: 30, fontWeight: FontWeight.w800)),
                const SizedBox(width: 18),
                _RoundBtn(
                  icon: Icons.add_rounded,
                  onTap: _cantidad < 10 ? () => setState(() => _cantidad++) : null,
                ),
                const SizedBox(width: 14),
                Text(_cantidad == 1 ? 'pastilla' : 'pastillas',
                  style: const TextStyle(color: _textDim, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 24),

            // Horarios — grid de 24 horas
            Row(
              children: [
                const Text('Horarios de toma',
                  style: TextStyle(color: _textSub, fontSize: 13, fontWeight: FontWeight.w600)),
                const Spacer(),
                if (_horas.isNotEmpty)
                  Text('${_horas.length} seleccionado${_horas.length > 1 ? 's' : ''}',
                    style: TextStyle(color: _sky.withOpacity(0.8), fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6, crossAxisSpacing: 8,
                mainAxisSpacing: 8, childAspectRatio: 1,
              ),
              itemCount: 24,
              itemBuilder: (_, h) {
                final sel = _horas.contains(h);
                return GestureDetector(
                  onTap: () => setState(() => sel ? _horas.remove(h) : _horas.add(h)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      color: sel ? _sky.withOpacity(0.18) : _card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel ? _sky : _divider,
                        width: sel ? 1.5 : 1,
                      ),
                      boxShadow: sel
                          ? [BoxShadow(color: _sky.withOpacity(0.28), blurRadius: 8)]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        _fmtH2(h),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: sel ? _sky : _textDim,
                          fontSize: 9.5,
                          fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Guardar
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: _valid ? 1.0 : 0.35,
              child: GestureDetector(
                onTap: _valid
                    ? () => Navigator.pop(
                        context,
                        Medicamento(
                          nombre: _nameCtrl.text.trim(),
                          pastillasPorDosis: _cantidad,
                          horas: _horas.toList()..sort(),
                        ),
                      )
                    : null,
                child: Container(
                  width: double.infinity, height: 52,
                  decoration: BoxDecoration(
                    gradient: _valid
                        ? const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)])
                        : null,
                    color: _valid ? null : _card,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _valid
                        ? [BoxShadow(color: _sky.withOpacity(0.32), blurRadius: 20, offset: const Offset(0, 4))]
                        : null,
                  ),
                  child: const Center(
                    child: Text('Guardar medicamento',
                      style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  PASO 3 — CONFIRMACIÓN
// ══════════════════════════════════════════════════════════════════════════════

class _ConfirmPage extends StatelessWidget {
  final String nombre, edad, doctor;
  final List<Medicamento> meds;
  const _ConfirmPage({
    required this.nombre, required this.edad,
    required this.doctor, required this.meds,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          const _StepHeader(
            icon: Icons.check_circle_rounded, step: '✓',
            title: 'Confirmar', subtitle: 'Revisa todo antes de empezar.',
          ),
          const SizedBox(height: 24),

          // Paciente
          _ConfirmCard(
            title: 'Paciente', icon: Icons.person_rounded,
            child: Column(
              children: [
                _CRow(label: 'Nombre', value: nombre.isEmpty ? '—' : nombre),
                _CRow(label: 'Edad',   value: edad.isEmpty   ? '—' : '$edad años'),
                _CRow(label: 'Doctor', value: doctor.isEmpty ? 'No especificado' : doctor, last: true),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Medicamentos
          _ConfirmCard(
            title: 'Medicamentos (${meds.length})', icon: Icons.medication_rounded,
            child: Column(
              children: meds.asMap().entries.map((e) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (e.key > 0) Divider(color: _divider, height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(e.value.nombre,
                              style: const TextStyle(color: _text, fontSize: 14, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(
                              '${e.value.pastillasPorDosis} pastilla${e.value.pastillasPorDosis > 1 ? 's' : ''} por dosis',
                              style: const TextStyle(color: _textSub, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Wrap(
                        spacing: 4, runSpacing: 4,
                        children: e.value.horas.map((h) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: _emerald.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _emerald.withOpacity(0.22)),
                          ),
                          child: Text(_fmtH(h),
                            style: const TextStyle(
                              color: _emerald, fontSize: 10, fontWeight: FontWeight.w700,
                            )),
                        )).toList(),
                      ),
                    ],
                  ),
                ],
              )).toList(),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  WIDGETS REUTILIZABLES
// ══════════════════════════════════════════════════════════════════════════════

class _StepHeader extends StatelessWidget {
  final IconData icon;
  final String step, title, subtitle;
  const _StepHeader({required this.icon, required this.step, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _sky.withOpacity(0.09),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _sky.withOpacity(0.22)),
        ),
        child: Icon(icon, color: _sky, size: 24),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
              style: const TextStyle(
                color: _text, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5,
              )),
            const SizedBox(height: 3),
            Text(subtitle, style: const TextStyle(color: _textSub, fontSize: 13)),
          ],
        ),
      ),
    ],
  );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, hint;
  final IconData icon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? formatters;
  final VoidCallback onChanged;

  const _Field({
    required this.ctrl, required this.label, required this.hint,
    required this.icon, required this.onChanged,
    this.keyboardType = TextInputType.text, this.formatters,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: _textSub, fontSize: 13, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextField(
        controller: ctrl,
        onChanged: (_) => onChanged(),
        keyboardType: keyboardType,
        inputFormatters: formatters,
        style: const TextStyle(color: _text, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: _textDim),
          prefixIcon: Icon(icon, color: _textDim, size: 20),
          filled: true, fillColor: _card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _divider),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _sky, width: 1.5),
          ),
        ),
      ),
    ],
  );
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _RoundBtn({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: onTap != null ? 1.0 : 0.3,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: _cardHigh, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _divider),
        ),
        child: Icon(icon, color: _sky, size: 20),
      ),
    ),
  );
}

class _MiniChip extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final String label;
  final Color color;
  const _MiniChip({required this.icon, required this.label, required this.color, this.iconSize = 13});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.09),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.2)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: iconSize),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

class _ConfirmCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _ConfirmCard({required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: _card, borderRadius: BorderRadius.circular(22),
      border: Border.all(color: _divider),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _sky, size: 15),
            const SizedBox(width: 7),
            Text(title,
              style: const TextStyle(
                color: _textSub, fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.4,
              )),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

class _CRow extends StatelessWidget {
  final String label, value;
  final bool last;
  const _CRow({required this.label, required this.value, this.last = false});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: last ? 0 : 10),
    child: Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(label, style: const TextStyle(color: _textDim, fontSize: 13)),
        ),
        Expanded(
          child: Text(value,
            style: const TextStyle(color: _text, fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ],
    ),
  );
}

// ══════════════════════════════════════════════════════════════════════════════
//  HELPERS DE FORMATO
// ══════════════════════════════════════════════════════════════════════════════

String _fmtH(int h) {
  if (h == 0)  return '12 AM';
  if (h < 12)  return '$h AM';
  if (h == 12) return '12 PM';
  return '${h - 12} PM';
}

// Formato de 2 líneas para el grid (más compacto)
String _fmtH2(int h) {
  if (h == 0)  return '12\nAM';
  if (h < 12)  return '$h\nAM';
  if (h == 12) return '12\nPM';
  return '${h - 12}\nPM';
}
