(function () {
  try {
    var u = new URL(window.location.href);
    var hash = new URLSearchParams((u.hash || "").replace(/^#/, ""));
    if (!hash.get("token")) {
      hash.set("token", "llmstack-openclaw-gateway-token");
      u.hash = hash.toString();
      window.history.replaceState(null, "", u.toString());
    }
  } catch (e) {
    console.warn("openclaw bootstrap failed", e);
  }
})();
