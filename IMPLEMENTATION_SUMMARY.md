# Implementation Summary: Animal-Vehicle Collision Reporting (Issue #49 - Complete)

## Overview
Successfully implemented both requirements of GitHub Issue #49:
1. ✅ Dynamic menu names pulled from the backend API
2. ✅ Complete traffic accident (Animal-Vehicle Collision) reporting flow with all required fields

## Part 1: Dynamic Interaction Types (COMPLETED)

### What Was Changed

#### 1. Created New API Layer
**File:** `lib/data_managers/interaction_type_api.dart`
- Created `InteractionTypeApi` class to fetch interaction types from backend
- Implements GET request to `interaction-type/` endpoint
- Returns `List<InteractionType>` with id, name, description

**File:** `lib/interfaces/data_apis/interaction_type_api_interface.dart`
- Created interface contract for interaction type API
- Defines `getAllInteractionTypes()` abstract method

#### 2. Created State Management
**File:** `lib/providers/interaction_type_provider.dart`
- Created `InteractionTypeProvider` extending `ChangeNotifier`
- Manages list of interaction types with loading and error states
- Provides helper methods: `getInteractionTypeByName()`, `getInteractionTypeById()`

**File:** `lib/managers/api_managers/interaction_type_manager.dart`
- Created `InteractionTypeManager` for business logic
- Implements `loadInteractionTypes()` method to fetch from API and update provider
- Handles errors and sets appropriate states

#### 3. Updated Application Bootstrap
**File:** `lib/main.dart`
- Added imports for new interaction type components
- Initialized `InteractionTypeApi`, `InteractionTypeProvider`, `InteractionTypeManager`
- Added `await interactionTypeManager.loadInteractionTypes()` at app startup
- Registered `InteractionTypeProvider` in `MultiProvider`

#### 4. Updated Rapporteren Screen
**File:** `lib/screens/shared/rapporteren.dart`
- Added import for `InteractionTypeProvider` and `TrafficAccidentDetailsScreen`
- Modified `_handleReportTypeSelection()` to accept `interactionTypeId` and `displayName` parameters
- Maps interaction type IDs to internal logic:
  - ID 1 → Waarneming (Animal Sightings)
  - ID 2 → Gewasschade (Crop Damage)
  - ID 3 → Verkeersongeval (Traffic Accident) - NOW ENABLED
  - ID 4 → Diergezondheid (Animal Health) if exists
- Refactored `build()` method to use `context.watch<InteractionTypeProvider>()`
- Created `_buildContent()` method with loading, error, and success states
- Dynamically generates menu buttons from API data
- Maps icon paths based on interaction type IDs

## Part 2: Traffic Accident Reporting Flow (COMPLETED)

### What Was Implemented

#### 1. Created Traffic Accident Details Screen
**File:** `lib/screens/traffic_accident/traffic_accident_details_screen.dart`
- New screen to collect traffic accident-specific details
- Three required fields:
  - **Estimated Damage (€)**: Numeric input for monetary damage
  - **Intensity**: Dropdown with options (high, medium, low)
  - **Urgency**: Dropdown with options (high, medium, low)
- Form validation ensures all fields are filled
- Stores data in `AppStateProvider` before navigating to location screen
- Includes user-friendly Dutch labels and validation messages

#### 2. Updated AppStateProvider
**File:** `lib/providers/app_state_provider.dart`
- Added `setTrafficAccidentDetails()` method
- Takes parameters: `estimatedDamage`, `intensity`, `urgency`
- Updates the current `AccidentReport` in state with collected details
- Includes debug logging for tracking

#### 3. Updated AccidentReport Model
**File:** `lib/models/beta_models/accident_report_model.dart`
- Updated `toJson()` method to include all required fields:
  - `estimatedDamage`: Monetary damage as string
  - `intensity`: String (high/medium/low)
  - `urgency`: String (high/medium/low)
  - `involvedAnimals`: Array of animal data (empty array if none)
- Handles null/empty animals list gracefully

#### 4. Updated Navigation Flow
**File:** `lib/screens/shared/rapporteren.dart`
- Enabled traffic accident button (removed snackbar message)
- Case 3 now navigates to `TrafficAccidentDetailsScreen`
- Initializes map in background
- Sets `ReportType.verkeersongeval` in app state

## How It Works

### Dynamic Menu Names Flow
1. **App Startup:** When the app starts, `main.dart` calls `await interactionTypeManager.loadInteractionTypes()`
2. **API Call:** The manager fetches interaction types from `GET /interaction-type/` endpoint
3. **State Update:** The provider is updated with the list of interaction types
4. **UI Rendering:** The Rapporteren screen watches the provider and displays buttons dynamically
5. **User Selection:** When a button is pressed, the interaction type ID is used to determine navigation flow

### Traffic Accident Reporting Flow
1. **User selects** "Verkeersongeval" from main menu
2. **App navigates** to `TrafficAccidentDetailsScreen`
3. **User enters**:
   - Estimated damage amount (€)
   - Intensity (high/medium/low)
   - Urgency (high/medium/low)
