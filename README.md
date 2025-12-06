# Learn Jenkins App

A modern React application with Jenkins CI/CD pipeline integration. This project has been migrated from Create React App to **Vite** for better performance and modern tooling.

## 🚀 Technology Stack

- **React 19** - Latest React version
- **Vite 6** - Next-generation frontend build tool
- **Vitest 2** - Modern unit testing framework
- **Playwright 1.48** - End-to-end testing
- **Node.js 22** - Latest LTS version
- **Jenkins** - CI/CD automation

## 📦 Installation

```bash
# Remove old dependencies
rm -rf node_modules package-lock.json

# Install fresh dependencies
npm install
```

## 🛠️ Available Scripts

### `npm start` or `npm run dev`

Runs the app in development mode with hot module replacement (HMR).  
Open [http://localhost:3000](http://localhost:3000) to view it in your browser.

The page will automatically reload when you make changes. Vite's HMR is significantly faster than Create React App!

### `npm test`

Launches Vitest test runner in run mode (runs once).

### `npm run test:watch`

Launches Vitest in watch mode for interactive testing during development.

### `npm run test:ui`

Opens Vitest UI for a visual testing experience.

### `npm run build`

Builds the app for production to the `build` folder.  
Optimizes the build for the best performance with code splitting and minification.

The build is minified and the filenames include content hashes for optimal caching.

### `npm run preview`

Preview the production build locally before deploying.

## 🔄 Migration from Create React App

This project was migrated from Create React App to Vite. Key changes:

1. **Build Tool**: Webpack → Vite (10x faster builds!)
2. **Testing**: Jest → Vitest (faster, ESM-first)
3. **Entry Point**: `src/index.js` → `src/main.jsx`
4. **Config**: `react-scripts` → `vite.config.js`
5. **React Version**: 18.2 → 19.0

## 🧪 Testing

### Unit Tests
Unit tests use **Vitest** with React Testing Library:
- Located in `src/**/*.test.js`
- Output: `test-results/junit.xml` for Jenkins

### E2E Tests
End-to-end tests use **Playwright**:
- Located in `e2e/**/*.spec.js`
- Runs against Chromium by default
- HTML reports generated in `playwright-report/`

## 🏗️ Jenkins Pipeline

The `Jenkinsfile` defines a complete CI/CD pipeline:

1. **Build** - Install dependencies and build the app
2. **Tests** - Run unit and E2E tests in parallel
3. **Deploy Staging** - Deploy to Netlify staging
4. **Approval** - Manual approval gate
5. **Deploy Prod** - Deploy to production
6. **Prod E2E** - Run E2E tests against production

All stages use the latest Docker images:
- **Node.js**: `node:22-alpine`
- **Playwright**: `mcr.microsoft.com/playwright:v1.48.2-jammy`

## 📚 Learn More

- [Vite Documentation](https://vite.dev/)
- [React Documentation](https://react.dev/)
- [Vitest Documentation](https://vitest.dev/)
- [Playwright Documentation](https://playwright.dev/)

## 🐛 Troubleshooting

If you encounter issues after migration:

1. Delete `node_modules` and `package-lock.json`
2. Run `npm install` to get fresh dependencies
3. Clear browser cache
4. Check that you're using Node.js 22 or later
