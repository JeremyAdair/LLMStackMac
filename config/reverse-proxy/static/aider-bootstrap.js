(function () {
  function injectBanner() {
    if (document.getElementById("llmstack-banner")) return;

    var style = document.createElement("style");
    style.textContent =
      "body{padding-top:36px !important;} #llmstack-banner{position:fixed;top:0;left:0;right:0;z-index:9999;background:#101828;color:#fff;font:600 12px/1.4 Segoe UI,system-ui,sans-serif;padding:8px 12px;display:flex;align-items:center;gap:10px;box-shadow:0 2px 10px rgba(0,0,0,.2)} #llmstack-banner a{color:#ffd37a;text-decoration:none} #llmstack-banner .divider{opacity:.7}";
    document.head.appendChild(style);

    var banner = document.createElement("div");
    banner.id = "llmstack-banner";
    banner.innerHTML =
      'LLMStack <span class="divider">|</span> <a href="https://llmstack.lan/">Back to LLM Stack</a>';
    document.body.appendChild(banner);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", injectBanner, { once: true });
  } else {
    injectBanner();
  }

  new MutationObserver(injectBanner).observe(document.documentElement, {
    childList: true,
    subtree: true,
  });
})();
