// startup
user_pref("browser.startup.homepage", "about:blank");
user_pref("browser.startup.page", 3);  // restore previous session

// blank new tabs
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.section.highlights.includeBookmarks", false);
user_pref("browser.newtabpage.activity-stream.section.highlights.includeDownloads", false);
user_pref("browser.newtabpage.activity-stream.section.highlights.includePocket", false);
user_pref("browser.newtabpage.activity-stream.section.highlights.includeVisited", false);
user_pref("browser.newtabpage.activity-stream.showSearch", false);
user_pref("browser.newtabpage.activity-stream.showWeather", false);

// search
user_pref("browser.urlbar.placeholderName", "DuckDuckGo");
user_pref("browser.urlbar.placeholderName.private", "DuckDuckGo");
user_pref("browser.search.region", "US");
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.urlbar.suggest.history", false);
user_pref("browser.urlbar.suggest.bookmark", false);
user_pref("browser.urlbar.suggest.engines", false);
user_pref("browser.urlbar.suggest.openpage", false);
user_pref("browser.urlbar.suggest.quickactions", false);
user_pref("browser.urlbar.suggest.quicksuggest.all", false);
user_pref("browser.urlbar.suggest.recentsearches", false);
user_pref("browser.urlbar.suggest.searches", false);
user_pref("browser.urlbar.suggest.topsites", false);

// privacy
user_pref("dom.security.https_only_mode", true);
user_pref("privacy.globalprivacycontrol.enabled", true);
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.emailtracking.enabled", true);
user_pref("privacy.trackingprotection.socialtracking.enabled", true);
user_pref("privacy.fingerprintingProtection", true);
user_pref("privacy.query_stripping.enabled", true);
user_pref("privacy.query_stripping.enabled.pbmode", true);
user_pref("browser.contentblocking.category", "standard");

// DNS over HTTPS
user_pref("network.trr.mode", 3);  // always
user_pref("network.trr.uri", "https://mozilla.cloudflare-dns.com/dns-query");
user_pref("doh-rollout.disable-heuristics", true);

// general behavior
user_pref("browser.warnOnQuit", false);
user_pref("browser.tabs.warnOnClose", true);
user_pref("browser.bookmarks.showMobileBookmarks", false);
user_pref("browser.link.open_newwindow.override.external", 7);  // open links from apps next to active tab
user_pref("findbar.highlightAll", true);
user_pref("media.videocontrols.picture-in-picture.video-toggle.enabled", false);
user_pref("sidebar.revamp", false);
user_pref("sidebar.visibility", "hide-on-close");

// developer tools
user_pref("devtools.command-button-screenshot.enabled", true);
user_pref("devtools.application.enabled", false);
user_pref("devtools.memory.enabled", false);
user_pref("devtools.styleeditor.enabled", false);

// disable autofill
user_pref("browser.formfill.enable", false);
user_pref("extensions.formautofill.addresses.enabled", false);
user_pref("extensions.formautofill.creditCards.enabled", false);

// disable password manager
user_pref("signon.rememberSignons", false);
user_pref("signon.management.page.breach-alerts.enabled", false);  // no password breach alerts

// disable extension recommendations
user_pref("browser.discovery.enabled", false);

// disable studies
user_pref("app.shield.optoutstudies.enabled", false);

// disable AI
user_pref("browser.tabs.groups.smart.userEnabled", false);
user_pref("browser.ml.chat.menu", false);
user_pref("browser.ml.linkPreview.enabled", false);

// crash reports
user_pref("browser.crashReports.unsubmittedCheck.autoSubmit2", true);
