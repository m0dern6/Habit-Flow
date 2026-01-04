# Habit Reminder Notification System

## Overview
The HabitFlow app now includes a comprehensive notification system that helps users stay on track with their habits through timely reminders.

## Features Implemented

### 1. **Multiple Reminder Types**
Each habit can have up to **6 automated notifications** per scheduled day:
- **2 hours before** reminder time
- **1 hour before** reminder time  
- **30 minutes before** reminder time
- **10 minutes before** reminder time
- **At reminder time** (exact time)
- **1 hour after** (missed notification)

### 2. **Custom Scheduling**
- Users can select **which days of the week** to receive reminders (Monday-Sunday)
- Users can set a **specific time** for the habit reminder
- Notifications automatically repeat weekly for selected days

### 3. **Notification Types**

#### Habit Reminders
Standard reminders based on user-selected time and days.

#### Missed Notifications  
If a habit isn't completed 1 hour after the reminder time, users receive a "missed" notification.

#### Streak Warnings (Available via NotificationService)
- Can show warnings when a streak is at risk
- Notifies users before end of day if habit incomplete

#### Streak Lost Notifications (Available via NotificationService)
- Alerts users when a streak has been reset
- Helps maintain awareness of habit completion importance

## How It Works

### For Users

1. **Creating a Habit with Reminders:**
   - Open "Add New Habit"
   - Fill in habit details (name, category, icon, color)
   - Scroll to "Reminder Settings"
   - Select days of the week (Mon, Tue, Wed, etc.)
   - Tap "Set time" to choose reminder time
   - Save the habit

2. **Notification Behavior:**
   - On selected days, you'll receive reminders at configured intervals
   - Tap a notification to open the app
   - Complete your habit to stop further reminders for that day

3. **Updating/Deleting Habits:**
   - Editing a habit automatically updates all scheduled notifications
   - Deleting a habit cancels all associated notifications

### For Developers

#### Architecture

**NotificationService** (`lib/core/services/notification_service.dart`)
- Singleton service managing all notification operations
- Uses `flutter_local_notifications` package
- Handles timezone-aware scheduling with `timezone` package

**Integration Points:**
- `main.dart`: Initializes service and requests permissions on app start
- `habit_bloc.dart`: Schedules/updates/cancels notifications when habits change
- `injection_container.dart`: Registers service in dependency injection

#### Key Methods

```dart
// Schedule all reminders for a habit
await notificationService.scheduleHabitReminders(
  habitId: habit.id,
  habitTitle: habit.title,
  reminderTime: habit.reminderTime!,
  weekdays: [1, 2, 3, 4, 5], // Mon-Fri
);

// Cancel all notifications for a habit
await notificationService.cancelHabitReminders(habitId);

// Show instant streak warning
await notificationService.showStreakWarning(
  habitTitle: 'Morning Exercise',
  currentStreak: 15,
);

// Show streak lost notification
await notificationService.showStreakLost(
  habitTitle: 'Morning Exercise',
  lostStreak: 15,
);

// Show habit completion failed
await notificationService.showHabitCompletionFailed(
  habitTitle: 'Morning Exercise',
);
```

#### Notification ID Strategy

Each habit can have up to 42 scheduled notifications (7 days × 6 notification types).

**ID Calculation:**
```dart
final baseId = habitId.hashCode;
final notificationId = baseId + (weekday * 10) + notificationType;

// Where:
// - weekday: 1-7 (Monday-Sunday)
// - notificationType: 1-6 (2hr, 1hr, 30min, 10min, exact, missed)
```

#### Android Configuration

**Permissions** (`android/app/src/main/AndroidManifest.xml`):
- `POST_NOTIFICATIONS` - Show notifications (Android 13+)
- `SCHEDULE_EXACT_ALARM` - Exact time scheduling
- `USE_EXACT_ALARM` - Alternative exact alarm permission
- `RECEIVE_BOOT_COMPLETED` - Reschedule after device restart
- `VIBRATE` - Vibration on notification

**Broadcast Receivers:**
- `ScheduledNotificationBootReceiver` - Handles boot events
- `ScheduledNotificationReceiver` - Handles scheduled notifications

#### Dependencies

```yaml
flutter_local_notifications: ^18.0.1  # Core notification functionality
timezone: ^0.9.4                      # Timezone-aware scheduling
permission_handler: ^11.3.1           # Runtime permission requests
```

## Future Enhancements

### Potential Additions:
1. **Smart Notifications:**
   - Adaptive timing based on completion patterns
   - Quiet hours (don't notify during sleep/work)
   - Weather-based adjustments (outdoor habits)

2. **Notification Customization:**
   - Custom notification sounds per habit
   - Notification priority levels
   - Rich notifications with action buttons (Mark Complete, Snooze)

3. **Advanced Analytics:**
   - Track notification response rates
   - Optimize reminder timing based on completion data
   - A/B test different notification strategies

4. **End of Day Summary:**
   - Daily recap of completed/missed habits
   - Streak status summary
   - Tomorrow's scheduled habits preview

5. **Integration Features:**
   - Calendar integration for habit scheduling
   - Widget for quick habit completion
   - Wear OS/Apple Watch support

## Troubleshooting

### Notifications Not Showing

1. **Check Permissions:**
   - Android 13+: Settings > Apps > HabitFlow > Notifications > Enable
   - Verify "Alarms & reminders" permission

2. **Verify Habit Configuration:**
   - Ensure reminder days are selected
   - Confirm reminder time is set
   - Check habit is active (not deleted)

3. **Battery Optimization:**
   - Some devices aggressively kill background apps
   - Add HabitFlow to battery optimization exceptions
   - Settings > Battery > Battery optimization > HabitFlow > Don't optimize

4. **Debug Mode:**
   ```dart
   // Check pending notifications
   final pending = await notificationService.getPendingNotifications();
   print('Pending: ${pending.length} notifications');
   for (var notif in pending) {
     print('ID: ${notif.id}, Title: ${notif.title}');
   }
   ```

### Common Issues

**Issue:** Notifications appear immediately after scheduling
- **Cause:** Timezone not properly initialized
- **Fix:** Ensure `tz.initializeTimeZones()` called before scheduling

**Issue:** Some notifications missing
- **Cause:** ID collision between different habits
- **Fix:** Verify hash-based ID generation is unique

**Issue:** Notifications don't survive app restart
- **Cause:** Plugin not configured for persistence
- **Fix:** Verify boot receiver is registered in AndroidManifest

## Testing

### Manual Testing Checklist

- [ ] Create habit with reminders for today
- [ ] Set reminder time 2-3 minutes in future
- [ ] Verify all 6 notifications appear at correct times
- [ ] Edit habit and change reminder time
- [ ] Verify old notifications cancelled, new ones scheduled
- [ ] Delete habit and verify all notifications cancelled
- [ ] Restart device and verify notifications still scheduled
- [ ] Complete habit and verify remaining notifications still fire
- [ ] Test with multiple habits on same day/time

### Automated Testing

Currently no automated tests for notifications. Consider adding:
- Unit tests for day-to-weekday conversion
- Integration tests for notification scheduling logic
- Widget tests for reminder UI components

## Resources

- [flutter_local_notifications Documentation](https://pub.dev/packages/flutter_local_notifications)
- [Android Notification Channels](https://developer.android.com/develop/ui/views/notifications/channels)
- [iOS Notification Guidelines](https://developer.apple.com/design/human-interface-guidelines/notifications)

---

**Last Updated:** December 21, 2025
**Version:** 1.0.0
**Author:** HabitFlow Development Team
