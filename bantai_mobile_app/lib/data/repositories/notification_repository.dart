import '../../core/api_client.dart';
import '../models/models.dart';

class NotificationRepository {
  Future<List<AppNotification>> list() async {
    final res = await ApiClient.instance.get('/notifications');
    return (res['notifications'] as List).map((e) => AppNotification.fromJson(e)).toList();
  }

  Future<void> markRead(String id) => ApiClient.instance.patch('/notifications/$id/read');

  Future<void> markAllRead() => ApiClient.instance.patch('/notifications/read-all');
}
