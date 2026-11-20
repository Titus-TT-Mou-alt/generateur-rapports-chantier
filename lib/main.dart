import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'data_store.dart';

const petroleum = Color(0xFF164B57);
const turquoise = Color(0xFFD9EEF0);
const orange = Color(0xFFF2A23A);
const ink = Color(0xFF183238);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataStore.instance.init();
  runApp(const SiteReportApp());
}

class SiteReportApp extends StatelessWidget {
  const SiteReportApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Département électromécanique – Générateur de rapports',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF7FAFA),
      colorScheme: ColorScheme.fromSeed(seedColor: petroleum,
        primary: petroleum, secondary: orange, surface: Colors.white),
      appBarTheme: const AppBarTheme(backgroundColor: petroleum,
        foregroundColor: Colors.white),
      inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
    ),
    home: const HomePage(),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  List<Map<String, Object?>> visits = [];
  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final rows = await DataStore.instance.visits();
    if (mounted) setState(() => visits = rows);
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Département électromécanique'),
      actions: const [Padding(padding: EdgeInsets.only(right: 16),
        child: Icon(Icons.construction, color: orange, size: 29))]),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Container(padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: petroleum,
          borderRadius: BorderRadius.circular(20)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('GÉNÉRATEUR DE RAPPORTS',
              style: TextStyle(color: turquoise, letterSpacing: 1.2)),
            SizedBox(height: 8),
            Text('Vos visites de chantier,\nsimplement.',
              style: TextStyle(color: Colors.white, fontSize: 25,
                fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Fonctionne hors connexion',
              style: TextStyle(color: Colors.white70)),
          ])),
      const SizedBox(height: 18),
      _ActionTile(icon: Icons.add_circle_outline, title: 'Nouvelle visite',
        subtitle: 'Créer un compte rendu', primary: true,
        onTap: () async {
          await Navigator.push(context,
            MaterialPageRoute(builder: (_) => const VisitPage()));
          _load();
        }),
      _ActionTile(icon: Icons.folder_open_outlined, title: 'Mes rapports',
        subtitle: '${visits.length} visite(s) enregistrée(s) sur cet appareil',
        onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => ReportsPage(visits: visits)))),
      const _ActionTile(icon: Icons.photo_camera_outlined, title: 'Photos',
        subtitle: 'Ajoutées directement aux lieux visités'),
      const _ActionTile(icon: Icons.mic_none, title: 'Dictée',
        subtitle: 'Saisie vocale à intégrer selon les capacités hors ligne du téléphone'),
      const _ActionTile(icon: Icons.tune, title: 'Divers',
        subtitle: 'Options complémentaires'),
      const SizedBox(height: 10),
      const Text('Les visites et leurs pièces jointes sont conservées localement.',
        style: TextStyle(color: Colors.black54, fontSize: 12)),
    ]),
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.title,
    required this.subtitle, this.onTap, this.primary = false});
  final IconData icon; final String title; final String subtitle;
  final VoidCallback? onTap; final bool primary;
  @override
  Widget build(BuildContext context) => Card(
    elevation: 0, color: primary ? turquoise : Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: primary ? petroleum : const Color(0xFFE2E9EA))),
    child: ListTile(contentPadding: const EdgeInsets.symmetric(
      horizontal: 16, vertical: 7),
      leading: CircleAvatar(backgroundColor: primary ? petroleum : turquoise,
        foregroundColor: primary ? Colors.white : petroleum, child: Icon(icon)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold,
        color: ink)),
      subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right),
      onTap: onTap),
  );
}

