import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tugas_provider.dart';
import '../widgets/tugas_list_view.dart';
import '../widgets/tugas_empty_state.dart';

class TugasPage extends StatefulWidget {
  final bool isTutor;

  const TugasPage({super.key, this.isTutor = false});

  @override
  State<TugasPage> createState() => _TugasPageState();
}

class _TugasPageState extends State<TugasPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TugasProvider>().fetchTugas(isTutor: widget.isTutor);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TugasProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isTutor ? 'Daftar Tugas (Tutor)' : 'Daftar Tugas'),
      ),
      floatingActionButton: widget.isTutor
          ? FloatingActionButton(
              onPressed: () {
                // Navigasi ke halaman pembuatan tugas baru
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
              ? Center(child: Text(provider.errorMessage!))
              : provider.tugasList.isEmpty
                  ? const TugasEmptyState()
                  : TugasListView(
                      tugasList: provider.tugasList,
                      isTutor: widget.isTutor,
                    ),
    );
  }
}
