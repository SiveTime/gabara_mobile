import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/class_provider.dart';
import '../widgets/class_card.dart';
import 'package:gabara_mobile/core/widgets/common_button.dart';

class ClassPage extends StatelessWidget {
  const ClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClassProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Kelas')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.classes.length,
              itemBuilder: (context, index) {
                final classItem = provider.classes[index];
                return ClassCard(classEntity: classItem);
              },
            ),
      floatingActionButton: CommonButton(
        label: 'Buat Kelas Baru',
        onPressed: () => Navigator.pushNamed(context, '/create_class'),
      ),
    );
  }
}