4. **Form validation** ensures all fields are valid
5. **Data is saved** to `AppStateProvider` via `setTrafficAccidentDetails()`
6. **App navigates** to `LocationScreen` (existing flow)
7. **User continues** with location selection and questionnaire (if backend provides one)
8. **Interaction is submitted** to backend with complete payload including:
   - `reportOfCollision` with all fields (estimatedDamage, intensity, urgency, involvedAnimals)
   - Location data
   - Timestamp
   - Species ID (if selected)

## API Contracts

### GET /interaction-type/
**Expected Response:**
```json
[
  {
    "ID": 1,
    "name": "Waarneming",
    "description": "Report animal sightings"
  },
  {
    "ID": 2,
    "name": "Gewasschade",
    "description": "Report crop damage"
  },
  {
    "ID": 3,
    "name": "Verkeersongeval",
    "description": "Report traffic accidents"
  }
]
```

### POST /interaction/ (Traffic Accident)
**Request Payload:**
```json
{
  "description": "Optional description",
  "location": {
    "latitude": 52.3676,
    "longitude": 4.9041
  },
  "moment": "2025-10-29T12:00:00.000Z",
  "place": {
    "latitude": 52.3676,
    "longitude": 4.9041
  },
  "reportOfCollision": {
    "accidentReportID": null,
    "estimatedDamage": "500.00",
    "intensity": "medium",
    "involvedAnimals": [],
    "urgency": "high"
  },
  "speciesID": "species-uuid",
  "typeID": 3
}
```

## UI States

### Rapporteren Screen States

#### Loading State
- Shows `CircularProgressIndicator` while fetching interaction types

#### Error State
- Displays error message
- Shows "Retry" button (currently suggests app restart)

#### Success State
- Dynamically renders 2x2 grid of interaction type buttons
- Each button shows:
  - Icon (mapped by interaction type ID)
  - Name from API
  - OnPressed handler with ID and name

### Traffic Accident Details Screen

#### Form Fields
- **Estimated Damage**: Number input with € prefix, validates positive numbers
- **Intensity**: Dropdown with Dutch labels (Hoog, Gemiddeld, Laag)
- **Urgency**: Dropdown with Dutch labels (Hoog, Gemiddeld, Laag)

#### Validation
- All fields are required
- Damage must be a valid positive number
- Form cannot be submitted until all fields are valid

## Icon Mapping

Icons are mapped to interaction type IDs:
- ID 1: `assets/icons/rapporteren/sighting_icon.png`
- ID 2: `assets/icons/rapporteren/crop_icon.png`
- ID 3: `assets/icons/rapporteren/accident_icon.png`
- ID 4: `assets/icons/rapporteren/health_icon.png`

## Files Created

### Part 1 (Dynamic Menu Names)
1. `lib/data_managers/interaction_type_api.dart`
2. `lib/interfaces/data_apis/interaction_type_api_interface.dart`
3. `lib/providers/interaction_type_provider.dart`
4. `lib/managers/api_managers/interaction_type_manager.dart`

### Part 2 (Traffic Accident Flow)
5. `lib/screens/traffic_accident/traffic_accident_details_screen.dart`

## Files Modified

### Part 1
1. `lib/main.dart` - Added initialization and provider registration
2. `lib/screens/shared/rapporteren.dart` - Made menu dynamic

### Part 2
3. `lib/providers/app_state_provider.dart` - Added `setTrafficAccidentDetails()` method
4. `lib/models/beta_models/accident_report_model.dart` - Updated `toJson()` with all fields
5. `lib/screens/shared/rapporteren.dart` - Enabled traffic accident button, added navigation

## Testing Notes

### Backend Requirements
1. **Interaction Types Endpoint**
   - Ensure `GET /interaction-type/` endpoint exists and returns data
   - Response must include `ID`, `name`, and `description` fields
   - IDs should match expected values (1=Waarneming, 2=Gewasschade, 3=Verkeersongeval)

2. **Traffic Accident Endpoint**
   - `POST /interaction/` with `typeID: 3` must accept traffic accident payload
   - Must handle `reportOfCollision` object with:
     - `estimatedDamage` (string/number)
     - `intensity` (string: "high", "medium", "low")
     - `urgency` (string: "high", "medium", "low")
     - `involvedAnimals` (array, can be empty)

### App Behavior
- If interaction types API fails, user sees error message
- If API returns empty list, user sees "No interaction types available"
- Traffic accident flow now fully functional
- All validation and error handling in place
- Debug logging throughout for troubleshooting

## Architecture Pattern

This implementation follows the established architecture pattern:
```
API Layer → Interface → Provider (State) → Manager (Business Logic) → UI
```

Consistent with existing features like:
- `SpeciesApi` → `SpeciesApiInterface` → `AnimalManager`
- `BelongingApi` → `BelongingApiInterface` → `BelongingManager`
- `InteractionApi` → `InteractionApiInterface` → `InteractionManager`

## Summary

**Issue #49 is now COMPLETE**:
- ✅ Menu names are dynamically pulled from the backend API
- ✅ Traffic accident reporting flow is fully implemented
- ✅ All required fields are collected (estimatedDamage, intensity, urgency)
- ✅ Data is properly formatted and sent to backend
- ✅ User interface is polished with Dutch translations
- ✅ Form validation ensures data quality
- ✅ Architecture follows established patterns
- ✅ Error handling and loading states implemented
- ✅ Debug logging for troubleshooting

The app is now ready for testing the complete traffic accident reporting flow from start to finish!
