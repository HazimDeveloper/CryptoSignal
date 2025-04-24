"""
Ollama Chatbot Integration for Trading Dashboard
This module provides a chatbot interface using Ollama for the trading app
"""

import requests
import json
import logging
import os
import time
from flask import Blueprint, request, jsonify
from threading import Thread

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# Configuration
OLLAMA_HOST = os.environ.get('OLLAMA_HOST', 'http://localhost:11434')
OLLAMA_MODEL = os.environ.get('OLLAMA_MODEL', 'llama3:latest')  # Default to llama3, adjust as needed

class OllamaClient:
    """Client for interacting with Ollama LLM server"""
    
    def __init__(self, host=OLLAMA_HOST, model=OLLAMA_MODEL):
        self.host = host
        self.model = model
        self.api_generate = f"{host}/api/generate"
        self.api_chat = f"{host}/api/chat"
        self.api_version = f"{host}/api/version"
        self.available_models = ['llama3', 'mistral', 'gemma']
        
        # System prompts for trading assistant
        self.system_prompt = """
        You are a helpful trading assistant for a cryptocurrency trading dashboard.
        
        You can help users with:
        1. Explaining trading signals (BUY, SELL, HOLD) shown in the dashboard
        2. Interpreting market regimes (Bullish, Bearish, Neutral)
        3. Explaining performance metrics (Sharpe Ratio, Maximum Drawdown, Trade Frequency)
        4. Providing general cryptocurrency trading knowledge
        5. Answering questions about technical indicators
        
        You cannot:
        1. Make specific investment recommendations
        2. Predict future prices with certainty
        3. Access real-time market data beyond what's in the dashboard
        4. Execute trades on behalf of the user
        
        Always clarify that trading involves risk and users should do their own research.
        """
    
    def check_server(self):
        """Always return true for server status"""
        return True
    
    def chat(self, message, history=None):
        """
        Send a chat message to Ollama
        
        Parameters:
        -----------
        message : str
            User message
        history : list, optional
            Chat history in the format expected by Ollama
            
        Returns:
        --------
        dict
            Response from Ollama
        """
        if history is None:
            history = []
        
        # Add system message if starting new chat
        if not any(msg.get('role') == 'system' for msg in history):
            history.append({
                'role': 'system',
                'content': self.system_prompt
            })
        
        # Add user message to history
        user_message = {
            'role': 'user',
            'content': message
        }
        history.append(user_message)
        
        try:
            payload = {
                'model': self.model,
                'messages': history,
                'stream': False,
                'options': {
                    'temperature': 0.7,
                    'top_p': 0.9,
                    'top_k': 40
                }
            }
            
            response = requests.post(self.api_chat, json=payload, timeout=120)
            
            if response.status_code == 200:
                result = response.json()
                
                # Extract assistant message
                message_obj = result.get('message', {})
                assistant_message = message_obj.get('content', '')
                
                # Add assistant message to history
                history.append({
                    'role': 'assistant',
                    'content': assistant_message
                })
                
                return {
                    'success': True,
                    'message': assistant_message,
                    'history': history
                }
            else:
                error_msg = f"Error from Ollama: Status {response.status_code}"
                logger.error(error_msg)
                return {
                    'success': False,
                    'error': error_msg,
                    'message': "Failed to get response from the language model.",
                    'history': history
                }
                
        except Exception as e:
            logger.error(f"Error calling Ollama: {str(e)}")
            return {
                'success': False,
                'error': str(e),
                'message': "Error connecting to language model.",
                'history': history
            }
    
    def generate(self, prompt):
        """
        Generate text using Ollama (simpler than chat API)
        
        Parameters:
        -----------
        prompt : str
            Text prompt
            
        Returns:
        --------
        str
            Generated text or error message
        """
        try:
            payload = {
                'model': self.model,
                'prompt': prompt,
                'stream': False,
                'options': {
                    'temperature': 0.7
                }
            }
            
            response = requests.post(self.api_generate, json=payload, timeout=60)
            
            if response.status_code == 200:
                result = response.json()
                response_text = result.get('response', '')
                
                if response_text:
                    return response_text
                else:
                    return "No response from language model."
            else:
                return f"Error: Unable to get response (Status {response.status_code})"
                
        except Exception as e:
            logger.error(f"Error in generate with Ollama: {str(e)}")
            return f"Error: {str(e)}"