class VisitPage extends StatefulWidget {
  const VisitPage({super.key});
  @override
  State<VisitPage> createState() => _VisitPageState();
}
class _VisitPageState extends State<VisitPage> {
  final site = TextEditingController();
  final date = TextEditingController(text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  final subject = TextEditingController();
  final people = <PersonDraft>[];
  final zones = <ZoneDraft>[];
  bool saving = false;

  @override
  void dispose() {
    site.dispose(); date.dispose(); subject.dispose();
    for (final p in people) { p.name.dispose(); p.role.dispose(); }
    for (final z in zones) { z.place.dispose(); z.comment.dispose(); }
    super.dispose();
  }
  Future<void> _save() async {
    if (site.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Indique le site de la visite.')));
      return;
    }
    setState(() => saving = true);
    try {
      await DataStore.instance.saveVisit(site: site.text.trim(),
        date: date.text.trim(), subject: subject.text.trim(),
        people: people.map((p) => {'name': p.name.text, 'role': p.role.text}).toList(),
        zones: zones.map((z) => {'place': z.place.text,
          'comment': z.comment.text, 'photos': z.photos}).toList());
      if (mounted) Navigator.pop(context);
    } finally { if (mounted) setState(() => saving = false); }
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nouvelle visite')),
    body: ListView(padding: const EdgeInsets.all(18), children: [
      const _Heading('1. Informations de la visite'),
      _field('Site / lieu de la visite', site, hint: 'Ex. École Sainte-Madeleine'),
      _field('Date', date),
      _field('Objet / suivi de chantier', subject,
        hint: 'Texte libre : objet, contexte et suivi…', lines: 3),
      const SizedBox(height: 14),
      Row(children: [
        const Expanded(child: _Heading('2. Personnes présentes sur site')),
        TextButton.icon(onPressed: () => setState(() => people.add(PersonDraft())),
          icon: const Icon(Icons.person_add_alt_1), label: const Text('Ajouter')),
      ]),
      ...people.asMap().entries.map((e) => Card(elevation: 0,
        child: Padding(padding: const EdgeInsets.all(10),
          child: Row(children: [
            const Icon(Icons.person, color: petroleum),
            const SizedBox(width: 8),
            Expanded(child: _field('Nom', e.value.name, hint: 'Nom et prénom')),
            const SizedBox(width: 8),
            Expanded(child: _field('Fonction', e.value.role)),
            IconButton(onPressed: () => setState(() => people.removeAt(e.key)),
              icon: const Icon(Icons.delete_outline)),
          ])))),
      const SizedBox(height: 14),
      Row(children: [
        const Expanded(child: _Heading('3. Constats par lieu visité')),
        TextButton.icon(onPressed: () => setState(() => zones.add(ZoneDraft())),
          icon: const Icon(Icons.add), label: const Text('Ajouter un lieu')),
      ]),
      ...zones.asMap().entries.map((e) => _zoneCard(e.key, e.value)),
      const SizedBox(height: 18),
      FilledButton.icon(
        style: FilledButton.styleFrom(backgroundColor: petroleum,
          padding: const EdgeInsets.all(16)),
        onPressed: saving ? null : _save,
        icon: const Icon(Icons.save_outlined),
        label: Text(saving ? 'Enregistrement…' : 'Enregistrer la visite'),
      ),
    ]),
  );

  Widget _zoneCard(int index, ZoneDraft z) => Card(
    color: turquoise, elevation: 0, margin: const EdgeInsets.only(bottom: 12),
    child: Padding(padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: _field('Lieu visité', z.place,
            hint: 'Cour, salle de classe, chaufferie…')),
          IconButton(onPressed: () => setState(() => zones.removeAt(index)),
            icon: const Icon(Icons.delete_outline)),
        ]),
        _field('Constat / avancement / vigilance / prochaine étape',
          z.comment, hint: 'Décrivez librement ce qui est constaté…', lines: 4),
        Wrap(spacing: 8, runSpacing: 8, children: [
          OutlinedButton.icon(onPressed: () => _addPhoto(z),
            icon: const Icon(Icons.add_a_photo_outlined),
            label: const Text('Ajouter une photo')),
          Text('${z.photos.length} photo(s) associée(s)',
            style: const TextStyle(color: petroleum)),
        ]),
        if (z.photos.isNotEmpty) Wrap(spacing: 8, children: z.photos.map((p) =>
          ClipRRect(borderRadius: BorderRadius.circular(8),
            child: Image.file(File(p), width: 76, height: 76, fit: BoxFit.cover)
          )).toList()),
      ])),
  );
  Future<void> _addPhoto(ZoneDraft z) async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera,
      imageQuality: 82, maxWidth: 1800);
    if (image != null) {
      final permanentPath = await DataStore.instance.keepPhoto(image.path);
      if (mounted) setState(() => z.photos.add(permanentPath));
    }
  }
  Widget _field(String label, TextEditingController c,
    {String? hint, int lines = 1}) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(controller: c, maxLines: lines,
        decoration: InputDecoration(labelText: label, hintText: hint)));
}

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key, required this.visits});
  final List<Map<String, Object?>> visits;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Mes rapports')),
    body: visits.isEmpty
      ? const Center(child: Text('Aucune visite enregistrée.'))
      : ListView.builder(itemCount: visits.length, itemBuilder: (context, i) {
        final v = visits[i];
        return ListTile(leading: const Icon(Icons.description, color: petroleum),
          title: Text('${v['site']}'),
          subtitle: Text('${v['date']}'),
          trailing: IconButton(icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              final data = await DataStore.instance.visitDetails(v['id'] as int);
              await _makePdf(data);
            }));
      }),
  );
}

