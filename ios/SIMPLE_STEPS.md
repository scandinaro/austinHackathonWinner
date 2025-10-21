# Super Simple Steps - Just Drag and Drop!

I've deleted the auto-generated files for you. Now you just need to add the real files in Xcode.

## Current State ✅

- ✅ App Clip target created: `com.cameo.CameoPOC.Clip`
- ✅ Auto-generated Swift files deleted
- ✅ Your real files are ready in: `CameoAppClip/` folder

## What You Need to Do (2 minutes)

### Step 1: Open Xcode (if not already open)

```bash
open ios/CameoPOC/CameoPOC.xcodeproj
```

### Step 2: Find Your Files in Finder

Open Finder to this location:
```bash
open ios/CameoPOC/CameoAppClip
```

You should see:
- AnalyticsManager.swift
- CameoAppClipApp.swift
- ContentView.swift
- VideoViewModel.swift
- Info.plist
- Assets.xcassets (folder)

### Step 3: Drag Files into Xcode

1. In **Xcode**, find the `com.cameo.CameoPOC.Clip` folder in the left sidebar (it's the blue folder icon)

2. In **Finder**, select all the files (Cmd+A):
   - AnalyticsManager.swift
   - CameoAppClipApp.swift
   - ContentView.swift
   - VideoViewModel.swift
   - Info.plist
   - Assets.xcassets

3. **Drag and drop** all these files from Finder into the `com.cameo.CameoPOC.Clip` folder in Xcode

4. A dialog will appear. Make sure these settings:
   - ☐ **Copy items if needed** - UNCHECK this
   - ☑️ **Create groups** - should be selected
   - **Add to targets** - make sure ONLY `com.cameo.CameoPOC.Clip` is checked

5. Click **Finish**

### Step 4: Verify Files Added

In Xcode's left sidebar, expand `com.cameo.CameoPOC.Clip` folder. You should now see:

```
com.cameo.CameoPOC.Clip/
├── AnalyticsManager.swift
├── CameoAppClipApp.swift
├── ContentView.swift
├── VideoViewModel.swift
├── Assets.xcassets/
├── Info.plist (two copies - that's OK, one is yours, one is Xcode's)
└── com_cameo_CameoPOC_Clip.entitlements
```

### Step 5: Build and Run!

1. At the top of Xcode, click the **scheme dropdown** (next to the Play button)
2. Select **com.cameo.CameoPOC.Clip** scheme
3. Choose a simulator: **iPhone 15 Pro** (iOS 17.0+)
4. Click **Play** button ▶️

## What Should Happen

1. App builds (might take 30-60 seconds first time)
2. Simulator launches
3. "Loading your Cameo..." appears
4. Video starts playing automatically
5. Let video play all the way through
6. Post-video overlay appears with "Download & Save Video"

## 🐛 If You Get Errors

**"Cannot find X in scope":**
- Click on one of the .swift files in Xcode
- Press Cmd+Option+1 to open File Inspector
- Under "Target Membership", make sure `com.cameo.CameoPOC.Clip` is checked

**"Duplicate symbol" or "Multiple commands":**
- You might have duplicate Info.plist files
- In Xcode, click on the project name → com.cameo.CameoPOC.Clip target
- Go to "Build Phases" tab
- Under "Copy Bundle Resources", if you see two Info.plist entries, remove the old one

**Still stuck?**
Let me know what error message you see!

---

## Alternative: If Drag-and-Drop Doesn't Work

1. Right-click on `com.cameo.CameoPOC.Clip` folder in Xcode
2. Choose "Add Files to 'CameoPOC'..."
3. Navigate to `ios/CameoPOC/CameoAppClip/`
4. Select all files
5. UNCHECK "Copy items if needed"
6. Make sure only `com.cameo.CameoPOC.Clip` target is checked
7. Click "Add"
