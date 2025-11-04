import 'package:flutter/material.dart';
import '../../data/models/tugas_model.dart';
import 'tugas_card.dart';

class TugasListView extends StatelessWidget {
  final List<TugasModel> tugasList;
  final bool isTutor;

  const TugasListView({
    super.key,
    required this.tugasList,
    this.isTutor = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tugasList.length,
      itemBuilder: (context, index) {
        final tugas = tugasList[index];
        return TugasCard(
          tugas: tugas,
          isTutor: isTutor,
          onTap: () {
            // navigasi ke submission_page
          },
        );
      },
    );
  }
}
