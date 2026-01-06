# App Size Optimization - Reducing from 150MB to 70MB

**Date:** 05/01/2026  
**Project:** Wildlife NL - Wild Rapport App  
**Issue:** [#171](https://github.com/BasMichielsen/wildrapport/issues/171) - Compiled app size too large

---

## What

### The Problem
The compiled Android APK size was **>150MB**, which is unreasonably large for a small wildlife reporting app. This causes:
- ❌ Slow downloads for users (especially on mobile data)
- ❌ Takes up excessive phone storage
- ❌ Users may avoid installing the app
- ❌ Google Play Store warnings about large app size

**Acceptable size for this type of app:** 10-20MB  
**Our goal:** Reduce to under 100MB as first step

### The Solution
Identified and removed unused/duplicate asset files that were bloating the app bundle.

**Results:**
- ✅ **Before:** >150MB
- ✅ **After:** ~70MB
- ✅ **Reduction:** ~53% smaller

---

## Why

### What causes large app sizes?

Flutter apps bundle everything specified in `pubspec.yaml`:
1. **Code** - Dart code compiled to native (usually 5-15MB)
2. **Assets** - Images, fonts, animations (can be 50-200MB if not managed)
3. **Dependencies** - Third-party packages
4. **Native libraries** - Platform-specific code for Android/iOS

### Why our app was 150MB

Investigation revealed the **assets folder was 93MB**, containing:
1. **Duplicate animal images** - Same images in multiple locations:
   - Root level: `wolf.png`, `fox.png`, `deer.png`, etc.
   - In `assets/animals/` folder
   - In `assets/icons/animals/` folder
   
2. **Unused logo variants** - Multiple unused versions:
   - `app_logo.png`, `app_logo1.png`, `app_logo2.png`, `app_logo4.png`
   
3. **Wildcard asset inclusion** - The line `- assets/` in `pubspec.yaml` was bundling **everything** under assets/, including:
   - Test files
   - Backup copies
   - Unused graphics
   - Files referenced but not actually present (causing build errors)

### Why the first attempt didn't work much

**First attempt:** Enabled Android resource shrinking
```kotlin
isShrinkResources = true  // in build.gradle.kts
```

**Why it only helped a little:**
- Resource shrinking only removes **unused Android resources** (drawables, strings, colors)
- It does NOT remove Flutter assets defined in `pubspec.yaml`
- Our bloat was from Flutter assets, not Android resources

---

## How

### Step 1: Enable Resource Shrinking (Minor improvement)

**File:** `android/app/build.gradle.kts`  
**Line:** ~67

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName(if (hasReleaseKeystore) "release" else "debug")
        isMinifyEnabled = true
        isShrinkResources = true  // Changed from false to true
        proguardFiles(
            getDefaultProguardFile("proguard-android.txt"),
            "proguard-rules.pro"
        )
    }
}
```

**Impact:** Small reduction (~5-10MB) by removing unused Android resources.

---

### Step 2: Analyze Asset Folder Size

Run PowerShell command to measure assets:
```powershell
Get-ChildItem -Path "d:\Wildlife\wildrapport\assets" -Recurse -File | 
  Measure-Object -Property Length -Sum | 
  ForEach-Object {[math]::Round($_.Sum / 1MB, 2)}
```

**Result:** 93.2 MB just in assets!

---

### Step 3: Clean Up pubspec.yaml Assets

**File:** `pubspec.yaml`  
**Lines:** 64-100

**Changes made:**

1. **Removed duplicate root-level animal PNGs:**
   ```yaml
   # REMOVED (files don't exist or are duplicates):
   - assets/wolf.png
   - assets/fox.png
   - assets/marten.png
   - assets/deer.png
   - assets/beer.png
   - assets/tiger.png
   - assets/LogoWildlifeNL.png
   - assets/LogoHeadWildlifeNL.png
   - assets/icons/deer.png  # Duplicate
   ```

2. **Removed dangerous wildcard:**
   ```yaml
   # REMOVED:
   - assets/  # This was bundling EVERYTHING including junk
   ```

3. **Kept only necessary folders:**
   ```yaml
   # KEPT (used by app):
   - assets/icons/animals/  # Folder wildcard for animal icons
   - assets/animals/        # Folder wildcard for animal images
   - assets/gifs/           # Specific files only
   - assets/icons/...       # Specific icons referenced in code
   ```

**Before (bloated):**
```yaml
assets:
  - assets/wolf.png          # Doesn't exist
  - assets/fox.png           # Doesn't exist
  - assets/deer.png          # Doesn't exist
  - assets/icons/animals/    # Folder with actual files
  - assets/animals/          # Duplicate images
  - assets/                  # ⚠️ Bundles EVERYTHING!
