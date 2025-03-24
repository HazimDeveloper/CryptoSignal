# CryptoSignal: AI-Powered Trading Signals

CryptoSignal is an advanced cryptocurrency trading signal platform that leverages artificial intelligence to help traders make more informed decisions. The system combines CNN+LSTM neural networks with Hidden Markov Model regime detection to analyze market data and generate reliable trading signals with performance metrics.

![CryptoSignal Dashboard](https://ibb.co/G46tF4bg)

## Features

- **AI-Powered Signal Generation**: Neural network architecture combining CNN for pattern extraction with LSTM for time-series memory
- **Market Regime Detection**: HMM identifies bullish, bearish, and neutral market conditions
- **Performance Metrics**: Tracks Sharpe Ratio, Maximum Drawdown, and Trading Frequency
- **Adaptive Learning**: Self-updating model that improves with new market data
- **Mobile-First Design**: Flutter application providing access to signals anywhere

## Technology Stack

### Backend
- Python Flask API
- TensorFlow/Keras for machine learning
- Hidden Markov Models for regime detection
- RESTful endpoints for data and signals

### Frontend
- Flutter mobile application
- Interactive charts with signal overlays
- Real-time performance metrics
- Push notifications for new signals

## Success Criteria

The system is designed to meet these performance targets:
- **Sharpe Ratio** ≥ 1.8
- **Maximum Drawdown** ≤ 40%
- **Trading Frequency** ≥ 3%

## Screenshots

### Dashboard
![Dashboard](https://ibb.co/G46tF4bg)
Real-time performance metrics with signal distribution and recent trading alerts.

### Charts
![Charts](https://ibb.co/LDXFcZWG)
Interactive price charts with buy/sell signals clearly marked.

### Signals
![Signals](https://ibb.co/Wpkkqbj6)
Complete history of trading signals with confidence levels and expected returns.


## Installation

### Backend Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/cryptosignal.git
cd cryptosignal/backend

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the Flask server
python app.py
```

### Frontend Setup

```bash
# Navigate to the frontend directory
cd ../frontend

# Install dependencies
flutter pub get

# Run the app in development mode
flutter run
```

## Configuration

The application can be configured through:
- Server URL in settings
- Performance criteria thresholds
- Notification preferences

## Usage

1. Launch the application
2. View current signals on the dashboard
3. Analyze price charts with signal overlays
4. Track performance metrics
5. Receive notifications for new signals

## Roadmap

- **Phase 1** (Current): Single cryptocurrency, basic signals
- **Phase 2**: Multiple cryptocurrencies, enhanced UI
- **Phase 3**: Portfolio management, risk settings
- **Phase 4**: Social trading features, signal marketplace
- **Phase 5**: Integration with exchanges for automated trading

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- TensorFlow team for their excellent machine learning framework
- Flutter team for the mobile app framework
- CoinGecko for cryptocurrency data API