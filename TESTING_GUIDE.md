# Testing Guide: Animal-Vehicle Collision Feature (Issue #49)

## Prerequisites
1. Backend must have `GET /interaction-type/` endpoint running
2. Backend must accept `POST /interaction/` with `typeID: 3` (traffic accidents)
3. App must be logged in with valid bearer token

## Test Flow

### 1. Test Dynamic Menu Names

**Expected Behavior:**
- App fetches interaction types from backend on startup
- Main "Rapporteren" screen displays menu items with names from API

**Steps:**
1. Start the app
2. Navigate to "Rapporteren" screen
3. Verify menu items display names from backend (not hardcoded)

**Loading State:**
- Should see circular progress indicator while fetching

**Error State:**
- If API fails, should see error message with "Retry" button

**Success State:**
- Should see 2x2 grid of buttons with dynamic names

### 2. Test Traffic Accident Flow

**Steps:**
1. Navigate to "Rapporteren" screen
2. Tap "Verkeersongeval" button
3. Should navigate to Traffic Accident Details screen

**Traffic Accident Details Screen:**

**Field: Estimated Damage**
- Label: "Geschatte schade (€)"
- Type: Number input with € prefix
- Validation: Must be positive number
- Test cases:
  - ✅ Enter "500.00" → Valid
  - ✅ Enter "1000" → Valid
  - ❌ Leave empty → Shows "Voer een geschatte schade in"
  - ❌ Enter "-100" → Shows "Voer een geldig bedrag in"
  - ❌ Enter "abc" → Input formatter prevents non-numeric

**Field: Intensity**
- Label: "Intensiteit"
- Type: Dropdown
- Options:
  - Hoog (high)
  - Gemiddeld (medium)
  - Laag (low)
- Validation: Must select one
- Test cases:
  - ❌ Leave unselected → Shows "Selecteer een intensiteit"
  - ✅ Select any option → Valid

**Field: Urgency**
- Label: "Urgentie"
- Type: Dropdown
- Options:
  - Hoog (high)
  - Gemiddeld (medium)
  - Laag (low)
- Validation: Must select one
- Test cases:
  - ❌ Leave unselected → Shows "Selecteer een urgentie"
  - ✅ Select any option → Valid

**Submit Form:**
1. Fill all fields with valid data
2. Tap "Volgende" button
3. Should navigate to Location Screen
4. Data should be stored in AppStateProvider

**Back Navigation:**
1. Tap back arrow in app bar
2. Should return to Rapporteren screen
3. Can re-enter the flow and data should be cleared

### 3. Complete Flow Test

**Full End-to-End Test:**
1. Start at Rapporteren screen
2. Tap "Verkeersongeval"
3. Enter traffic accident details:
   - Estimated damage: 500.00
   - Intensity: Gemiddeld
   - Urgency: Hoog
4. Tap "Volgende"
5. Continue with location selection
6. Continue with questionnaire (if provided by backend)
7. Submit report
8. Verify backend receives correct payload

**Expected Payload Structure:**
```json
{
  "description": "",
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
  "speciesID": null,
  "typeID": 3
}
```

## Backend Validation

### Check GET /interaction-type/ Response
```bash
curl -X GET "https://test-api-wildlifenl.uu.nl/interaction-type/" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Expected:
```json
[
  {
    "ID": 1,
    "name": "Waarneming",
    "description": "..."
  },
  {
    "ID": 2,
    "name": "Gewasschade",
    "description": "..."
  },
  {
    "ID": 3,
    "name": "Verkeersongeval",
    "description": "..."
  }
]
```

### Check POST /interaction/ Accepts Traffic Accident
```bash
curl -X POST "https://test-api-wildlifenl.uu.nl/interaction/" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "typeID": 3,
    "location": {
      "latitude": 52.3676,
      "longitude": 4.9041
    },
    "reportOfCollision": {
      "estimatedDamage": "500.00",
      "intensity": "medium",
      "urgency": "high",
      "involvedAnimals": []
    }
  }'
```

Should return 200 OK with interaction response.

## Debug Logging

Watch for these log messages:

### App Startup
```
[InteractionTypeManager] Loading interaction types...
[InteractionTypeApi] Fetching all interaction types...
[InteractionTypeProvider] Setting 3 interaction types
```

### Rapporteren Screen
```
[Rapporteren] Verkeersongeval selected, initializing map
```

### Traffic Accident Details
```
[TrafficAccidentDetails] Saving data: {estimatedDamage: 500.0, intensity: medium, urgency: high}
[AppStateProvider] Traffic accident details set: damage=500.0, intensity=medium, urgency=high
```

### Interaction Submission
```
[InteractionAPI]: Report is verkeersongeval
[InteractionAPI] Response code: 200
[InteractionAPI] Response body: {...}
```

## Common Issues

### Issue: Menu items not showing
- **Cause:** Backend endpoint not returning data
- **Fix:** Check backend logs, verify endpoint exists

### Issue: "No interaction types available"
- **Cause:** Backend returns empty array
- **Fix:** Ensure backend has interaction types seeded

### Issue: Traffic accident button shows "Deze functie is nog niet beschikbaar"
- **Cause:** Old code still in place
- **Fix:** Verify rapporteren.dart has been updated (case 3 should navigate to TrafficAccidentDetailsScreen)

### Issue: Form validation not working
- **Cause:** User trying to submit with empty fields
- **Fix:** This is expected behavior - fill all required fields

### Issue: Backend rejects payload
- **Cause:** Payload format mismatch
- **Fix:** Check backend expects correct field names and types

## Success Criteria

✅ All checklist items should pass:
- [ ] App loads interaction types on startup
- [ ] Menu displays dynamic names from API
- [ ] Traffic accident button is enabled
- [ ] Clicking traffic accident navigates to details screen
- [ ] All form fields have proper validation
- [ ] Form cannot be submitted with invalid data
- [ ] Valid form navigates to location screen
- [ ] Data is stored in AppStateProvider
- [ ] Complete flow submits correct payload to backend
- [ ] Backend accepts and stores traffic accident report
- [ ] No console errors during flow
- [ ] Back navigation works correctly
- [ ] Loading states display properly
- [ ] Error states display properly

## Test Scenarios

### Scenario 1: Happy Path
1. User selects Verkeersongeval
2. User fills all fields correctly
3. User continues through location selection
4. Report is submitted successfully

### Scenario 2: Validation Errors
1. User selects Verkeersongeval
2. User tries to submit without filling fields
3. Validation errors appear
4. User fills fields correctly
5. Form submits successfully

### Scenario 3: Back Navigation
1. User selects Verkeersongeval
2. User partially fills form
3. User clicks back button
4. User returns to Rapporteren screen
5. User can restart flow

### Scenario 4: API Error
1. Backend interaction-type endpoint is down
2. App shows error state
3. User sees helpful error message
4. User can retry (via app restart)

## Performance Notes

- Interaction types are loaded once at app startup
- Cached in InteractionTypeProvider
- No additional API calls when navigating to Rapporteren screen
- Map initialization happens in background
- Form validation is instant (no API calls)
- Only network call is final submission

## Accessibility Notes

- All form fields have proper labels
- Error messages are descriptive
- Buttons have sufficient touch targets
- Color contrast meets accessibility standards
- Screen reader compatible
