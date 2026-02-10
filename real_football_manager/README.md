# Real Football Manager

A modern football management simulation game built with Flutter, featuring AI-powered player interactions and dynamic gameplay.

## 🎮 Features

### Core Gameplay
- **Team Selection**: Choose from Turkish Super Lig clubs with unique characteristics
- **Squad Management**: View detailed player profiles and statistics
- **AI Chat System**: Interact with players using advanced AI responses
- **Daily Simulation**: Progress through days with dynamic events
- **News Feed**: AI-generated football news and rumors
- **Email System**: Receive important notifications and decisions

### AI Integration
- **Groq API Powered**: Uses Llama 3.3 model for realistic responses
- **Player Personality**: Each player has unique traits affecting conversations
- **Dynamic Events**: AI generates realistic scenarios and news
- **Context-Aware**: Responses consider player mood, ego, and situation

### User Interface
- **Modern Dark Theme**: Professional football manager aesthetic
- **Responsive Design**: Optimized for mobile and desktop
- **Smooth Animations**: Fluid transitions and micro-interactions
- **Data Visualization**: Progress bars, stats, and performance indicators

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.9.2)
- Groq API key (free at [console.groq.com](https://console.groq.com/))

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd real_football_manager
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up API key**
   ```bash
   cp .env.example .env
   # Edit .env and add your Groq API key:
   GROQ_API_KEY=gsk_your_actual_api_key_here
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 📱 Screens & Navigation

### Main Screens
- **Team Selection**: Choose your club to manage
- **Dashboard**: Main hub with daily simulation and overview
- **Squad**: View and interact with your players
- **Player Detail**: Comprehensive player profiles with chat
- **News**: AI-generated football media content
- **Tactics**: Team formation and strategy (coming soon)
- **Fixtures**: Match schedule and results (coming soon)

### Navigation Flow
```
Team Selection → Dashboard → [Squad, News, Tactics, Fixtures]
                    ↓
              Player Detail → Chat Screen
```

## 🤖 AI Features

### Player Chat System
- **Personality-Based**: Responses vary by player ego, mood, and traits
- **Realistic Dialogue**: Players respond like real footballers
- **Context Sensitive**: Considers recent events and player status
- **Turkish Language**: All AI responses in Turkish for authenticity

### Dynamic Events
- **Daily Scenarios**: Training sessions, media incidents, injuries
- **Probability-Based**: Random events with weighted chances
- **Statistical Impact**: Events affect team morale and energy
- **AI Generated**: Content created dynamically using AI

### News Generation
- **Realistic Headlines**: Turkish sports media style
- **Multiple Categories**: Transfers, matches, crises, interviews
- **Team-Specific**: Focuses on your club and league
- **Timely Updates**: Fresh content with each simulation

## 🏗️ Architecture

### Project Structure
```
lib/
├── models/          # Data models (Player, Club, GameState)
├── services/        # Business logic (AI, Data, Simulation)
├── screens/          # UI screens
└── main.dart         # App entry point
```

### Key Components
- **AIService**: Handles all AI interactions with Groq API
- **SimulationService**: Manages daily game logic and events
- **DataService**: Manages local data and state
- **GameState**: Central state management for the game

### Data Models
- **Player**: Skills, traits, personality, contract info
- **Club**: Finances, culture, squad, reputation
- **GameState**: Current date, news, emails, statistics

## 🎯 Game Mechanics

### Player Attributes
- **Technical Skills**: Speed, shooting, passing, dribbling, defense, physical
- **Mental Attributes**: Ego, ambition, discipline, loyalty, leadership
- **Status**: Happy, Angry, Unrest, Injured
- **Traits**: Captain, Star, Leader, etc.

### Team Dynamics
- **Morale System**: Affected by results, events, and management
- **Energy Levels**: Player fitness and condition
- **Club Culture**: Chaos factor, fan pressure, identity
- **Financial Management**: Transfer budgets and contracts

### Simulation Logic
- **Daily Progress**: Advance time with event generation
- **Probability Events**: Weighted random occurrences
- **AI Integration**: Dynamic content generation
- **State Management**: Persistent game state updates

## 🔧 Configuration

### Environment Variables
Create a `.env` file in the project root:
```
GROQ_API_KEY=your_groq_api_key_here
```

### API Configuration
- **Base URL**: `https://api.groq.com/openai/v1/chat/completions`
- **Model**: `llama-3.3-70b-versatile`
- **Temperature**: 0.7 (balanced creativity)
- **Max Tokens**: 1024

## 📊 Dependencies

### Core Dependencies
- `flutter`: UI framework
- `sqflite`: Local database
- `path_provider`: File system access
- `flutter_dotenv`: Environment variables
- `http`: API requests

### Development Dependencies
- `flutter_test`: Testing framework
- `flutter_lints`: Code quality

## 🎨 UI/UX Design

### Theme
- **Dark Mode**: Professional football manager aesthetic
- **Color Palette**: 
  - Primary: `#0A0E12` (dark background)
  - Secondary: `#161B22` (cards and surfaces)
  - Accent: `#DC2626` (actions and highlights)
- **Typography**: Clean, modern sans-serif fonts

### Design Patterns
- **Material Design 3**: Modern UI components
- **Responsive Layout**: Adapts to screen sizes
- **Micro-interactions**: Subtle animations and feedback
- **Information Hierarchy**: Clear visual structure

## 🚧 Development

### Building for Production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Testing
```bash
# Run tests
flutter test

# Generate test coverage
flutter test --coverage
```

### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
dart format .
```

## 🔮 Future Features

### Planned Enhancements
- **Match Simulation**: Live match engine with tactics
- **Transfer Market**: Buy and sell players
- **League Competition**: Full season simulation
- **Press Conferences**: Media interactions
- **Youth Academy**: Develop young players
- **Financial Management**: Detailed budget system
- **Multiplayer**: Online leagues and competitions

### Technical Improvements
- **State Management**: BLoC or Riverpod integration
- **Offline Mode**: Reduced API dependency
- **Performance**: Optimizations and caching
- **Localization**: Multiple language support

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open Pull Request

### Code Standards
- Follow Dart style guide
- Write tests for new features
- Update documentation
- Use meaningful commit messages

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

### Getting Help
- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Feature requests and questions
- **Documentation**: Check this README and inline comments

### Common Issues
- **API Errors**: Verify Groq API key in `.env`
- **Build Issues**: Run `flutter clean && flutter pub get`
- **Performance**: Check device specifications

## 🏆 Acknowledgments

- **Groq**: For providing the AI API
- **Flutter Team**: For the excellent framework
- **Turkish Football Community**: For inspiration and feedback

---

**Built with ❤️ for football management enthusiasts**

*Real Football Manager - Where strategy meets AI-powered storytelling*
