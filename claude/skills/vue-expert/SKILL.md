---
name: vue3-expert
description: Production-grade Vue 3 development with Composition API and `<script setup>`. Use whenever creating, refactoring, or reviewing Vue 3 components, composables, Pinia stores, Vue Router 4 setups, Nuxt 3/4 apps, or Vue component libraries. Targets Vue 3.5+ idioms and assumes TypeScript.
---

# Vue 3 Expert

A senior Vue 3 engineer's working checklist. Modern (Vue 3.5+), opinionated, framework-agnostic (SPA, Nuxt, library). Use this when writing any `.vue`, `.ts`, or `.js` file in a Vue 3 project.

---

## When to use this skill

Activate this skill when the task involves any of:

- Creating or editing `.vue` Single-File Components
- Writing or refactoring composables (`use*` functions)
- Pinia stores, Vue Router 4 routes, Nuxt pages/layouts/composables
- Reviewing Vue code for bugs, reactivity issues, or performance
- Migrating Options API → Composition API
- Setting up Vitest / Vue Test Utils tests for Vue code

Do **not** use this skill for Vue 2 / Options API legacy code (different reactivity model). Flag and recommend migration instead.

---

## Response behavior (for AI agents using this skill)

1. **Detect first.** Inspect `package.json` for Vue, Pinia, Vue Router, Nuxt, and Vue Test Utils versions before writing code. Adjust idioms accordingly (e.g. no `defineModel` below 3.4, no `useTemplateRef` below 3.5).
2. **Match existing style** unless the user explicitly asks for a migration or refactor. Don't rewrite Options API to Composition API as a side effect of an unrelated change.
3. **Prefer minimal safe diffs** over wholesale rewrites. Touch what the task requires.
4. **Explain reactivity or architectural issues briefly** when fixing them — one or two sentences, not an essay.
5. **Don't introduce new dependencies** (VueUse, Zod, Pinia plugins, etc.) without a stated reason.
6. **Preserve public APIs** of components, composables, and stores unless the task is explicitly a migration or breaking change.

---

## Non-negotiables (apply on every Vue file)

1. **Composition API + `<script setup lang="ts">` only** in new code. Never mix Options and Composition API in the same component.
2. **TypeScript by default.** Type props, emits, refs, route meta, store state. Avoid `any`; use `unknown` + narrow.
3. **Props are read-only.** Never mutate a prop. Use a local `ref` seeded from the prop, then emit changes upward (`update:*` events / `defineModel`).
4. **One-way data flow.** Props down, events up. Reach for `provide/inject` or Pinia only when prop drilling crosses 3+ levels.
5. **Reactivity is sacred.** Don't destructure `reactive()` or Pinia stores without `toRefs` / `storeToRefs`. (Vue 3.5+ reactive *props* destructure is the explicit exception — see below.)
6. **Cleanup side effects.** Every `addEventListener`, `setInterval`, subscription, or observer registered in a component or composable must be torn down in `onUnmounted` / `onScopeDispose`.
7. **Multi-word component names in application code.** Single-word names like `Card` or `Item` collide with current/future HTML elements. Exception: root `App` and conventional UI primitives such as `BaseButton`, `AppHeader`, `VInput` (the prefix makes them multi-word).
8. **Prefer `<style scoped>` for component-local styling.** Use global styles intentionally — for design tokens, resets, typography, theme layers, and app-wide utilities. Inside scoped blocks, prefer class selectors over element selectors.

---

## SFC structure

Order tags consistently: `<script setup>` first, `<template>` second, `<style scoped>` last.

Inside `<script setup lang="ts">`, follow this order top to bottom:

1. `import`s (Vue → 3rd party → app aliases → relative → types)
2. `defineOptions` / `defineProps` / `defineEmits` / `defineModel` / `defineSlots`
3. Composables (`useRoute`, `useRouter`, `useI18n`, Pinia stores, custom `use*`)
4. Local reactive state (`ref`, `shallowRef`, `reactive`)
5. `computed`
6. `watch` / `watchEffect`
7. Lifecycle hooks (`onMounted`, `onUnmounted`, …)
8. Functions / event handlers
9. `defineExpose` (if needed — keep components closed by default)

Keep components small (≤ ~200 lines of `<script setup>`). Split when a component does more than one thing.

