## Leaderboard Performance Optimization

### Problem
The leaderboard was taking 10-12 seconds to load because it calculated all stats in real-time when opening the screen, resulting in thousands of Firestore queries.

### Solution
Created a `leaderboard_stats` collection that stores pre-computed statistics:
- `userId`: User ID
- `totalStreak`: Sum of all habit streaks
- `totalHabits`: Number of habits
- `completedToday`: Habits completed today
- `lastUpdated`: Timestamp

### Implementation

#### 1. LeaderboardUpdateService
Location: `lib/core/services/leaderboard_update_service.dart`

Automatically updates user stats when they complete/uncomplete habits.

#### 2. Updated Leaderboard Data Source
Location: `lib/features/leaderboard/data/datasources/leaderboard_remote_data_source.dart`

Now queries the `leaderboard_stats` collection instead of calculating everything on-the-fly.

#### 3. Integration
Stats are updated in `HabitBloc` after every habit completion/uncompletion.

### Setup Instructions

#### One-Time Setup: Initialize Stats for Existing Users

Run this from Flutter DevTools console or create a temporary admin function:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_app/core/services/leaderboard_update_service.dart';

Future<void> initializeLeaderboardStats() async {
  final service = LeaderboardUpdateService();
  await service.updateAllUsersStats();
  print('Leaderboard stats initialized for all users!');
}
```

Or use Firebase Functions to run it server-side.

#### Firestore Index Required

Create a composite index on `leaderboard_stats` collection:
- Collection: `leaderboard_stats`
- Fields: `totalStreak` (Descending)

Firebase will prompt you to create this index when you first query the leaderboard.

### Performance Improvement

**Before:**
- 100 users × 5 habits × 90 days = ~45,000 queries
- Load time: 10-12 seconds

**After:**
- 1 query to `leaderboard_stats` + 100 queries for user profiles
- Load time: <1 second

### Maintenance

Stats are automatically updated whenever users:
- Complete a habit
- Uncomplete a habit
- Create a new habit (handled by the service)
- Delete a habit (handled by the service)

No manual maintenance required!
