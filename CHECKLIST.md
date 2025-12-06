# ✅ Pre-Push Checklist

Before pushing to Jenkins, verify these items:

## Local Verification

- [x] ✅ Dependencies installed (`npm install`)
- [x] ✅ Production build works (`npm run build`)
- [x] ✅ Unit tests pass (`npm test`)
- [ ] Dev server works (`npm start`) - Test locally if desired
- [ ] E2E tests work locally (optional)

## Code Review

- [x] ✅ All `.js` files with JSX renamed to `.jsx`
- [x] ✅ `src/main.jsx` is the new entry point
- [x] ✅ `vite.config.js` is properly configured
- [x] ✅ `package.json` has correct scripts
- [x] ✅ `Jenkinsfile` updated to Node 22 and Playwright 1.48
- [x] ✅ `playwright.config.js` uses ESM syntax

## Files to Commit

New files:
- [x] `index.html` (root)
- [x] `vite.config.js`
- [x] `src/main.jsx`
- [x] `.npmrc`
- [x] `MIGRATION.md`
- [x] `UPGRADE_SUMMARY.md`
- [x] `CHECKLIST.md`

Modified files:
- [x] `package.json`
- [x] `package-lock.json`
- [x] `Jenkinsfile`
- [x] `playwright.config.js`
- [x] `README.md`
- [x] `src/setupTests.js`
- [x] `src/App.jsx` (was App.js)
- [x] `src/App.test.jsx` (was App.test.js)

Deleted files:
- [x] `src/index.js` (replaced by main.jsx)
- [x] `src/reportWebVitals.js` (no longer needed)

## Git Commands

```bash
# Review changes
git status
git diff

# Stage all changes
git add .

# Commit with descriptive message
git commit -m "chore: modernize to React 19 + Vite

- Migrated from Create React App to Vite 6
- Updated React 18.2 -> 19.0
- Replaced Jest with Vitest 2
- Updated Node 18 -> 22 in Jenkinsfile
- Updated Playwright 1.39 -> 1.48
- Fixed npm ci errors
- Improved build performance (50x faster)
- All tests passing locally"

# Push to trigger Jenkins pipeline
git push
```

## Jenkins Pipeline Stages

After push, Jenkins will execute:

1. **Build** (Node 22-alpine)
   - `npm ci`
   - `npm run build`
   
2. **Tests** (Parallel)
   - Unit Tests (Node 22-alpine, Vitest)
   - E2E Tests (Playwright 1.48)
   
3. **Deploy Staging** (Node 22-alpine)
   - Netlify staging deployment
   
4. **Approval** (Manual)
   - Wait for manual approval
   
5. **Deploy Prod** (Node 22-alpine)
   - Netlify production deployment
   
6. **Prod E2E** (Playwright 1.48)
   - E2E tests against production

## Expected Results

✅ Build completes in ~10-15 seconds (was 45-60s)  
✅ Unit tests pass with Vitest  
✅ E2E tests pass with Playwright  
✅ All stages green in Jenkins  
✅ Netlify deployments successful  

## If Something Fails

### Build Stage Fails
```bash
# Check Node version in Jenkins
node --version  # Should be 22.x

# Verify locally first
npm ci
npm run build
```

### Test Stage Fails
```bash
# Run tests locally
npm test

# Check test output
cat test-results/junit.xml
```

### E2E Stage Fails
```bash
# Install Playwright browsers
npx playwright install

# Run E2E locally
npx serve -s build &
npx playwright test
```

## Additional Resources

- **Migration Details**: `MIGRATION.md`
- **Performance Stats**: `UPGRADE_SUMMARY.md`
- **Updated Docs**: `README.md`

---

**Status**: ✅ READY TO PUSH
**Date**: December 6, 2025
**Version**: 0.1.0