---

## Reactivity rules

### `ref` vs `reactive` — opinionated default: prefer `ref`

This is a working default, not framework law. Both are valid; pick consistently.

- **`ref()`** for everything by default: primitives, objects, arrays, DOM elements, async data. Survives reassignment, narrows cleanly, and destructuring an object of refs keeps reactivity.
- **`reactive()`** when fields form a tightly-coupled object model that always lives together (e.g. a form state object). Never for primitives — it silently fails and Vue emits a warning.
- **Never** `const state = reactive({...}); state = newState` — reassignment breaks the proxy. Use `Object.assign(state, newState)` or a `ref`.
- **`shallowRef`** for large immutable payloads (API responses, charts, editor instances). Triggers updates only when `.value` is reassigned, not on deep mutations.
- **`markRaw()`** for class instances and 3rd-party objects (Chart.js, Leaflet maps, Vue components stored as data) you never want to proxy.

### Destructuring pitfalls

Don't destructure reactive state unless you use `toRefs()` / `storeToRefs()`. Vue 3.5's reactive **props** destructure is a valid, supported exception — props remain reactive when destructured directly from `defineProps`.

```ts
// ❌ Loses reactivity
const { count } = reactive({ count: 0 })
const { user } = store              // Pinia

// ✅ Keeps reactivity
const state = reactive({ count: 0 })
const { count } = toRefs(state)            // for reactive objects
const { user } = storeToRefs(userStore)    // for Pinia stores

// ✅ Vue 3.5+ — reactive props destructure is supported
const { foo = 'default' } = defineProps<{ foo?: string }>()
```

Pinia stores are wrapped in `reactive`, so direct destructuring breaks reactivity for state/getters. Use `storeToRefs()` to extract state and getters as refs; **destructure actions directly** — they are bound to the store.

### `computed` vs `watch` vs `watchEffect`

- **`computed`** for derived values. Cached, side-effect-free, runs on demand. **First choice.**
- **`watch(source, cb)`** when you need the previous value, async work, or explicit control (`{ immediate, deep, flush: 'post' }`).
- **`watchEffect`** when dependencies are implicit and you don't need the old value. Avoid for anything non-trivial — explicit `watch` is easier to read and debug.
- **Never** mutate the watched source inside its own watcher. **Never** put business logic in a `computed` — keep them pure.
- Use Vue 3.5's `onWatcherCleanup()` inside watchers to cancel pending requests/timers (see Async & cancellation below).

### Watching props correctly

```ts
const props = defineProps<{ id: string }>()

// ❌ Not reactive — passes a string at call-time
watch(props.id, fn)

// ✅
watch(() => props.id, fn)
```

---

## Props, emits, v-model

### Typed `defineProps` / `defineEmits`

Prefer the **type-based** form. Use reactive props destructuring (Vue 3.5+) for default values:

```ts
const { count = 0, label = 'Items' } = defineProps<{
  count?: number
  label?: string
}>()

const emit = defineEmits<{
  submit: [payload: FormData]
  'update:modelValue': [value: string]
}>()
```

Rules:
- Boolean props default to `false`.
- Required props are required — don't ship "optional with default" when the parent must always pass it.
- Event names are `kebab-case` in templates, `camelCase` in `defineEmits`.
- Validate complex props with a runtime check or Zod when they cross a trust boundary (API, plugin).

### `v-model` — use `defineModel` (Vue 3.4+)

`defineModel` graduated to stable in Vue 3.4 and replaces the old `props + emit('update:modelValue')` boilerplate entirely.

```ts
// Child.vue
const model = defineModel<string>({ required: true })
const count = defineModel<number>('count', { default: 0 })
```

```vue
<!-- Parent -->
<Child v-model="text" v-model:count="qty" />
```

Use multiple `defineModel` calls for multi-`v-model` components.

---

## Composables

Composables are the primary code-reuse primitive. Use them in preference to mixins (never), renderless components (rarely), or duplicated logic (never).

### Conventions

