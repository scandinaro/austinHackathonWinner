# Testing Dynamic Video Loading

## What Changed

The app now dynamically loads videos based on the URL used to invoke it!

**URL Format:** `v.cameo.com/{video_id}`
**Constructs:** `https://cdn.cameo.com/video/{video_id}-processed.mp4`

## Test Commands

### Test 1: Original Video (Default)
```bash
xcrun simctl openurl booted "https://v.cameo.com/6536b92a64a84efc4acbce6a"
```
**Expected:** Loads the original Cameo video we've been using

### Test 2: Different Video ID
```bash
xcrun simctl openurl booted "https://v.cameo.com/test-video-123"
```
**Expected:**
- Console shows: `🎬 Loading video ID: test-video-123`
- Attempts to load: `https://cdn.cameo.com/video/test-video-123-processed.mp4`
- May fail if video doesn't exist (will show error screen)

### Test 3: No Video ID (Fallback)
```bash
xcrun simctl openurl booted "https://v.cameo.com/"
```
**Expected:**
- Console shows: `🎬 Loading default video (no video ID provided)`
- Loads fallback video: `6536b92a64a84efc4acbce6a`

### Test 4: Another Real Video
If you have another Cameo video ID, try:
```bash
xcrun simctl openurl booted "https://v.cameo.com/YOUR_VIDEO_ID_HERE"
```

## What to Watch For in Console

When you invoke with a URL, look for these logs:

```
App Clip invoked with Branch URL: https://v.cameo.com/abc123
📊 Analytics Event: app_clip_launched
   Properties: ["video_id": "abc123", "url": "https://v.cameo.com/abc123"]
🎬 Loading video ID: abc123
    Video URL: https://cdn.cameo.com/video/abc123-processed.mp4
📊 Analytics Event: video_viewed
📊 Analytics Event: video_loaded
```

## Testing in Xcode

1. Build and run the app
2. While app is running in simulator, use the test commands above
3. App should reload with the new video ID
4. Check Xcode console for the log messages

## URL Pattern Assumptions

Current implementation assumes:
- Videos are on CDN: `cdn.cameo.com`
- Path format: `/video/{id}-processed.mp4`
- All videos have `-processed` suffix

If your video URLs have different patterns, we'll need to adjust the VideoViewModel URL construction logic.

## Next Steps for Production

1. **Validate video IDs** - Check if video exists before loading
2. **Better error handling** - Show user-friendly message if video not found
3. **Loading states** - Show thumbnail while video loads
4. **Branch integration** - Use Branch SDK to get full video URL from link metadata
