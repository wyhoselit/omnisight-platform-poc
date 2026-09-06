# Frontend Shell & UI Components

# Frontend Shell & UI Components

Vue 3 + Vuetify 3 application shell. Handle layout orchestration, theme state, routing, and observability integration.

## Core Architecture

App use dynamic layout injection in `App.vue`. Route meta field `layout` determine component.

```mermaid
graph TD
    A[App.vue] --> B{Route Meta}
    B -- layout["layout:"] 'auth' --> C[AuthLayout]
    B -- default --> D[DefaultLayout]
    D --> E[v-app-bar]
    D --> F[v-navigation-drawer]
    D --> G[v-main / router-view]
```

## Key Components

### App Shell (`App.vue`)
Root component. Switch between `DefaultLayout` and `AuthLayout` via `computed` property.

### Default Layout (`DefaultLayout.vue`)
Main UI wrapper. 
- **Navigation**: Responsive drawer. `temporary` on mobile, `v-side-navigation-drawer` on desktop.
- **Theme Toggle**: Trigger `themeStore.toggleTheme()`. Increment OTel counter `theme_toggle_count`.
- **Role Access**: Hide/show Admin links via `authStore.user.roles`.

### Theme Store (`src/stores/theme.ts`)
Pinia store manage `isDark` state.
- **Persistence**: Save to `localStorage`.
- **System Sync**: `initTheme` check `prefers-color-scheme`.
- **DOM Sync**: `applyTheme` set `data-theme` attribute on `html` element.

## Routing & Security (`src/router/index.ts`)

Vue Router handle navigation and guards.

- **Auth Guard**: `beforeEach` check `meta.requiresAuth`. Redirect to `/login` if no session.
- **Admin Guard**: Check `meta.requiresAdmin` and user roles. Redirect to `/` if unauthorized.
- **Metrics**: `afterEach` call `recordPageView` for OTel tracking.

## UI Configuration (`src/plugins/vuetify.ts`)

Vuetify 3 setup with custom color palettes.
- **Light Theme**: Primary `#1976D2`, Surface `#FFFFFF`.
- **Dark Theme**: Primary `#90CAF9`, Surface `#1E1E1E`.
- **Icons**: Material Design Icons (`@mdi/font`).

## Observability Integration

Initialized in `main.ts` before app mount.
- **Tracing**: `setupObservability` hook into document load and user interaction.
- **Interceptors**: `axiosInstrumentation` and `routerInstrumentation` track network and navigation spans.

## Deployment & Proxy (`nginx.conf`)

Nginx serve production build.
- **SPA Routing**: `try_files $uri $uri/ /index.html` handle client-side routes.
- **API Proxy**: Forward `/api/` to `http://backend:8000`.
- **Metrics**: `/nginx_status` enabled for internal network scraping.

## Testing

### E2E Flow (`cypress/e2e/criticalUserFlow.cy.ts`)
Test full RAG pipeline:
1. Login via `LoginForm`.
2. Navigate to `/documents`.
3. Upload PDF via `attachFile`.
4. Query RAG system in `/rag`.
5. Assert response visibility.

### Unit Tests
Vitest run in `happy-dom` environment. Config in `vitest.config.ts`.

## Development Commands

- `npm run dev`: Start Vite server on port 5173.
- `npm run build`: Generate production assets in `dist/`.
- `npm test`: Run Vitest suite.
- `npm run cypress:run`: Execute E2E tests headless.

→ skipped: complex component library, add when UI scale.
→ skipped: server-side rendering, add when SEO need.