- **Naming:** filename `useThing.ts`, exported function `useThing()`. PascalCase types: `UseThingReturn`.
- **Location:** `src/composables/` (Nuxt: `app/composables/` — auto-imported, top-level only).
- **Return an object of refs/computeds** — consumers destructure without losing reactivity (refs survive destructuring).
- **Single responsibility.** A composable that fetches *and* validates *and* formats is three composables.
- **Accept `MaybeRefOrGetter<T>`** for inputs that may be reactive; normalize with `toValue()`:

```ts
import { type MaybeRefOrGetter, toValue, ref, watchEffect } from 'vue'

export function useDoubled(input: MaybeRefOrGetter<number>) {
  const result = ref(0)
  watchEffect(() => { result.value = toValue(input) * 2 })
  return { result }
}
```

- **Clean up.** Register listeners with `onMounted` + `onUnmounted`, or use `onScopeDispose` so the composable also works inside an `effectScope`.
- **UI side effects in composables:** avoid hard-coupling generic, low-level composables (data fetching, storage, observers) to toasts, alerts, navigation, or modals. **Feature-level composables may coordinate** navigation, notifications, or modal behavior when that orchestration *is* their explicit responsibility (e.g. `useCheckoutFlow`, `useAuthGuard`). Keep that coupling deliberate, not accidental.

### Composables vs Pinia stores

| Use a **composable** when | Use a **Pinia store** when |
|---|---|
| Logic is per-component-instance (each call = fresh state) | State must be shared globally across components |
| You need a small reusable behavior (debounce, fetch, form helper) | You need devtools time-travel, persistence, or HMR-safe singletons |
| No global identity needed | The data has app-wide identity (current user, cart, theme) |

A composable can wrap a Pinia store; the reverse is also fine inside setup stores.

### When to reach for VueUse

**Prefer VueUse for well-known browser abstractions and utilities** rather than reimplementing them. Good fits:

- **Storage** — `useStorage`, `useLocalStorage`, `useSessionStorage`
- **Observers** — `useIntersectionObserver`, `useResizeObserver`, `useMutationObserver`
- **Media & sensors** — `useMediaQuery`, `usePreferredDark`, `useGeolocation`, `useDeviceOrientation`
- **Timing** — `useDebounceFn`, `useThrottleFn`, `useTimeoutFn`, `useInterval`
- **DOM** — `useEventListener`, `onClickOutside`, `useFocus`

Don't reach for VueUse for trivial one-liners or for app-specific business logic — write it yourself. VueUse is a library, not a default import.

---

## Pinia (state management)

- **Pinia is the official store.** Vuex is in maintenance mode; do not propose it for new code.
- **Prefer setup stores** over option stores. They let you use composables, `watch`, `inject`, and other Vue APIs directly inside the store, and they feel identical to `<script setup>`.

```ts
// stores/cart.ts
export const useCartStore = defineStore('cart', () => {
  const items = ref<CartItem[]>([])
  const total = computed(() => items.value.reduce((s, i) => s + i.price, 0))

  function add(item: CartItem) { items.value.push(item) }
  function clear() { items.value = [] }

  return { items, total, add, clear }
})
```

Rules:
- **Return everything** you want exposed. Anything not returned doesn't exist for Pinia (no private state in setup stores — encapsulate inside a separate composable if you need privacy).
- **Use `storeToRefs(store)`** when destructuring state/getters in a component. Destructure actions directly.
- **One store per concern**, one file per store. Stores can import other stores.
- **Persistence:** use `pinia-plugin-persistedstate` rather than custom localStorage glue.
- **SSR / Nuxt:** use `skipHydrate()` on state properties that must initialize on the client only (e.g. `useLocalStorage` wrappers).

---

## Templates

- **`v-for` requires `:key`** with a stable, unique value (an `id`, not the index — unless the list is truly static).
- **Never combine `v-if` and `v-for`** on the same element. `v-if` wins precedence and breaks the variable scope. Wrap in `<template v-if>` outside `v-for`, or filter via `computed`.
- **Prefer `<template v-for>` / `<template v-if>`** to avoid wrapper `<div>`s.
- Self-close components: `<MyThing />` not `<MyThing></MyThing>`.
- Use **PascalCase** for components in templates (`<UserCard />`), kebab-case only in in-DOM templates.
- **Avoid complex expressions in templates.** Move to a `computed`.
- Inline event handlers are fine for one-liners; extract anything multi-statement into a `function`.
- Use `v-memo="[dep1, dep2]"` only after profiling — it skips re-renders when deps are unchanged. Useful on huge `v-for` lists of expensive items.
- Use event modifiers: `@submit.prevent`, `@click.stop`, `@keydown.enter`, `@click.self`. Don't `event.preventDefault()` manually in inline handlers.

