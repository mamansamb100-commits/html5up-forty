# ═══════════════════════════════════════════════════════════════════
#  SETUP COMPLET — html5up-forty (Windows PowerShell)
#  Usage : .\setup.ps1
# ═══════════════════════════════════════════════════════════════════

$GITHUB_USERNAME = "mamansamb100-commits"
$REPO            = "html5up-forty"
$GITHUB_URL      = "https://github.com/$GITHUB_USERNAME/$REPO.git"
$IMAGE           = "ci-html"
$TAG             = "1.0.1"
$PORT            = 8080

function log  { param($m) Write-Host "✅ $m" -ForegroundColor Green }
function warn { param($m) Write-Host "⚠️  $m" -ForegroundColor Yellow }
function info { param($m) Write-Host "ℹ️  $m" -ForegroundColor Cyan }
function err  { param($m) Write-Host "❌ $m" -ForegroundColor Red; exit 1 }

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     SETUP COMPLET — html5up-forty CI/CD Lab          ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ── Étape 1 : Vérification ─────────────────────────────────────────
Write-Host "── Étape 1 : Vérification des outils ──"
try { git --version | Out-Null; log "Git installé" } catch { err "Git non trouvé" }
try { docker info 2>$null | Out-Null; log "Docker actif" } catch { err "Docker non lancé" }

# ── Étape 2 : Clone ────────────────────────────────────────────────
Write-Host "`n── Étape 2 : Clone du fork GitHub ──"
if (Test-Path $REPO) {
  warn "Dossier $REPO existant — on travaille dedans"
  Set-Location $REPO
} else {
  info "Clonage de $GITHUB_URL ..."
  git clone $GITHUB_URL
  Set-Location $REPO
  log "Repo cloné"
}

# ── Étape 3 : Copie fichiers ───────────────────────────────────────
Write-Host "`n── Étape 3 : Mise en place des fichiers ──"
New-Item -ItemType Directory -Force -Path ".github/workflows","assets","images" | Out-Null

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
foreach ($f in @("Dockerfile","nginx.conf")) {
  $src = Join-Path $scriptDir $f
  if (Test-Path $src) { Copy-Item $src .; log "Copié : $f" }
  else { warn "$f non trouvé" }
}
$ciSrc = Join-Path $scriptDir ".github\workflows\ci.yaml"
if (Test-Path $ciSrc) {
  Copy-Item $ciSrc ".github\workflows\ci.yaml"
  log "Copié : .github/workflows/ci.yaml"
}

# ── Étape 4 : Build Docker ─────────────────────────────────────────
Write-Host "`n── Étape 4 : Build Docker local ──"
info "Construction de l'image ${IMAGE}:${TAG} ..."
docker build -t "${IMAGE}:${TAG}" .
log "Image construite"
docker image ls | Select-String $IMAGE

# ── Étape 5 : Test conteneur ───────────────────────────────────────
Write-Host "`n── Étape 5 : Lancement du conteneur ──"
$exists = docker ps -a --format "{{.Names}}" | Select-String "^ci-app$"
if ($exists) {
  docker stop ci-app 2>$null
  docker rm   ci-app 2>$null
  warn "Ancien conteneur supprimé"
}
docker run -d --name ci-app -p "${PORT}:80" "${IMAGE}:${TAG}"
Start-Sleep -Seconds 2
$running = docker ps | Select-String "ci-app"
if ($running) { log "Conteneur ci-app actif sur le port $PORT" }
else          { err "Conteneur non démarré — lancez : docker logs ci-app" }

# ── Étape 6 : Git commit + push ────────────────────────────────────
Write-Host "`n── Étape 6 : Git commit et push ──"
git add -A
$diff = git diff --cached --quiet
if ($LASTEXITCODE -eq 0) {
  warn "Aucun changement à committer"
} else {
  git commit -m "feat: ajout pipeline CI/CD Docker + Trivy + corrections workflow"
  log "Commit créé"
  git push origin main
  log "Push sur main effectué"
}

# ── Étape 7 : Branche trivy ────────────────────────────────────────
Write-Host "`n── Étape 7 : Branche trivy ──"
$branches = git branch -a
if ($branches -match "trivy") {
  git checkout trivy
  git merge main --no-edit
  git push origin trivy
  log "Branche trivy mise à jour"
} else {
  git checkout -b trivy
  git push origin trivy
  log "Branche trivy créée"
}
git checkout main

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║  ✅  TOUT EST EN PLACE !                             ║" -ForegroundColor Green
Write-Host "╠══════════════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║  Site local  : http://localhost:$PORT                  ║" -ForegroundColor Green
Write-Host "║  GitHub      : github.com/$GITHUB_USERNAME/$REPO       ║" -ForegroundColor Green
Write-Host "║  Branches    : main  +  trivy                        ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "Secrets à configurer sur GitHub > Settings > Secrets :"
Write-Host "  • DOCKERHUB_USERNAME"
Write-Host "  • DOCKERHUB_TOKEN"
Write-Host ""
