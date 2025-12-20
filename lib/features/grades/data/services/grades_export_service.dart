// lib/features/grades/data/services/grades_export_service.dart
// Export service for grades to PDF and Excel

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../models/grade_model.dart';
import '../../domain/entities/grade_entity.dart';
import 'grades_analytics_service.dart';

/// Service untuk export grades ke PDF dan Excel
class GradesExportService {
  final GradesAnalyticsService _analyticsService = GradesAnalyticsService();

  /// Export grades to PDF
  Future<String?> exportToPDF({
    required List<GradeModel> grades,
    required Map<String, List<GradeModel>> gradesByClass,
    required String studentName,
    required String studentId,
  }) async {
    try {
      final pdf = pw.Document();
      final insights = _analyticsService.getPerformanceInsights(grades);
      final distribution = _analyticsService.calculateGradeDistribution(grades);

      // Page 1: Summary & Overview
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            return [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.only(bottom: 20),
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(width: 2, color: PdfColors.blue),
                  ),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'LAPORAN NILAI AKADEMIK',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Gabara Education Learning Management System',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Student Info
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'INFORMASI SISWA',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Row(
                      children: [
                        pw.Expanded(child: pw.Text('Nama: $studentName')),
                        pw.Expanded(child: pw.Text('ID: $studentId')),
                      ],
                    ),
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            'Tanggal Laporan: ${DateFormat('dd MMMM yyyy', 'id_ID').format(DateTime.now())}',
                          ),
                        ),
                        pw.Expanded(
                          child: pw.Text('Total Nilai: ${grades.length}'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Performance Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'RINGKASAN PERFORMA',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: _buildSummaryCard(
                            'Rata-rata Keseluruhan',
                            '${insights['averageScore'].toStringAsFixed(1)}%',
                            _getGradeColor(insights['averageScore']),
                          ),
                        ),
                        pw.SizedBox(width: 16),
                        pw.Expanded(
                          child: _buildSummaryCard(
                            'Tingkat Peningkatan',
                            '${insights['improvementRate'].toStringAsFixed(1)}%',
                            insights['improvementRate'] >= 0
                                ? PdfColors.green
                                : PdfColors.red,
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 12),
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: _buildSummaryCard(
                            'Mata Pelajaran Terkuat',
                            insights['strongestSubject'] ?? 'N/A',
                            PdfColors.green,
                          ),
                        ),
                        pw.SizedBox(width: 16),
                        pw.Expanded(
                          child: _buildSummaryCard(
                            'Perlu Peningkatan',
                            insights['weakestSubject'] ?? 'N/A',
                            PdfColors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Grade Distribution
              pw.Text(
                'DISTRIBUSI NILAI',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              _buildGradeDistributionTable(distribution),

              pw.SizedBox(height: 20),

              // Recommendations
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'REKOMENDASI',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      insights['recommendation'],
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ];
          },
        ),
      );