---

## TypeScript integration

- Enable `"strict": true` in `tsconfig.json`. Add `"vueCompilerOptions": { "target": 3.5 }` for Vue Language Tools.
- Use **generic components** when needed:

```vue
<script setup lang="ts" generic="T extends { id: string | number }">
const props = defineProps<{ items: T[] }>()
defineEmits<{ select: [item: T] }>()
</script>
```

- **Template refs** in Vue 3.5+: use `useTemplateRef()`:

```ts
const inputRef = useTemplateRef<HTMLInputElement>('input')
onMounted(() => inputRef.value?.focus())
```

Old style (`const inputRef = ref<HTMLInputElement | null>(null)` matched by `ref="inputRef"`) still works but is being phased out.

- For component refs, type as `InstanceType<typeof Child>` or use `ComponentExposed`.
- Don't sprinkle `as unknown as X` to silence Volar. If you need it, your model is wrong — usually a missing `unref()` or a wrong ref type.

---

## Vue 3.4 / 3.5 features to use

| Feature | Version | Use it for |
|---|---|---|
| `defineModel()` | 3.4 stable | All custom `v-model` components |
| Same-name shorthand `:title` ≡ `:title="title"` | 3.4 | Concise binding |
| Reactive props destructuring | 3.5 stable | Default values + clean signatures |
| `useTemplateRef()` | 3.5 | All new template ref code |
| `useId()` | 3.5 | SSR-safe unique IDs for ARIA (`aria-describedby`, label-input pairs) |
| `onWatcherCleanup()` | 3.5 | Cancel in-flight fetches inside watchers |
| Deferred `<Teleport defer>` | 3.5 | Teleport to a target that mounts later in the same render |
| Lazy hydration via `defineAsyncComponent({ hydrate: hydrateOnVisible() })` | 3.5 | Nuxt islands / heavy below-the-fold components |

---

## Async & cancellation

Stale async work is one of the top sources of Vue bugs: a fetch fires, the input changes, the *first* fetch resolves *second*, and old data overwrites new. Cancel aggressively.

- Inside `watch` / `watchEffect`, register cleanup with `onWatcherCleanup()` (Vue 3.5+) or the watcher's `onCleanup` callback (pre-3.5). It runs before the next invocation and on scope dispose.
- Always pair `fetch` with `AbortController` when the request is tied to a reactive source.
- Track an "in-flight token" or check `signal.aborted` after `await` boundaries before mutating state.
- Inside event handlers, store the controller in a `ref` so the *next* invocation can abort the previous one.

```ts
import { ref, watch, onWatcherCleanup } from 'vue'

const query = ref('')
const results = ref<Item[]>([])

watch(query, async (q) => {
  if (!q) { results.value = []; return }
  const controller = new AbortController()
  onWatcherCleanup(() => controller.abort())

  try {
    const res = await fetch(`/api/search?q=${encodeURIComponent(q)}`, {
      signal: controller.signal,
    })
    results.value = await res.json()
  } catch (err) {
    if ((err as Error).name !== 'AbortError') throw err
  }
})
```

For per-event aborts (typing, button mashing), keep the controller in a ref and abort on next call:

```ts
const inFlight = ref<AbortController>()
async function submit() {
  inFlight.value?.abort()
  inFlight.value = new AbortController()
  await fetch('/api/x', { signal: inFlight.value.signal })
}
```

---

## Error handling

- **Never swallow errors silently.** A bare `catch {}` or `.catch(() => {})` is a bug unless paired with a comment explaining why.
- **Surface recoverable errors via reactive state** — an `error` ref next to `data` and `pending`. Let the template render the failure; don't `alert()` from a composable.
- **Normalize errors at the boundary layer.** Wrap your HTTP client so callers receive a typed `ApiError` (status, code, message) instead of raw `Response` or `AxiosError`. Components shouldn't need to know about transport details.
- **Throw only when ownership belongs to the caller.** Inside a composable returning `{ data, error }`, set `error.value` and return. Throw only from utilities whose contract is "succeed or throw" (parsers, validators, guards).
- **Use `onErrorCaptured`** in feature-root components to log/report; pair with an app-level `app.config.errorHandler` for global reporting (Sentry, etc.).
- **Async lifecycle hooks need try/catch.** Unhandled promise rejections inside `onMounted` won't be caught by `onErrorCaptured`.
- Distinguish **expected** errors (validation, 404, auth) — render UI — from **unexpected** errors (network down, bug) — log and show a generic fallback.

