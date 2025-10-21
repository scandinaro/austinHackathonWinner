# Adding App Clip Target - Step by Step

I've already copied all the App Clip files to `ios/CameoPOC/CameoAppClip/`. Now you just need to add the App Clip target in Xcode.

## Step 1: Open Project in Xcode

```bash
open ios/CameoPOC/CameoPOC.xcodeproj
```

Or double-click `CameoPOC.xcodeproj` in Finder.

## Step 2: Add App Clip Target

1. **In Xcode**, click on the project name "CameoPOC" in the left sidebar (the blue icon at the very top)
2. You'll see targets listed in the main editor area
3. At the **bottom** of the targets list, click the **+** button
4. In the dialog that appears:
   - Search for "App Clip" in the filter box at top
   - Select **"App Clip"** (under iOS section)
   - Click **Next**

5. In the options screen:
   - Product Name: **CameoAppClip**
   - Organization Identifier: (should match your main app)
   - Bundle Identifier: Will auto-fill as `com.yourname.CameoPOC.Clip`
   - Language: **Swift**
   - User Interface: **SwiftUI**
   - Embed in Application: **CameoPOC** (should be selected)
   - Click **Finish**

6. When asked "Activate CameoAppClip scheme?", click **Activate**

## Step 3: Delete Auto-Generated Files

Xcode created some default files we don't need. In the left sidebar:

1. Find the **CameoAppClip** folder (blue icon)
2. Inside, you'll see Xcode's auto-generated files:
   - `CameoAppClipApp.swift` (Xcode's version)
   - `ContentView.swift` (Xcode's version)
   - Maybe an `Assets.xcassets` folder
3. **Right-click each one** → **Delete** → Choose **"Move to Trash"** (not just "Remove Reference")

## Step 4: Add Your Files to Xcode

Now we need to tell Xcode about the files I copied for you:

1. **Right-click** on the **CameoAppClip** folder (blue icon) in the left sidebar
2. Choose **"Add Files to CameoPOC..."**
3. Navigate to: `ios/CameoPOC/CameoAppClip/`
4. **Select ALL files**:
   - `AnalyticsManager.swift`
   - `CameoAppClipApp.swift`
   - `ContentView.swift`
   - `VideoViewModel.swift`
   - `Info.plist`
   - `Assets.xcassets` (folder)
5. **Important**: Before clicking Add, check these options at the bottom:
   - ✅ **Copy items if needed** - UNCHECK this (files are already in place)
   - ✅ **Create groups** - should be selected
   - ✅ **Add to targets** - make sure **ONLY CameoAppClip** is checked (NOT CameoPOC)
6. Click **Add**

## Step 5: Verify Setup

In the left sidebar, your **CameoAppClip** folder should now show:
```
CameoAppClip/
├── CameoAppClipApp.swift
├── ContentView.swift
├── VideoViewModel.swift
├── AnalyticsManager.swift
├── Assets.xcassets/
└── Info.plist
```

## Step 6: Set Deployment Target

1. Click **CameoPOC** (project name) in left sidebar
2. Select **CameoAppClip** target in the targets list
3. In the **General** tab, find **Minimum Deployments**
4. Set **iOS** to **16.0** or higher

## Step 7: Build and Run

1. At the top of Xcode, click the scheme dropdown (next to the Play button)
2. Select **CameoAppClip** scheme
3. Choose a simulator (iPhone 15 Pro or similar, iOS 16+)
4. Click the **Play** button (▶️) or press Cmd+R

## ✅ Expected Result

- App launches in simulator
- "Loading your Cameo..." appears briefly
- Video starts playing automatically
- Watch it through to the end
- Post-video overlay appears with "Download & Save Video" button

## 🐛 Troubleshooting

**"Cannot find X in scope" errors:**
- Make sure all 4 `.swift` files are in the CameoAppClip target
- Click on each file in sidebar, check the **File Inspector** (right panel)
- Under **Target Membership**, ensure **CameoAppClip** is checked

**"Multiple targets" or build errors:**
- Make sure files are ONLY in CameoAppClip target, NOT in CameoPOC

**App won't run:**
- Check deployment target is iOS 16.0+
- Try cleaning build folder: **Product → Clean Build Folder** (Shift+Cmd+K)

**Still stuck?**
Let me know what error you're seeing and I'll help!