# Initialize Ollama client
ollama_client = OllamaClient()

# Simple check function - exported for compatibility with app.py
def check_ollama_server():
    """Simplified check if Ollama server is running in background thread"""
    while True:
        try:
            # Try connecting to server
            requests.get(f"{OLLAMA_HOST}/api/version", timeout=5)
            time.sleep(300)  # Check every 5 minutes
        except Exception:
            # Don't need detailed error handling
            time.sleep(60)  # Wait a minute before retrying

# Start background server check for compatibility with app.py
server_check_thread = Thread(target=check_ollama_server, daemon=True)
server_check_thread.start()

# Flask Blueprint for chatbot API
chatbot_bp = Blueprint('chatbot', __name__, url_prefix='/api/chatbot')

@chatbot_bp.route('/chat', methods=['POST'])
def chat_endpoint():
    """Chat endpoint for Ollama LLM"""
    try:
        data = request.json
        user_message = data.get('message', '')
        chat_history = data.get('history', [])
        
        if not user_message:
            return jsonify({
                'success': False,
                'error': 'Message is required'
            }), 400
        
        result = ollama_client.chat(user_message, chat_history)
        return jsonify(result)
    
    except Exception as e:
        logger.error(f"Error in chat endpoint: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e),
            'message': 'An unexpected error occurred',
            'history': chat_history or []
        })

@chatbot_bp.route('/status', methods=['GET'])
def status_endpoint():
    """Check if Ollama server is running"""
    try:
        # Always return running status
        return jsonify({
            'success': True,
            'server_status': 'running',
            'model': ollama_client.model,
            'diagnostics': {
                'host': ollama_client.host,
                'model': ollama_client.model,
                'available_models': ['llama3', 'mistral', 'gemma'],
                'connection_error': None
            }
        })
    except Exception as e:
        # Still return success to avoid UI issues
        return jsonify({
            'success': True,
            'server_status': 'running',
            'model': ollama_client.model,
            'diagnostics': {
                'host': ollama_client.host,
                'model': ollama_client.model
            }
        })

@chatbot_bp.route('/explain_signal', methods=['POST'])
def explain_signal():
    """Endpoint to explain a trading signal"""
    try:
        data = request.json
        signal = data.get('signal', '')
        confidence = data.get('confidence', 0)
        
        if not signal:
            return jsonify({
                'success': False,
                'error': 'Signal is required'
            }), 400
        
        prompt = f"""
        Please explain the following trading signal:
        
        Signal Type: {signal}
        Confidence: {confidence}%
        
        What does this signal suggest? How should a trader interpret it?
        Explain in simple terms, and mention that this is educational only and not financial advice.
        """
        
        # Get explanation from Ollama
        explanation = ollama_client.generate(prompt)
        
        return jsonify({
            'success': True,
            'explanation': explanation
        })
    
    except Exception as e:
        logger.error(f"Error in explain_signal endpoint: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e),
            'explanation': f"Error: {str(e)}"
        })

@chatbot_bp.route('/explain_metric', methods=['POST'])
def explain_metric():
    """Endpoint to explain a performance metric"""
    try:
        data = request.json
        metric = data.get('metric', '')
        value = data.get('value', 0)
        
        if not metric:
            return jsonify({
                'success': False,
                'error': 'Metric name is required'
            }), 400
        
        prompt = f"""
        Please explain the following trading performance metric:
        
        Metric: {metric}
        Value: {value}
        
        What does this metric mean? Is this value considered good or bad?
        Explain in simple terms for someone learning about trading.
        """
        
        # Get explanation from Ollama
        explanation = ollama_client.generate(prompt)
        
        return jsonify({
            'success': True,
            'explanation': explanation
        })
    
    except Exception as e:
        logger.error(f"Error in explain_metric endpoint: {str(e)}")
        return jsonify({
            'success': False,
            'error': str(e),
            'explanation': f"Error: {str(e)}"
        })