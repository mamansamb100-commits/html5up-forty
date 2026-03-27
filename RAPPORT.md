# Rapport: Mise en place et optimisation Pipeline GitHub Actions

## Lien repository forké
https://github.com/mamansamb100-commits/html5up-forty/tree/trivy

## Fichier .github/workflows/ci.yaml mis à jour
- **Triggers**: push sur `main`, `trivy`.
- **Jobs**:
  1. **ci**: Checkout, Docker login/build/push (`ci-html:${{ github.sha }}`), Trivy scan.
  2. **scan-trivy** (bonus): Scan sécurité image avant deploy (fail si CRITICAL/HIGH).
  3. **deploy**: needs [ci, scan-trivy], pull/run container sur port 80.
- **Optimisations**:
  | Modification | Justification | Impact |
  |--------------|---------------|--------|
  | Tag dynamique `${{ github.sha }}` | Évite hardcode | Toujours latest unique image. |
  | Trivy fixé + job séparé | Scan bonne image, avant deploy | Sécurité renforcée. |
  | `ubuntu-latest` | Remplace `aws-runner` invalide | Pipeline s'exécute. |
  | `docker/login-action@v3` | Best practice | Sécurisé. |

## Dockerfile amélioré
- nginx:1.25-alpine, labels, healthcheck, nginx.conf custom.

## Test & fonctionnement
- Local: `docker build . -t test && docker run -p 80:80 test`
- GitHub: Push sur `trivy` → Actions tab → Vérifier logs (build, scans, deploy sim).
- Site: localhost:80 (container ci-app).

## Consignes respectées
- Fork main, pipeline OK.
- Trivy avant deploy.
- Documentation complète.

**Livrables prêts !**

