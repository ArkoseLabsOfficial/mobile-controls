
# 2.0.0 (ReWrite)

- **⚠︎ BREAKING CHANGE ⚠︎:** Entire Library has been rewritten, this version require to update mobile-control images and json files in your game to latest json type and images.
- Added `OpenFL Support`.
- `mobile_controls_allow_mouse_clicks` has been removed.
- Added `DPad`.
- Added `Custom Bounds` Support to JoyStick.
- General performance improvements.

# 1.0.0 (First Stable Release)

- **⚠︎ BREAKING CHANGE ⚠︎:** Updated and renamed several variables for consistency.
- Added `ScreenUtil`.
- Added `MobileControlManager`.
- Added `Unique ID` (specifically for ID-based input systems in games like FNF).
- Added `overlapsUltraComplex()` to the Touch class.
- Added `mobile_controls_allow_mouse_clicks` flag for testing on PC.
- Removed `TouchUtil` & `SwipeUtil` classes (migrated to `ScreenUtil.touch` and `ScreenUtil.swipe`).
- **JoyStick Reworked:** Highly optimized core logic with a new fallback system.
- General performance improvements.

# 0.1.0 (First Release)

- Initial Library Release.