```

**After (optimized):**
```yaml
assets:
  - assets/app_logo.png      # Only 1 logo kept
  - assets/loaders/loading_paw.json
  - assets/gifs/login.gif
  - assets/gifs/thankyou.gif
  - assets/icons/animals/    # Folder wildcard
  - assets/animals/          # Folder wildcard
  - assets/icons/...         # Specific icons only
```

---

### Step 4: Clean Build Cache

After editing `pubspec.yaml`, Flutter caches can cause stale data:

```powershell
flutter clean
flutter pub get
flutter build apk --release
```

This ensures Flutter rebuilds everything from scratch with the new asset list.

---

## Result

### Size Comparison
| Build Type | Size | Notes |
|------------|------|-------|
| **Original** | >150MB | With all duplicate assets |
| **After resource shrinking** | ~145MB | Minor improvement |
| **After asset cleanup** | **~70MB** | **53% reduction** ✅ |

### What was removed
- ❌ Duplicate animal images at root level (wolf.png, fox.png, etc.)
- ❌ Extra logo files (app_logo1-4.png)
- ❌ Non-existent file references (LogoWildlifeNL.png)
- ❌ Wildcard `assets/` inclusion
- ✅ Kept only the `assets/icons/animals/` folder with 12 icon files

### Files actually used by app
The app code references animal icons like this:
```dart
// In kaart_overview_screen.dart
String? _getAnimalIconPath(String? speciesName) {
  if (name.contains('wolf')) return 'assets/icons/animals/wolf.png';
  if (name.contains('vos')) return 'assets/icons/animals/vos.png';
  // etc...
}
```

These files exist in `assets/icons/animals/`:
- wolf.png, vos.png, das.png, ree.png
- wild_zwijn.png, damhert.png, egel.png
- eekhoorn.png, beaver.png, boommarten.png
- hooglander.png, winsent.png

---

## Further Optimization Opportunities

### 1. Per-ABI Split APKs (Recommended Next Step)
Currently bundling all CPU architectures in one APK. Split into separate files:

```powershell
flutter build apk --release --split-per-abi
```

This creates 3 APKs:
- `app-armeabi-v7a-release.apk` (~25MB) - for older 32-bit phones
- `app-arm64-v8a-release.apk` (~28MB) - for modern 64-bit phones
- `app-x86_64-release.apk` (~30MB) - for emulators/rare devices

**Users only download what their phone needs.**

**Expected result:** Each APK ~25-30MB instead of 70MB

---

### 2. App Bundle (Best for Play Store)
Let Google Play automatically optimize per-device:

```powershell
flutter build appbundle --release
```

Upload the `.aab` file to Play Store instead of APK.

**Benefits:**
- Google splits by ABI, screen density, language
- Users get 40-60% smaller downloads
- Dynamic delivery of features

**Expected result:** User downloads ~20-30MB

---

### 3. Asset Compression (Future)
Convert large PNGs to WebP format:
- WebP provides ~30% better compression than PNG
- Lossless quality
- Supported on all modern Android versions

**Tools:**
```powershell
# Install cwebp converter
# Convert PNGs to WebP
cwebp input.png -o output.webp
```

**Expected result:** Additional 10-20MB reduction

---

### 4. Remove Unused Dependencies
Audit `pubspec.yaml` for unused packages:
```powershell
flutter pub deps
```

Remove any packages not actively used in code.

---

## Lessons Learned

### ✅ Do's
1. **Be specific in pubspec.yaml** - Only include assets you need
2. **Use folder wildcards carefully** - `assets/icons/animals/` not `assets/`
3. **Check actual file existence** - Don't reference files that don't exist
4. **Measure before optimizing** - Know where the bloat is
5. **Test after changes** - Always rebuild with `flutter clean`

### ❌ Don'ts
1. **Don't use broad wildcards** - `assets/` bundles everything
2. **Don't keep duplicate files** - One source of truth per asset
3. **Don't assume resource shrinking fixes all** - It only helps with Android resources
4. **Don't skip clean builds** - Cache can hide problems


## References

- Flutter Asset Management: https://docs.flutter.dev/ui/assets/assets-and-images
- Android App Size: https://developer.android.com/topic/performance/reduce-apk-size
- Flutter Build Modes: https://docs.flutter.dev/testing/build-modes

---

**Status:** ✅ COMPLETE - Achieved 70MB (53% reduction from 150MB)  
**Next Steps:** Consider per-ABI splits or App Bundle for further 50-60% reduction
