import 'dart:io';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../services/share_service.dart';
import '../services/pdf_export_service.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});
  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<File> _photos = [];
  List<File> _selected = [];
  CaptureMode? _filter;
  bool _selectMode = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final photos = await StorageService.listLocalPhotos(mode: _filter);
    setState(() {
      _photos = photos.reversed.toList();
      _selected.clear();
      _selectMode = false;
    });
  }

  Future<void> _share(File f) async {
    try {
      await ShareService.shareImage(filePath: f.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _exportPDF() async {
    if (_selected.isEmpty) return;
    try {
      final path = await PDFExportService.exportMultipleImagesToPDF(
        imagePaths: _selected.map((f) => f.path).toList(),
      );
      await ShareService.sharePDF(pdfPath: path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Fotos'),
        actions: [
          IconButton(
            icon: Icon(_selectMode ? Icons.close : Icons.checklist),
            onPressed: () => setState(() {
              _selectMode = !_selectMode;
              if (!_selectMode) _selected.clear();
            }),
          ),
          PopupMenuButton<CaptureMode?>(
            onSelected: (m) {
              setState(() => _filter = m);
              _load();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: null, child: Text('Todas')),
              const PopupMenuItem(value: CaptureMode.portrait, child: Text('Retratos')),
              const PopupMenuItem(value: CaptureMode.proshot, child: Text('ProShot')),
              const PopupMenuItem(value: CaptureMode.document, child: Text('Docs')),
              const PopupMenuItem(value: CaptureMode.expert, child: Text('Experto')),
            ],
            child: const Icon(Icons.filter_list),
          ),
        ],
      ),
      bottomNavigationBar: _selectMode && _selected.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _share(_selected.first),
                    icon: const Icon(Icons.share),
                    label: Text('Compartir (${_selected.length})'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _exportPDF,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('PDF'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            )
          : null,
      body: _photos.isEmpty
          ? const Center(child: Text('No hay fotos guardadas'))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _photos.length,
              itemBuilder: (_, i) {
                final p = _photos[i];
                final isSel = _selected.contains(p);
                return GestureDetector(
                  onTap: () {
                    if (_selectMode) {
                      setState(() {
                        if (isSel) _selected.remove(p);
                        else _selected.add(p);
                      });
                    } else {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.file(p),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _share(p);
                                    },
                                    icon: const Icon(Icons.share),
                                    label: const Text('Compartir'),
                                  ),
                                  TextButton.icon(
                                    onPressed: () async {
                                      await StorageService.deleteLocalPhoto(p.path);
                                      Navigator.pop(context);
                                      _load();
                                    },
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    label: const Text('Eliminar',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: isSel ? Border.all(color: Colors.blue, width: 3) : null,
                        ),
                        child: Image.file(p, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                      ),
                      if (_selectMode)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isSel ? Colors.blue : Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue, width: 2),
                            ),
                            child: isSel
                                ? const Icon(Icons.check, color: Colors.white, size: 16)
                                : null,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
