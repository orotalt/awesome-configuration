// Preferences for Firefox. To be symlinked in the profile as user.js.
// Settings synced through Firefox Accounts may not be present.

// Ensure context menus stay open after left-click (useful when scale
// == 1.5)
user_pref("ui.context_menus.after_mouseup", true);

// Don't display menubar when pressing Alt
user_pref("ui.key.menuAccessKeyFocuses", false);

// Default download dir
user_pref("browser.download.dir", "/home/bernat/download");

// No popup at all!
user_pref("browser.link.open_newwindow.restriction", 0);

// Search settings
user_pref("browser.search.region", "FR");
user_pref("browser.search.suggest.enabled", false);

// Homepage is newtab
user_pref("browser.startup.homepage", "about:newtab");

// Languages
user_pref("intl.accept_languages", "en-us,en,fr");

// Backspace is like back
user_pref("browser.backspace_action", 0);

// Ctrl-Tab should not use recent order (it's confusing for me)
user_pref("browser.ctrlTab.recentlyUsedOrder", false);