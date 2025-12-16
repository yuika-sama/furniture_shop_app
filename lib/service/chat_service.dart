import 'package:google_generative_ai/google_generative_ai.dart';
import 'app_data.dart';
import '../constants/app_config.dart';

class ChatService {
  static const _apiKey = AppConfig.geminiApiKey;
  
  static const _modelName = 'gemini-2.5-flash';

  late final GenerativeModel _model;
  late ChatSession _chat;

  ChatService() {
    _model = GenerativeModel(
      model: _modelName,
      apiKey: _apiKey,
      systemInstruction: Content.system("""
        Bạn là trợ lý ảo thông minh của ứng dụng Homi Furniture - ứng dụng bán nội thất trực tuyến.
        
        NHIỆM VỤ:
        - Hỗ trợ người dùng về thông tin ứng dụng
        - Giải thích các tính năng, models, API
        - Hướng dẫn sử dụng ứng dụng
        - Trả lời câu hỏi về sản phẩm, đơn hàng, thanh toán
        
        QUY TẮC:
        1. Chỉ trả lời dựa trên thông tin trong KNOWLEDGE BASE được cung cấp
        2. Nếu thông tin không có trong KNOWLEDGE BASE, hãy trả lời: "Tôi không có thông tin về vấn đề này. Vui lòng liên hệ bộ phận hỗ trợ."
        3. Trả lời ngắn gọn, rõ ràng, dễ hiểu
        4. Sử dụng tiếng Việt
        5. Thân thiện và chuyên nghiệp
        6. Không bịa đặt thông tin
        
        --- KNOWLEDGE BASE ---
        $appKnowledgeBase
        
        --- HẾT KNOWLEDGE BASE ---
        
        Hãy bắt đầu hỗ trợ người dùng!
      """),
    );

    _chat = _model.startChat();
  }

  /// Gửi message đến AI và nhận response
  /// 
  /// [message]: Tin nhắn từ người dùng
  /// Returns: Response text từ AI, hoặc error message
  Future<String?> sendMessage(String message) async {
    try {
      final response = await _chat.sendMessage(Content.text(message));
      return response.text;
    } catch (e) {
      // Error handling
      if (e.toString().contains('API key')) {
        return "⚠️ Lỗi: API Key chưa được cấu hình. Vui lòng thêm Google API Key vào file chat_service.dart";
      }
      return "❌ Lỗi kết nối: $e";
    }
  }

  void clearHistory() {
    _chat = _model.startChat();
  }
}
