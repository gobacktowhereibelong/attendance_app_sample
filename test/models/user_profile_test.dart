import 'package:flutter_test/flutter_test.dart';
import 'package:attendance_app/models/user_profile.dart';

void main() {
  group('UserProfile Model Tests', () {
    final sampleProfile = UserProfile(
      id: 'usr_789',
      email: 'user@example.com',
      fullName: 'Budi Santoso',
      createdAt: DateTime.parse('2026-01-01T10:00:00.000'),
      role: 'Pengguna',
    );

    test('Serialisasi dan deserialisasi UserProfile', () {
      final json = sampleProfile.toJson();
      expect(json['id'], 'usr_789');
      expect(json['email'], 'user@example.com');
      expect(json['full_name'], 'Budi Santoso');
      expect(json['created_at'], '2026-01-01T10:00:00.000');
      expect(json['role'], 'Pengguna');

      final fromJson = UserProfile.fromJson(json);
      expect(fromJson.id, sampleProfile.id);
      expect(fromJson.email, sampleProfile.email);
      expect(fromJson.fullName, sampleProfile.fullName);
      expect(fromJson.createdAt, sampleProfile.createdAt);
      expect(fromJson.role, sampleProfile.role);
    });

    test('Default role adalah Pengguna jika tidak diberikan di JSON', () {
      final json = {
        'id': 'usr_001',
        'email': 'test@example.com',
        'full_name': 'Test User',
        'created_at': '2026-01-01T10:00:00.000',
      };
      final profile = UserProfile.fromJson(json);
      expect(profile.role, 'Pengguna');
    });
  });
}
