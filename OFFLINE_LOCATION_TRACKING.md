# Location Tracking Offline Support - Issue #112

## Overview
This implementation adds support for caching location tracking readings when the device has no internet connection. Cached readings are automatically sent to the backend when the connection is restored, preserving the original timestamps as required by the API.

## Files Created

### 1. `lib/models/beta_models/tracking_reading_model.dart`
A model class to represent a cached tracking reading with:
- `latitude`: GPS latitude coordinate
- `longitude`: GPS longitude coordinate
- `timestampUtc`: The exact time the reading was captured (in UTC)

### 2. `lib/managers/api_managers/tracking_cache_manager.dart`
The main manager responsible for:
- Caching tracking readings to `SharedPreferences` when offline
- Monitoring connectivity changes using `connectivity_plus` package
- Automatically retrying failed readings when connection is restored
- Sending cached readings with their original timestamps to the backend

### 3. `test/business/tracking_cache_manager_test.dart`
Comprehensive unit tests covering:
- Caching tracking readings
- Sending cached readings when online
- Keeping failed readings in cache
- Handling multiple cached readings
- Offline behavior

## Files Modified

### 1. `lib/main.dart`
- Added import for `TrackingCacheManager`
- Instantiated `TrackingCacheManager` with the `TrackingApi`
- Initialized the cache manager with `init()` to start connectivity monitoring
- Set the cache manager on `MapProvider`

### 2. `lib/providers/map_provider.dart`
- Added `TrackingCacheManager` as a dependency
- Added `setTrackingCacheManager()` method
- Modified `sendTrackingPingFromPosition()` to:
  - Use the cache manager by default (if available)
  - Automatically cache readings when they fail to send
  - Fall back to direct API calls if cache manager is not set

## How It Works

### Normal Flow (with internet)
1. User's location is tracked periodically (every 10 seconds in kaart_overview_screen)
2. `MapProvider.sendTrackingPingFromPosition()` is called
3. `TrackingCacheManager.sendOrCacheReading()` checks for internet connection
4. If connected, sends the reading immediately to the API
5. If successful, also attempts to send any previously cached readings

### Offline Flow (no internet)
1. User's location is tracked periodically
2. `MapProvider.sendTrackingPingFromPosition()` is called
3. `TrackingCacheManager.sendOrCacheReading()` detects no internet connection
4. Reading is cached to `SharedPreferences` with its timestamp
5. Location continues to be tracked and cached

### Recovery Flow (internet restored)
1. `TrackingCacheManager` detects connectivity change via `connectivity_plus`
2. Automatically retrieves all cached readings
3. Sends them to the API one by one with original timestamps
4. Successfully sent readings are removed from cache
5. Failed readings remain in cache for next retry
6. A retry loop runs every 10 seconds until all readings are sent

## Key Features

### Timestamp Preservation
The implementation preserves the exact timestamp when each location was captured, meeting the API requirement that the endpoint "Add TrackingReading" supports client-provided timestamps.

### Automatic Retry
The cache manager automatically monitors connectivity and retries sending cached readings without user intervention.

### Resilience
- Failed readings are kept in cache
- Multiple retry attempts with 10-second intervals
- Works even if some readings fail while others succeed

### Testability
- Uses `ConnectionChecker` for mockable connectivity checks
- Can work without connectivity monitoring in test environments
- Comprehensive unit test coverage

## API Compatibility

The implementation maintains full compatibility with the existing `addTrackingReading` endpoint:

```dart
{
  "location": {
    "latitude": 52.0,
    "longitude": 5.0
  },
  "timestamp": "2025-11-20T12:00:00.000Z"  // Original timestamp preserved
}
```

## Testing

Run the tests with:
```bash
flutter test test/business/tracking_cache_manager_test.dart
```

All 7 tests should pass, covering:
- Caching functionality
- Sending cached readings
- Handling failures
- Preserving order and timestamps
- Offline/online scenarios

## Usage in the App

The tracking cache manager is fully integrated and requires no additional configuration. It works automatically:

1. When location tracking is enabled in user settings
2. When the user is on the map screen (kaart_overview_screen)
3. Periodic tracking sends location every 10 seconds
4. All readings (successful or cached) use this system

## Future Enhancements

Potential improvements:
- Add a UI indicator showing how many cached readings are pending
- Add a manual "sync now" button for users
- Implement exponential backoff for retry intervals
- Add limits on cache size to prevent excessive storage use
- Add telemetry to track cache hit rates and offline duration
