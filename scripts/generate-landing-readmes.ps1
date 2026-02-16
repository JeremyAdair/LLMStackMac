param()

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$landingReadmesDir = Join-Path $repoRoot "config/landing/readmes"
New-Item -ItemType Directory -Force -Path $landingReadmesDir | Out-Null

$readmeMap = @(
  @{ Input = "README.md"; Output = "root-readme.html"; Title = "Project README" },
  @{ Input = "python-toolbox/README.md"; Output = "python-toolbox-readme.html"; Title = "Python Toolbox README" },
  @{ Input = "workspaces/README.md"; Output = "workspaces-readme.html"; Title = "Workspaces README" },
  @{ Input = "roadmap/landing-page/README.md"; Output = "roadmap-landing.html"; Title = "Roadmap - Landing Page" },
  @{ Input = "roadmap/backups/README.md"; Output = "roadmap-backups.html"; Title = "Roadmap - Backups" },
  @{ Input = "roadmap/ci-tests/README.md"; Output = "roadmap-ci-tests.html"; Title = "Roadmap - CI Tests" }
)

foreach ($entry in $readmeMap) {
  $inputPath = Join-Path $repoRoot $entry.Input
  if (-not (Test-Path -Path $inputPath)) {
    throw "Missing README input: $($entry.Input)"
  }

  $markdown = Get-Content -Path $inputPath -Raw
  $escaped = [System.Net.WebUtility]::HtmlEncode($markdown)
  $title = [System.Net.WebUtility]::HtmlEncode($entry.Title)

  $html = @"
<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>$title</title>
    <link rel="stylesheet" href="/styles.css" />
  </head>
  <body>
    <main class="container">
      <header>
        <h1>$title</h1>
      </header>

      <section class="links">
        <a class="button" href="/docs.html">Back to Docs</a>
        <a class="button" href="/python-api.html">Back to Python API</a>
        <a class="button" href="/">Back to Landing</a>
      </section>

      <section class="note">
        <pre style="white-space: pre-wrap;">$escaped</pre>
      </section>
    </main>
  </body>
</html>
"@

  $outputPath = Join-Path $landingReadmesDir $entry.Output
  Set-Content -Path $outputPath -Value $html -Encoding UTF8
  Write-Host "Generated $($entry.Output)"
}
