import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/class_model.dart';

class ClassService {
  final SupabaseClient supabaseClient;

  ClassService(this.supabaseClient);

  // 1. GET ALL CLASSES (Dengan Filter Role otomatis via RLS Database)
  Future<List<ClassModel>> getClasses() async {
    try {
      // Kita select semua kolom (*), plus data dari tabel relasi 'subjects' dan 'profiles'
      final response = await supabaseClient
          .from('classes')
          .select('*, subjects(name), tutor:profiles(full_name)')
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      return data.map((json) => ClassModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data kelas: $e');
    }
  }

  // 2. CREATE CLASS (Khusus Mentor)
  Future<void> createClass({
    required String name,
    required String description,
    required int subjectId, // ID Mapel (Integer)
    required int maxStudents,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw Exception('User tidak login');

      await supabaseClient.from('classes').insert({
        'name': name,
        'description': description,
        'subject_id': subjectId,
        'tutor_id': user.id, // Otomatis set diri sendiri sebagai tutor
        'max_students': maxStudents,
        'is_active': true,
      });
    } catch (e) {
      throw Exception('Gagal membuat kelas: $e');
    }
  }
  
  // 3. GET SUBJECTS (Untuk Dropdown di Form Buat Kelas)
  Future<List<Map<String, dynamic>>> getSubjects() async {
    try {
      final response = await supabaseClient
          .from('subjects')
          .select('id, name')
          .order('name', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return []; // Return list kosong jika gagal
    }
  }
}