---

## Performance

Optimize **after** measuring.

### Cheap wins, apply by default
- `shallowRef` for large arrays/objects that you replace whole, not mutate field-by-field.
- `markRaw` for non-reactive class instances stored in reactive state (chart instances, map objects, Vue components passed as data).
- Lazy-load route components: `component: () => import('./Foo.vue')`.
- `defineAsyncComponent` for heavy components below the fold (with `<Suspense>` for fallback).
- Use `:key` correctly on `v-for`. A stable key is a perf optimization, not just a warning fix.
- Tree-shake imports — never `import * as _ from 'lodash'`; import individual functions.

### Reach for when needed
- `v-memo` on long lists with infrequent changes.
- Virtual scrolling (VueUse `useVirtualList` or `vue-virtual-scroller`) for lists > a few hundred items.
- `<KeepAlive>` for expensive tabs/routes that should preserve state.

---

## SSR & hydration pitfalls

Apply whenever the app runs through Nuxt, `vite-ssr`, or any SSG/SSR setup.

- **Never access browser APIs during render.** `window`, `document`, `localStorage`, `navigator`, `IntersectionObserver`, `matchMedia`, animation libraries — none of them exist during SSR.
- **Guard browser-only code** with `onMounted` (runs only on the client), `import.meta.client` / `import.meta.server`, or wrap the markup in `<ClientOnly>`.
- **Avoid non-deterministic values** during render: `Math.random()`, `Date.now()`, `new Date()`, `crypto.randomUUID()`. They produce different output on server vs. client → hydration mismatch. Use `useId()` for stable IDs; compute timestamps in `onMounted` or pass them in as props from the server payload.
- **Locale & timezone drift.** `toLocaleString()` and `Intl.DateTimeFormat()` can format differently on server vs. browser. Pin the locale and timezone explicitly, or render the formatted string only on the client.
- **`useState` (Nuxt) for SSR-shared state**; plain `ref` declared at module scope leaks across requests on the server.
- **`skipHydrate()`** on Pinia state hydrated from browser-only sources (localStorage, IndexedDB).
- **Check the hydration mismatch warning seriously.** It's almost always a real bug, not noise.

---

## Vue Router 4

- Use `createRouter({ history: createWebHistory() })`. Hash mode only for static hosts without rewrites.
- Define routes with `meta` for auth / titles / layouts. Type `meta` via `declare module 'vue-router'` augmentation.
- **Use the return-based syntax** in navigation guards — the legacy `next()` callback is the largest source of "double-call" / "never-called" bugs:

```ts
router.beforeEach(async (to) => {
  if (to.meta.requiresAuth && !auth.isAuthenticated) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }
})
```

- Watch route params with `onBeforeRouteUpdate` or `watch(() => route.params.id, …)` — visiting `/users/1` → `/users/2` does **not** remount the component.
- Lazy-load every route component.
- Programmatic navigation: `useRouter()`. Read current route: `useRoute()`. Never store `route` in a Pinia state — re-read it from the store function.

---

## Forms

- **Keep validation separate from rendering.** Validation rules live next to the schema/model, not embedded in template `v-if`s. Components only display errors.
- **Prefer schema-driven validation** with Zod, Valibot, or VeeValidate + a schema. The schema is the source of truth for types *and* runtime validation.
- **Avoid duplicated derived validation state.** Compute `isValid`, field errors, and `canSubmit` from one source — don't maintain parallel booleans that drift.
- **Disable submit during pending mutations.** Bind `:disabled="pending || !isValid"`; reset `pending` in `finally`.
- **`defineModel`** is the cleanest binding for custom inputs. For native inputs, plain `v-model` is fine.
- **Reset and dirty state matter** for UX: track `isDirty` per field, expose `reset()` from form composables.
- **Server errors map to fields.** When the API returns a field-level validation error, surface it next to the input, not as a global toast.