Future<void> _makePdf(Map<String, Object?> v) async {
  final doc = pw.Document();
  final people = (v['people'] as List).cast<Map<String, Object?>>();
  final zones = (v['zones'] as List).cast<Map<String, Object?>>();
  doc.addPage(pw.MultiPage(
    header: (_) => pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromInt(0xFF164B57)))),
      child: pw.Text('DÉPARTEMENT ÉLECTROMÉCANIQUE',
        style: pw.TextStyle(color: PdfColor.fromInt(0xFF164B57),
          fontWeight: pw.FontWeight.bold))),
    build: (_) => [
      pw.SizedBox(height: 14),
      pw.Text('COMPTE RENDU DE VISITE DE CHANTIER',
        style: pw.TextStyle(fontSize: 17, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 12),
      pw.Text('Site : ${v['site']}'),
      pw.Text('Date : ${v['date']}'),
      pw.Text('Objet / suivi : ${v['subject']}'),
      pw.SizedBox(height: 12),
      pw.Text('PERSONNES PRÉSENTES SUR SITE',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromInt(0xFF164B57))),
      pw.Wrap(spacing: 18, runSpacing: 8, children: people.map((p) =>
        pw.Container(width: 230, child: pw.Text(
          '• ${p['name']} — ${p['role']}'))).toList()),
      pw.SizedBox(height: 14),
      pw.Text('CONSTATS PAR LIEU',
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromInt(0xFF164B57))),
      ...zones.map((z) => pw.Container(
        margin: const pw.EdgeInsets.only(top: 8),
        padding: const pw.EdgeInsets.all(9),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColor.fromInt(0xFFD9EEF0))),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('${z['place']}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 4),
            pw.Text('${z['comment']}'),
            pw.SizedBox(height: 4),
            if ((z['photos'] as List).isNotEmpty)
              pw.Wrap(
                spacing: 8,
                runSpacing: 8,
                children: (z['photos'] as List).map((path) {
                  final file = File(path.toString());
                  if (!file.existsSync()) {
                    return pw.Text('Photo indisponible',
                      style: const pw.TextStyle(fontSize: 9));
                  }
                  final bytes = file.readAsBytesSync();
                  return pw.Container(
                    width: 220,
                    height: 145,
                    child: pw.Image(pw.MemoryImage(bytes), fit: pw.BoxFit.contain),
                  );
                }).toList(),
              ),
          ]))),
    ],
  ));
  await Printing.layoutPdf(onLayout: (_) async => doc.save());
}

class PersonDraft {
  final name = TextEditingController();
  final role = TextEditingController();
}
class ZoneDraft {
  final place = TextEditingController();
  final comment = TextEditingController();
  final photos = <String>[];
}
class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: const TextStyle(fontSize: 17,
      fontWeight: FontWeight.bold, color: petroleum)));
}
