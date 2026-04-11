extends Node

## MobileWeb — GDScript bridge to browser/PWA APIs.
##
## Autoloaded as MobileWeb. All methods are safe to call on any platform;
## non-web platforms either use native equivalents or silently no-op.
##
## Available from any script:
##   MobileWeb.vibrate([50])
##   MobileWeb.request_fullscreen()

signal fullscreen_changed(is_fullscreen: bool)

var _is_web: bool = OS.has_feature("web")


func _ready() -> void:
	if not _is_web:
		return
	_prevent_browser_touch_interference()
	_request_wake_lock()
	_lock_orientation_portrait()


# ── Touch / scroll interference ─────────────────────────────────────────────

func _prevent_browser_touch_interference() -> void:
	# Stops iOS/Android browser from consuming swipes as page-scroll, pinch-zoom,
	# pull-to-refresh, double-tap-zoom, or long-press context-menus.
	JavaScriptBridge.eval("""
(function () {
	var opts = { passive: false };

	// Block all native scroll and zoom gestures on the document
	document.addEventListener('touchmove', function (e) {
		e.preventDefault();
	}, opts);

	// Block multi-touch zoom gestures
	document.addEventListener('touchstart', function (e) {
		if (e.touches.length > 1) e.preventDefault();
	}, opts);

	// Block iOS/Safari gesture events (pinch/rotate)
	document.addEventListener('gesturestart',  function (e) { e.preventDefault(); }, opts);
	document.addEventListener('gesturechange', function (e) { e.preventDefault(); }, opts);
	document.addEventListener('gestureend',    function (e) { e.preventDefault(); }, opts);

	// Block double-tap-to-zoom on iOS (300 ms guard)
	var _lastTap = 0;
	document.addEventListener('touchend', function (e) {
		var now = Date.now();
		if (now - _lastTap < 300) e.preventDefault();
		_lastTap = now;
	}, opts);

	// Block long-press context menu
	document.addEventListener('contextmenu', function (e) { e.preventDefault(); }, false);

	// Block text selection during drag
	document.addEventListener('selectstart', function (e) { e.preventDefault(); }, false);

	// Ensure the canvas element also has touch-action: none
	var canvas = document.getElementById('canvas') || document.querySelector('canvas');
	if (canvas) {
		canvas.style.touchAction    = 'none';
		canvas.style.userSelect     = 'none';
		canvas.style.webkitUserSelect = 'none';
		canvas.style.outline        = 'none';
	}
})();
""", true)


# ── Wake lock ────────────────────────────────────────────────────────────────

func _request_wake_lock() -> void:
	# Keeps the screen on during gameplay. Re-acquires on visibility change
	# (required by the spec — the lock is released when the tab goes background).
	JavaScriptBridge.eval("""
(async function () {
	if (!('wakeLock' in navigator)) return;
	async function acquire() {
		try {
			window._coralWakeLock = await navigator.wakeLock.request('screen');
		} catch (e) {}
	}
	await acquire();
	document.addEventListener('visibilitychange', function () {
		if (document.visibilityState === 'visible') acquire();
	});
})();
""", true)


# ── Screen orientation ───────────────────────────────────────────────────────

func _lock_orientation_portrait() -> void:
	# Orientation lock only works inside a fullscreen context on some browsers;
	# the error is intentionally swallowed.
	JavaScriptBridge.eval("""
(async function () {
	if (screen.orientation && screen.orientation.lock) {
		try { await screen.orientation.lock('portrait-primary'); } catch (e) {}
	}
})();
""", true)


# ── Public API ───────────────────────────────────────────────────────────────

## Trigger haptic feedback. `pattern` is an array of on/off durations in ms,
## e.g. [50] for a single 50 ms pulse. Safe to call on all platforms.
func vibrate(pattern: Array = [50]) -> void:
	if not _is_web:
		return
	var pattern_json := JSON.stringify(pattern)
	JavaScriptBridge.eval(
		"navigator.vibrate && navigator.vibrate(%s)" % pattern_json, true)


## Enter fullscreen. On web this uses the Fullscreen API; on desktop it sets
## the window mode directly. After fullscreen, re-locks portrait orientation.
func request_fullscreen() -> void:
	if not _is_web:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		return
	JavaScriptBridge.eval("""
(function () {
	var el  = document.documentElement;
	var req = el.requestFullscreen || el.webkitRequestFullscreen || el.mozRequestFullScreen;
	if (!req) return;
	req.call(el).then(function () {
		if (screen.orientation && screen.orientation.lock) {
			screen.orientation.lock('portrait-primary').catch(function () {});
		}
	}).catch(function () {});
})();
""", true)


## Exit fullscreen.
func exit_fullscreen() -> void:
	if not _is_web:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		return
	JavaScriptBridge.eval("""
(function () {
	var ex = document.exitFullscreen || document.webkitExitFullscreen;
	if (ex) ex.call(document).catch(function () {});
})();
""", true)


## Returns true when the document is currently in fullscreen (web only).
func is_fullscreen() -> bool:
	if not _is_web:
		return DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	var result: Variant = JavaScriptBridge.eval(
		"!!(document.fullscreenElement || document.webkitFullscreenElement)", true)
	return bool(result)


# ── Focus / visibility handling ──────────────────────────────────────────────

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN and _is_web:
		# Re-acquire wake lock when the tab comes back to the foreground.
		_request_wake_lock()