---

## Nuxt 3/4 specifics (when applicable)

- Auto-imports are real. **Do not** manually import `ref`, `computed`, `useRoute`, `useFetch`, etc., in Nuxt code. Trust the IDE; if it errors, run `nuxt prepare`.
- Nuxt 4 source structure: `app/components/`, `app/composables/`, `app/utils/`, `app/pages/`, `app/layouts/`, `app/middleware/`, `server/api/`, `server/utils/`, `shared/`. Composables and utils are auto-imported only from the top level — re-export from `index.ts` if nested.
- **Data fetching:** `useFetch` / `useAsyncData` for SSR-hydrated reads, `$fetch` inside event handlers / mutations, `useState` for SSR-safe shared state. Always pass an explicit `key` to avoid hydration collisions when the same endpoint is called from multiple files.
- Use `useHead` / `useSeoMeta` (auto-imported) for `<head>` and SEO.
- `<ClientOnly>` for browser-only code; `import.meta.client` / `import.meta.server` for conditional logic.

---

## Testing (Vitest + Vue Test Utils)

- **Vitest** is the default test runner — it shares Vite config and is dramatically faster than Jest. Use Jest only when migrating a legacy suite.
- **`@vue/test-utils`** for component mounting; **`@testing-library/vue`** if you prefer user-centric queries.
- Test **behavior, not implementation**. Assert what the user sees and what the component emits, not internal `data` or method calls.
- Mock the network with **MSW**, not by stubbing `fetch` ad-hoc.
- Composables that use lifecycle hooks must be tested inside a temporary host component:

```ts
function withSetup<T>(composable: () => T): [T, App] {
  let result!: T
  const app = createApp({
    setup() { result = composable(); return () => null }
  })
  app.mount(document.createElement('div'))
  return [result, app]
}
```

- Don't snapshot-test entire components — they break on cosmetic changes. Snapshot small, stable subtrees if at all.
- For UI components, **Vitest browser mode** runs tests in real Chromium/Firefox/WebKit via Playwright and supports visual regression via `toMatchScreenshot()`.

---

## Anti-patterns — never do these

- **Mutating props.** `props.user.name = 'X'`. Always emit, or `defineModel`.
- **`reactive(0)` / `reactive('hello')`.** Reactive only wraps objects; primitives must use `ref`.
- **Destructuring reactive/store values without `toRefs`/`storeToRefs`.** Silently loses reactivity. (Vue 3.5+ props destructure is the only built-in exception.)
- **Reassigning a `reactive()` constant.** `state = newObj` breaks the proxy.
- **`watch` where `computed` would do.** If you're setting `state.foo = derive(state.bar)` inside a watcher, that's a `computed`.
- **Side effects inside `computed`.** Mutations, API calls, navigation — none of these belong in a getter.
- **Business logic in templates.** Computed properties exist for this.
- **`v-html` with user input.** XSS. Sanitize first, or use a parser.
- **`v-if` + `v-for` on the same element.**
- **Prop drilling 3+ levels.** Use `provide/inject` or a Pinia store.
- **Generic single-word component names** (`Card`, `Item`, `Button`) in app code — collide with HTML and other libraries. Prefix UI primitives (`BaseCard`, `AppItem`, `VButton`).
- **Importing the whole component library** (`import * as Big from 'big-lib'`). Use named imports / tree-shakeable paths.
- **Forgetting to remove listeners** added in `onMounted`. Memory leaks and stale callbacks.
- **Hand-rolling debounce, throttle, click-outside, intersection observer** when VueUse already covers it correctly and SSR-safe.
- **`any` in props/emits/store state.** It pollutes the entire component tree's inference.
- **One giant `App.vue` / one giant store.** Split by feature, not by type.
- **Using the deprecated `next()` callback in router guards.** Use the return-value syntax.
- **Swallowing errors.** A `catch` that doesn't log, report, or surface state is a bug.

---

## Naming conventions

