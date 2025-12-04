import 'package:flutter/material.dart';

/// Widget untuk menampilkan text dengan @mention yang di-highlight
/// Mendukung nama lengkap dengan spasi seperti "@Tsaqif Hisyam Saputra"
class MentionText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  /// Nama lengkap yang di-mention (untuk highlight nama dengan spasi)
  final String? mentionedName;

  const MentionText({
    super.key,
    required this.text,
    this.style,
    this.maxLines,
    this.overflow,
    this.mentionedName,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle =
        style ?? const TextStyle(fontSize: 14, color: Colors.black87);

    final spans = _parseText(text, defaultStyle);

    return RichText(
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
      text: TextSpan(children: spans),
    );
  }

  List<TextSpan> _parseText(String text, TextStyle defaultStyle) {
    final List<TextSpan> spans = [];
    final mentionStyle = defaultStyle.copyWith(
      color: Colors.blue.shade700,
      fontWeight: FontWeight.w600,
    );

    // Jika ada mentionedName, gunakan itu untuk highlight
    if (mentionedName != null && mentionedName!.isNotEmpty) {
      final fullMention = '@$mentionedName';

      // Cek apakah text mengandung @NamaLengkap
      final mentionIndex = text.indexOf(fullMention);

      if (mentionIndex != -1) {
        // Text sebelum mention
        if (mentionIndex > 0) {
          spans.add(
            TextSpan(
              text: text.substring(0, mentionIndex),
              style: defaultStyle,
            ),
          );
        }

        // Highlight @NamaLengkap (seluruh nama)
        spans.add(TextSpan(text: fullMention, style: mentionStyle));

        // Text setelah mention
        final afterMention = mentionIndex + fullMention.length;
        if (afterMention < text.length) {
          spans.add(
            TextSpan(text: text.substring(afterMention), style: defaultStyle),
          );
        }

        return spans;
      }
    }

    // Fallback: cari @mention di awal text dan highlight sampai spasi pertama setelah nama
    // Atau gunakan regex untuk nama dengan spasi
    return _parseWithSmartDetection(text, defaultStyle, mentionStyle);
  }

  /// Parse dengan deteksi cerdas untuk nama dengan spasi
  List<TextSpan> _parseWithSmartDetection(
    String text,
    TextStyle defaultStyle,
    TextStyle mentionStyle,
  ) {
    final List<TextSpan> spans = [];

    // Cek apakah text dimulai dengan @
    if (!text.startsWith('@')) {
      return [TextSpan(text: text, style: defaultStyle)];
    }

    // Cari posisi di mana mention berakhir
    // Heuristik: nama berakhir ketika menemukan kata yang dimulai huruf kecil
    // atau setelah maksimal 5 kata (untuk nama panjang)

    int mentionEnd = 1; // Mulai setelah @
    final textAfterAt = text.substring(1);
    final words = textAfterAt.split(' ');
    int wordCount = 0;
    int currentPos = 1;

    for (final word in words) {
      if (word.isEmpty) {
        currentPos++;
        continue;
      }

      // Kata pertama selalu bagian dari nama
      if (wordCount == 0) {
        mentionEnd = currentPos + word.length;
        wordCount++;
        currentPos += word.length + 1;
        continue;
      }

      // Cek apakah kata ini bagian dari nama:
      // - Huruf pertama kapital (A-Z)
      // - Bukan kata umum seperti "gurt", "bro", dll
      final firstChar = word[0];
      final isCapitalized =
          firstChar.toUpperCase() == firstChar &&
          firstChar.toLowerCase() != firstChar;

      // Jika huruf pertama kapital dan belum lebih dari 5 kata, masih bagian nama
      if (isCapitalized && wordCount < 5) {
        mentionEnd = currentPos + word.length;
        wordCount++;
        currentPos += word.length + 1;
      } else {
        // Kata ini bukan bagian dari nama, berhenti
        break;
      }
    }

    // Highlight mention
    final mentionText = text.substring(0, mentionEnd);
    spans.add(TextSpan(text: mentionText, style: mentionStyle));

    // Sisa text (termasuk spasi sebelum kata berikutnya)
    if (mentionEnd < text.length) {
      spans.add(
        TextSpan(text: text.substring(mentionEnd), style: defaultStyle),
      );
    }

    return spans;
  }
}