      // Page 2: Detailed Grades by Subject
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            final widgets = <pw.Widget>[
              pw.Text(
                'DETAIL NILAI PER MATA PELAJARAN',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
            ];

            gradesByClass.forEach((classId, classGrades) {
              if (classGrades.isNotEmpty) {
                final className =
                    classGrades.first.className ?? 'Unknown Class';
                final classAverage = GradeCalculator.calculateAverage(
                  classGrades,
                );

                widgets.addAll([
                  pw.Container(
                    padding: const pw.EdgeInsets.all(12),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey100,
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          className,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'Rata-rata: ${classAverage.toStringAsFixed(1)}%',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: _getGradeColor(classAverage),
                          ),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  _buildGradesTable(classGrades),
                  pw.SizedBox(height: 16),
                ]);
              }
            });

            return widgets;
          },
        ),
      );

      // Save PDF
      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/laporan_nilai_${studentId}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(await pdf.save());

      return file.path;
    } catch (e) {
      debugPrint('Error exporting to PDF: $e');
      return null;
    }
  }

  /// Export grades to Excel
  Future<String?> exportToExcel({
    required List<GradeModel> grades,
    required Map<String, List<GradeModel>> gradesByClass,
    required String studentName,
    required String studentId,
  }) async {
    try {
      final excel = Excel.createExcel();
      final insights = _analyticsService.getPerformanceInsights(grades);

      // Remove default sheet
      excel.delete('Sheet1');

      // Summary Sheet
      final summarySheet = excel['Ringkasan'];

      // Header
      summarySheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
        'LAPORAN NILAI AKADEMIK',
      );
      summarySheet.cell(CellIndex.indexByString('A2')).value = TextCellValue(
        'Gabara Education LMS',
      );
      summarySheet.cell(CellIndex.indexByString('A4')).value = TextCellValue(
        'Nama Siswa:',
      );
      summarySheet.cell(CellIndex.indexByString('B4')).value = TextCellValue(
        studentName,
      );
      summarySheet.cell(CellIndex.indexByString('A5')).value = TextCellValue(
        'ID Siswa:',
      );
      summarySheet.cell(CellIndex.indexByString('B5')).value = TextCellValue(
        studentId,
      );
      summarySheet.cell(CellIndex.indexByString('A6')).value = TextCellValue(
        'Tanggal Laporan:',
      );
      summarySheet.cell(CellIndex.indexByString('B6')).value = TextCellValue(
        DateFormat('dd/MM/yyyy').format(DateTime.now()),
      );

      // Performance Summary
      summarySheet.cell(CellIndex.indexByString('A8')).value = TextCellValue(
        'RINGKASAN PERFORMA',
      );
      summarySheet.cell(CellIndex.indexByString('A9')).value = TextCellValue(
        'Rata-rata Keseluruhan:',
      );
      summarySheet.cell(CellIndex.indexByString('B9')).value = DoubleCellValue(
        insights['averageScore'],
      );
      summarySheet.cell(CellIndex.indexByString('A10')).value = TextCellValue(
        'Tingkat Peningkatan:',
      );
      summarySheet.cell(CellIndex.indexByString('B10')).value = DoubleCellValue(
        insights['improvementRate'],
      );
      summarySheet.cell(CellIndex.indexByString('A11')).value = TextCellValue(
        'Mata Pelajaran Terkuat:',
      );
      summarySheet.cell(CellIndex.indexByString('B11')).value = TextCellValue(
        insights['strongestSubject'] ?? 'N/A',
      );
      summarySheet.cell(CellIndex.indexByString('A12')).value = TextCellValue(
        'Perlu Peningkatan:',
      );
      summarySheet.cell(CellIndex.indexByString('B12')).value = TextCellValue(
        insights['weakestSubject'] ?? 'N/A',
      );

      // Detailed Grades Sheet
      final detailSheet = excel['Detail Nilai'];

      // Headers
      detailSheet.cell(CellIndex.indexByString('A1')).value = TextCellValue(
        'Mata Pelajaran',
      );
      detailSheet.cell(CellIndex.indexByString('B1')).value = TextCellValue(
        'Item Penilaian',
      );
      detailSheet.cell(CellIndex.indexByString('C1')).value = TextCellValue(
        'Jenis',
      );
      detailSheet.cell(CellIndex.indexByString('D1')).value = TextCellValue(
        'Nilai',
      );
      detailSheet.cell(CellIndex.indexByString('E1')).value = TextCellValue(
        'Nilai Maksimal',
      );
      detailSheet.cell(CellIndex.indexByString('F1')).value = TextCellValue(
        'Persentase',
      );
      detailSheet.cell(CellIndex.indexByString('G1')).value = TextCellValue(
        'Grade',
      );
      detailSheet.cell(CellIndex.indexByString('H1')).value = TextCellValue(
        'Tanggal',
      );

      // Data
      int row = 2;
      for (final grade in grades) {
        detailSheet.cell(CellIndex.indexByString('A$row')).value =
            TextCellValue(grade.className ?? 'Unknown');
        detailSheet
            .cell(CellIndex.indexByString('B$row'))
            .value = TextCellValue(
          grade.itemTitle ?? (grade.isQuizGrade ? 'Quiz' : 'Tugas'),
        );
        detailSheet.cell(CellIndex.indexByString('C$row')).value =
            TextCellValue(grade.isQuizGrade ? 'Quiz' : 'Tugas');
        detailSheet.cell(CellIndex.indexByString('D$row')).value =
            DoubleCellValue(grade.score);
        detailSheet.cell(CellIndex.indexByString('E$row')).value =
            DoubleCellValue(grade.maxScore);
        detailSheet.cell(CellIndex.indexByString('F$row')).value =
            DoubleCellValue(grade.percentage);
        detailSheet.cell(CellIndex.indexByString('G$row')).value =
            TextCellValue(_getLetterGrade(grade.percentage));
        detailSheet.cell(CellIndex.indexByString('H$row')).value =
            TextCellValue(DateFormat('dd/MM/yyyy').format(grade.recordedAt));
        row++;
      }

      // Save Excel
      final output = await getTemporaryDirectory();
      final file = File(
        '${output.path}/laporan_nilai_${studentId}_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      );
      final bytes = excel.save();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        return file.path;
      }

      return null;
    } catch (e) {
      debugPrint('Error exporting to Excel: $e');
      return null;
    }
  }

  /// Share exported file
  Future<void> shareFile(String filePath, String fileName) async {
    try {
      await Share.shareXFiles([
        XFile(filePath),
      ], text: 'Laporan Nilai - $fileName');
    } catch (e) {
      debugPrint('Error sharing file: $e');
    }
  }

  // Helper methods for PDF
  pw.Widget _buildSummaryCard(String title, String value, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildGradeDistributionTable(Map<String, int> distribution) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Grade',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Jumlah',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                'Persentase',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            ),
          ],
        ),
        ...distribution.entries.map((entry) {
          final total = distribution.values.reduce((a, b) => a + b);
          final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
          return pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(entry.key),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(entry.value.toString()),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text('${percentage.toStringAsFixed(1)}%'),
              ),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildGradesTable(List<GradeModel> grades) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(
                'Item',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(
                'Nilai',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(
                '%',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(
                'Grade',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(
                'Tanggal',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        ...grades.map(
          (grade) => pw.TableRow(
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  grade.itemTitle ?? (grade.isQuizGrade ? 'Quiz' : 'Tugas'),
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  '${grade.score.toStringAsFixed(0)}/${grade.maxScore.toStringAsFixed(0)}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  '${grade.percentage.toStringAsFixed(1)}%',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  _getLetterGrade(grade.percentage),
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  DateFormat('dd/MM/yy').format(grade.recordedAt),
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  PdfColor _getGradeColor(double percentage) {
    if (percentage >= 80) return PdfColors.green;
    if (percentage >= 60) return PdfColors.orange;
    return PdfColors.red;
  }

  String _getLetterGrade(double percentage) {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'E';
  }
}
