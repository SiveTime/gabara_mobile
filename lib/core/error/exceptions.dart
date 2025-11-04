class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Terjadi kesalahan pada server']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Gagal memuat data dari cache']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Tidak ada koneksi internet']);
}
