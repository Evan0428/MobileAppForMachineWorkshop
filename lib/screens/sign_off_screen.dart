import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';
import '../state.dart';
import '../models.dart';

class SignOffScreen extends StatefulWidget {
  static const routeName = '/sign';
  const SignOffScreen({super.key});

  @override
  State<SignOffScreen> createState() => _SignOffScreenState();
}

class _SignOffScreenState extends State<SignOffScreen> {
  final sigCtrl = SignatureController(penStrokeWidth: 3, penColor: Colors.black);

  @override
  void dispose() {
    sigCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveSignature(String jobId) async {
    if (sigCtrl.isEmpty) return;
    final img = await sigCtrl.toImage();
    if (img == null) return;
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}_sign.png');
    await file.writeAsBytes(bytes.buffer.asUint8List());

    final c = JobDetailController();
    await c.init(jobId);
    await c.addPhotoNote(file.path);
    await c.setStatus(JobStatus.signedOff);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signature saved, job completed.')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final jobId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(title: const Text('Digital Sign-off')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Customer Signature', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black26),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Signature(controller: sigCtrl, backgroundColor: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: sigCtrl.clear, child: const Text('Clear'))),
                const SizedBox(width: 12),
                Expanded(child: FilledButton(onPressed: () => _saveSignature(jobId), child: const Text('Confirm'))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
