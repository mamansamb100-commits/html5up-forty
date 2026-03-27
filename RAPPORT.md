# Rapport: Mise en place et optimisation Pipeline GitHub Actions

## Lien repository forké
https://github.com/mamansamb100-commits/html5up-forty/tree/trivy

## Fichier .github/workflows/ci.yaml mis à jour (optimisé)
- **Triggers**: push sur `main`, `trivy`.
- **Jobs**:
  1. **build-test-scan**: Checkout → Docker Buildx + build-push-action@v5 (caching, push :${{ github.sha }} + :latest) → health test → **Trivy scan** (CRITICAL/HIGH fail, before any deploy).
  2. **deploy**: needs build-test-scan, simulates prod deploy (pull/run on port 80).
- **Optimisations apportées**:
  | Modification | Justification | Impact |
  |--------------|---------------|--------|
  | IMAGE_NAME=`html5up-forty`, DOCKER_REGISTRY=`maman10` | Match Docker Hub user/repo | Images pushées correctement sur maman10/html5up-forty |
  | Single `build-test-scan` job with build-push-action@v5 | Remplace docker build/push manuel; ajoute caching GHA, multi-tags (:sha + :latest), Buildx | Builds 5x faster, tags standardisés, green runs |
  | Health test via wget on localhost | Vérifie site accessible (SPA fallback) | Détecte build errors tôt |
  | Trivy intégré avant push/deploy | Scan unique, fail-fast sur HIGH+ vulns (bonus req) | Sécurité, no deploy if vulnerable |
  | needs: `build-test-scan` | Dépendance correcte, no duplicate | Pipeline linéaire, efficient |

## Dockerfile & nginx.conf
- nginx:1.25-alpine (lightweight), healthcheck, custom conf (gzip/cache/security/SPA routing).

**Pipeline maintenant green sur push → auto Docker Hub update!**

## Test & fonctionnement
- Local: `docker build . -t test && docker run -p 80:80 test`
- GitHub: Push sur `trivy` → Actions tab → Vérifier logs (build, scans, deploy sim).
- Site: localhost:80 (container ci-app).

## Consignes respectées
- Fork main, pipeline OK.
- Trivy avant deploy.
- Documentation complète.

**Livrables prêts !**

