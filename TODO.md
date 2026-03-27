# GitHub Actions Pipeline Fix & Trivy - TODO

## Status: [IN PROGRESS] 

### 1. [DONE] Create 'trivy' branch ✅
   - `git checkout -b trivy` executed

### 2. [DONE] Update .github/workflows/ci.yaml ✅
   - IMAGE_NAME: html5up-forty, DOCKER_REGISTRY: maman10
   - Renamed job build-test-scan (build-push-action@v5 caching, :latest tag, health test, Trivy)
   - Removed duplicate scan-trivy, fixed needs:build-test-scan

### 3. [DONE] Update RAPPORT.md ✅
   - Added detailed optimizations table with justifications

### 4. [DONE] Local test ✅
   - Docker build & healthcheck passed

### 5. [PENDING] Commit & push

### 5. [PENDING] User sets GH secrets & tests

### 6. [PENDING] Verify

*Updated after Step 1.*