| Thing | Convention | Example |
|---|---|---|
| Component file | PascalCase | `UserProfileCard.vue` |
| Base/UI primitives | `Base`/`App`/`V` prefix | `BaseButton.vue`, `AppHeader.vue` |
| Tightly-coupled children | Parent-prefixed | `TodoList.vue`, `TodoListItem.vue` |
| Component in template (SFC) | PascalCase | `<UserProfileCard />` |
| Component in in-DOM template | kebab-case | `<user-profile-card>` |
| Composable file & export | camelCase, `use*` | `useFeatureFlag.ts` → `useFeatureFlag()` |
| Pinia store | camelCase, `use*Store` | `useCartStore` |
| Props/emits in script | camelCase | `firstName`, `update:modelValue` |
| Props/emits in template | kebab-case | `:first-name`, `@update:model-value` |
| Event handlers | `handle*` or inline verb | `handleSubmit`, `onClick="$emit('close')"` |
| Constants/enums | `SCREAMING_SNAKE` / PascalCase enum | `MAX_ITEMS`, `OrderStatus.Paid` |

---

## File structure

Small/medium SPA:

```
src/
  assets/
  components/         # generic + feature-agnostic UI
  composables/        # use* hooks
  stores/             # Pinia stores
  views/ or pages/    # route components
  router/
  api/                # HTTP client + endpoint wrappers
  utils/              # pure functions, no Vue APIs
  types/              # cross-cutting TS types
  App.vue
  main.ts
```

Large app: switch to **feature-first**:

```
src/
  features/
    auth/
      components/
      composables/
      stores/
      api.ts
      routes.ts
      types.ts
      index.ts        # public surface
  shared/             # cross-feature
  app/                # bootstrapping
```

Nuxt 4: stick to its `app/` + `server/` + `shared/` conventions; don't reinvent.

---

## Accessibility & SEO baseline

- Always pair `<label for>` with input `id`. Generate IDs with `useId()` (3.5+).
- `<img>` needs `alt`. Decorative images: `alt=""`.
- Buttons are `<button type="button">` unless they submit a form. Don't `@click` on a `<div>`.
- Keyboard: any `@click` interactive non-button must also handle `@keydown.enter` / `@keydown.space`, have `tabindex="0"`, and an appropriate `role`.
- Manage focus on route changes (focus `<h1>` or main landmark) and on modal open/close.
- For SPAs, set `document.title` via the router `afterEach` or use `@vueuse/head` / Nuxt `useHead`.
- For SSR/SEO, use Nuxt or `vite-ssr` — client-only SPAs lose meta-tag indexing on many crawlers.

---

## Working with existing codebases

- **Detect first, then act.** Inspect `package.json` for Vue version, Pinia vs Vuex, Nuxt version, Vue Test Utils version. Match the existing style if it's reasonable; propose migration only when asked or when fixing a related bug.
- If you find Options API, do not rewrite to Composition API as a side quest. Match the file's style and leave a TODO.
- If you find Vuex, do not propose Pinia migration mid-task. Note it once and continue.
- If `vue-tsc` is present, run it after edits: `vue-tsc --noEmit`. Treat errors as failures.
- If ESLint with `eslint-plugin-vue` is configured, respect its rules — they encode many of the conventions above.

---

## Pre-commit checklist

- [ ] No Options API in new code; `<script setup lang="ts">` used
- [ ] Props typed via `defineProps<T>()`; emits typed via `defineEmits<T>()`
- [ ] No prop mutation; `defineModel` used for v-model
- [ ] `ref` for primitives; `reactive` only for grouped object state
- [ ] Destructuring uses `toRefs` / `storeToRefs` where needed (or Vue 3.5 reactive props destructure)
- [ ] `computed` used for derived values; `watch` only when prev value / async needed
- [ ] Async work cancels stale requests (`AbortController` + `onWatcherCleanup`)
- [ ] Errors surfaced via reactive state; no silent `catch`
- [ ] Browser APIs guarded for SSR (`onMounted` / `import.meta.client` / `<ClientOnly>`)
- [ ] Every listener / subscription / timer is cleaned up
- [ ] `v-for` has a stable `:key`; no `v-if` on the same element
- [ ] Components are multi-word, PascalCase, scoped styles
- [ ] Router guards use return-value syntax, not `next()`
- [ ] No `any`; `vue-tsc --noEmit` passes
- [ ] Tests added/updated for changed behavior
- [ ] No `console.log` / commented-out code left behind
