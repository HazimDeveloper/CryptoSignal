// chatbot_widget.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // For serialization to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // For deserialization from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class ChatbotScreen extends StatefulWidget {
  final String? initialQuestion;

  const ChatbotScreen({
    Key? key,
    this.initialQuestion,
  }) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isServerAvailable = false;
  
  // API configuration
  final String _serverUrl = 'http://10.0.2.2:5000/api'; // For Android emulator
  
  @override
  void initState() {
    super.initState();
    _checkServerStatus();
    _loadChatHistory();
     if (widget.initialQuestion != null) {
    // Wait for the build to complete before sending message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _textController.text = widget.initialQuestion!;
      _sendMessage();
    });
  }
  }
  
  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  // Save chat history to SharedPreferences
  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatHistory = _messages.map((m) => jsonEncode(m.toJson())).toList();
      await prefs.setStringList('chat_history', chatHistory);
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }
  
  // Load chat history from SharedPreferences
  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatHistory = prefs.getStringList('chat_history') ?? [];
      
      setState(() {
        _messages.clear();
        _messages.addAll(
          chatHistory
              .map((str) => ChatMessage.fromJson(jsonDecode(str)))
              .toList(),
        );
      });
    } catch (e) {
      print('Error loading chat history: $e');
    }
  }
  
  // Check if Ollama server is available
  Future<void> _checkServerStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$_serverUrl/chatbot/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isServerAvailable = data['server_status'] == 'running';
        });
        
        if (!_isServerAvailable) {
          setState(() {
            _errorMessage = 'Chatbot server is not running. Some features may be unavailable.';
          });
        } else if (_messages.isEmpty) {
          // Add initial welcome message if chat is empty
          _addMessage(
            'Hello! I\'m your trading assistant. I can help explain signals, market regimes, and performance metrics from your dashboard. What would you like to know?',
            false,
          );
        }
      } else {
        setState(() {
          _isServerAvailable = false;
          _errorMessage = 'Could not connect to chatbot server.';
        });
      }
    } catch (e) {
      setState(() {
        _isServerAvailable = false;
        _errorMessage = 'Error connecting to chatbot server: $e';
      });
    }
  }
  
  // Add a message to the chat
  void _addMessage(String text, bool isUser) {
    setState(() {
      _messages.add(ChatMessage(text: text, isUser: isUser));
    });
    
    // Save after adding message
    _saveChatHistory();
    
    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  // Send message to Ollama API
  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    
    // Clear text field
    _textController.clear();
    
    // Add user message to chat
    _addMessage(text, true);
    
    // Show loading indicator
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    if (!_isServerAvailable) {
      // Handle offline mode with pre-defined responses
      _handleOfflineResponse(text);
      return;
    }
    
    try {
      // Convert chat history to format expected by API
      final history = _convertChatHistoryToApiFormat();
      
      // Send request to API
      final response = await http.post(
        Uri.parse('$_serverUrl/chatbot/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': text,
          'history': history,
        }),
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success']) {
          // Add bot response to chat
          _addMessage(data['message'], false);
        } else {
          setState(() {
            _errorMessage = data['error'] ?? 'Unknown error occurred';
          });
          // Add fallback response
          _addMessage(
            'Sorry, I encountered an error. Please try again later or check with support.',
            false,
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
        });
        // Add fallback response
        _addMessage(
          'Sorry, I encountered a server error. Please try again later.',
          false,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
      // Add fallback response
      _addMessage(
        'Sorry, I couldn\'t process your request. Please try again later.',
        false,
      );
    }
  }
  
  // Handle offline mode with pre-defined responses
  void _handleOfflineResponse(String text) {
    // Wait a moment to simulate processing
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _isLoading = false;
      });
      
      final lowerText = text.toLowerCase();
      String response;
      
      // Basic keyword matching for offline mode
      if (lowerText.contains('buy') && lowerText.contains('signal')) {
        response = 'A BUY signal suggests the model predicts an upward price movement. The confidence level indicates how strong this prediction is. Always consider other factors before making investment decisions.';
      } else if (lowerText.contains('sell') && lowerText.contains('signal')) {
        response = 'A SELL signal indicates the model anticipates a downward price movement. Higher confidence means stronger conviction in this prediction. Remember that all trading involves risk.';
      } else if (lowerText.contains('sharpe')) {
        response = 'The Sharpe Ratio measures risk-adjusted returns. Values above 1.8 (like in your dashboard) indicate good risk-adjusted performance. Higher values mean better risk-adjusted returns.';
      } else if (lowerText.contains('drawdown')) {
        response = 'Maximum Drawdown measures the largest peak-to-trough decline. Your dashboard shows 25.8%, which is the largest percentage drop from a peak. Lower values are better.';
      } else if (lowerText.contains('regime') || lowerText.contains('bullish') || lowerText.contains('bearish')) {
        response = 'Market regimes classify market conditions as Neutral, Bullish (uptrend), or Bearish (downtrend). The model adjusts signal confidence based on the detected regime.';
      } else if (lowerText.contains('hello') || lowerText.contains('hi ')) {
        response = 'Hello! I\'m your trading assistant (currently in offline mode). I can help explain trading concepts and dashboard metrics.';
      } else {
        response = 'I\'m currently in offline mode and have limited responses. Please check if the Ollama server is running for full functionality. I can still help with basic questions about buy/sell signals, market regimes, and performance metrics.';
      }
      
      _addMessage(response, false);
    });
  }
  
  // Convert chat history to format expected by Ollama API
  List<Map<String, String>> _convertChatHistoryToApiFormat() {
    final apiHistory = <Map<String, String>>[];
    
    // Add system message if it's the first message
    if (_messages.isEmpty) {
      apiHistory.add({
        'role': 'system',
        'content': 'You are a helpful trading assistant for a cryptocurrency trading dashboard.',
      });
    }
    
    // Convert chat messages to API format
    for (final message in _messages) {
      apiHistory.add({
        'role': message.isUser ? 'user' : 'assistant',
        'content': message.text,
      });
    }
    
    return apiHistory;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trading Assistant'),
        centerTitle: false,
        actions: [
          // Server status indicator
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Tooltip(
              message: _isServerAvailable 
                  ? 'Chatbot server is online' 
                  : 'Chatbot server is offline',
              child: Icon(
                _isServerAvailable ? Icons.cloud_done : Icons.cloud_off,
                color: _isServerAvailable ? Colors.green : Colors.red,
              ),
            ),
          ),
          // Clear chat button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear chat history',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Chat History'),
                  content: const Text('Are you sure you want to clear the chat history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _messages.clear();
                          _saveChatHistory();
                        });
                        Navigator.pop(context);
                        // Add welcome message back
                        _addMessage(
                          'Hello! I\'m your trading assistant. How can I help you today?',
                          false,
                        );
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Error message
          if (_errorMessage.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.red.withOpacity(0.1),
              width: double.infinity,
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: () {
                      setState(() {
                        _errorMessage = '';
                      });
                    },
                  ),
                ],
              ),
            ),
          
          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),
          
          // Loading indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Assistant is thinking...',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          
          // Suggestion chips
          if (!_isLoading && _messages.length < 3)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildSuggestionChip('What is a BUY signal?'),
                  _buildSuggestionChip('Explain Sharpe Ratio'),
                  _buildSuggestionChip('What are market regimes?'),
                  _buildSuggestionChip('How to interpret confidence?'),
                ],
              ),
            ),
          
          // Input field
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              border: Border(
                top: BorderSide(
                  color: Colors.grey[800]!,
                  width: 0.5,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                // Message input
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                
                // Send button
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Build message bubble
  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bot avatar (only for bot messages)
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.blue[700],
              radius: 16,
              child: const Icon(
                Icons.smart_toy,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Colors.blue[700]
                    : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : null,
                ),
              ),
            ),
          ),
          
          // User avatar (only for user messages)
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue[900],
              radius: 16,
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  // Build suggestion chip
  Widget _buildSuggestionChip(String text) {
    return ActionChip(
      label: Text(
        text,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: Colors.blue.withOpacity(0.1),
      onPressed: () {
        _textController.text = text;
        _sendMessage();
      },
    );
  }
}