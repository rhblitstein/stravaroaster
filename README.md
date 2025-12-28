# Get Roasted

A brutally honest Strava companion app that roasts your activities with AI-powered feedback.

## Overview

Get Roasted connects to your Strava account and analyzes your activities to deliver roasts ranging from gentle encouragement to absolutely savage criticism. Choose your roast severity, hit the button, and get the honest feedback your Strava friends are too polite to give you.

## Features

- **Strava Integration**: Secure OAuth login to access your activities
- **Activity Feed**: Browse recent workouts with stats, photos, and achievements
- **Detailed Stats**: Distance, pace, elevation, heart rate, segment efforts, and more
- **AI Roasts**: Four severity levels from mild to ghost pepper
- **Segment Analysis**: See your PRs, Local Legend status, and leaderboard rankings
- **Photo Support**: View activity photos in the detail view

## Installation

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Strava account

### Setup

1. Clone the repository:
```bash
git clone <repo-url>
cd StravaRoaster
```

2. Create a Strava API application at https://www.strava.com/settings/api

3. Copy the config template and add your credentials:
```bash
cp StravaRoaster/Config.swift.example StravaRoaster/Config.swift
```

Edit `Config.swift` with your Strava API credentials:
```swift
static let stravaClientID = "YOUR_CLIENT_ID"
static let stravaClientSecret = "YOUR_CLIENT_SECRET"
```

4. In your Strava API settings, set the Authorization Callback Domain to `activityroaster`

5. Open `StravaRoaster.xcodeproj` in Xcode and run

## Usage

1. Launch the app and tap "Connect with Strava"
2. Log in and authorize the app
3. Browse your activities
4. Tap an activity to see details
5. Select a roast severity level
6. Hit "GET ROASTED"

## Roast Severity Levels

- **Mild**: Gentle encouragement with light ribbing
- **Spicy**: Sarcastic friend taking the piss
- **Caliente**: Brutally honest and mean (but funny)
- **🌶️🌶️🌶️**: Absolutely savage, no survivors

## Project Structure
```
StravaRoaster/
├── Models/              # Data models for activities, photos, segments
├── Views/               # SwiftUI views
├── Services/            # API integrations (Strava, AI)
├── Config.swift         # API credentials (not committed)
└── Theme.swift          # App colors and styling
```

## Roadmap

### Near Term
- Real AI integration (currently using mock roasts)
- Spotify Wrapped-style swipeable slides for each roast
- Photo timeline analysis (roast users for stopping to take selfies)
- Gear mileage tracking with maintenance reminders

### Future Ideas
- Weekly/monthly/yearly roast recaps
- Per-sport severity settings (gentle on swims, brutal on runs)
- Training insights and coaching advice
- Social features (share roasts, compare with friends)
- Kudos and comment directly from the app
- Route map visualization
- Multi-photo carousel support

## Technical Notes

- Built with Swift and SwiftUI
- Uses async/await for API calls
- Mock roast service can be swapped for real AI with one line change
- OAuth tokens expire after 6 hours (refresh flow not yet implemented)

## Contributing

Pull requests welcome! This started as a fun side project and there's plenty of room for improvement.

## License

MIT
