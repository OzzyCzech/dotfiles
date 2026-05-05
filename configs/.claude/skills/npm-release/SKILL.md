---
name: npm-release
description: Guide for setting up automated npm package releases via GitHub Actions using Trusted Publishing (OIDC). Use when creating release workflows, publishing to npm, or troubleshooting CI/CD publish failures.
---

# npm Release via GitHub Actions (Trusted Publishing)

**Trusted Publishing** je doporučená metoda od července 2025. Místo dlouhodobých tokenů používá OIDC — GitHub Actions automaticky prokáže svoji identitu npm registru bez secret tokenů.

## Postup — nejdřív prozkoumej projekt

Před vytvořením nebo úpravou jakéhokoli souboru proveď tyto kroky:

1. **Přečti `package.json`** — zjisti název balíčku, přítomnost `scripts.test`, `scripts.build`, `repository` pole a `devDependencies`.
2. **Zkontroluj `.github/workflows/`** — jaké workflow soubory již existují a co dělají. Uprav stávající místo vytváření nových.
3. **Zkontroluj lock soubor** — určuje package manager.

Na základě toho rozhoduj, co je skutečně potřeba:

| Podmínka | Akce |
|---|---|
| `publish.yml` neexistuje | Vytvoř ho |
| `publish.yml` existuje | Uprav jen to, co je špatně |
| `scripts.test` chybí v `package.json` | Nepřidávej `npm test` ani CI workflow |
| `scripts.build` chybí v `package.json` | Nepřidávej `npm run build` |
| Žádné build ani test kroky | Vynech `npm ci` |
| CI workflow (`main.yml`) neexistuje a projekt nemá testy | Nevytvářej ho |

## Detekce package manageru

| Lock soubor | Install příkaz | cache hodnota |
|---|---|---|
| `package-lock.json` | `npm ci` | `npm` |
| `yarn.lock` | `yarn install --frozen-lockfile` | `yarn` |
| `pnpm-lock.yaml` | `pnpm install --frozen-lockfile` | `pnpm` |
| `bun.lock` | `bun install --frozen-lockfile` | `bun` |

`npm publish` ponech vždy bez ohledu na package manager — je to příkaz pro publikaci, nikoliv správu závislostí.

## `.github/workflows/publish.yml`

Název souboru **musí přesně odpovídat** tomu, co nastavíš na npmjs.com v sekci Trusted Publisher.

Minimální podoba (bez testů a buildu):

```yaml
name: Publish to npm & Create Release

on:
  push:
    tags:
      - "v*.*.*"
  workflow_dispatch:

permissions: {}

jobs:
  publish:
    runs-on: ubuntu-latest
    permissions:
      contents: write      # pro vytvoření GitHub Release
      id-token: write      # POVINNÉ pro OIDC trusted publishing
    steps:
      - uses: actions/checkout@v6

      - uses: actions/setup-node@v6
        with:
          node-version: "24"
          registry-url: "https://registry.npmjs.org"   # POVINNÉ i když je default

      - name: Publish to npm
        run: npm publish --provenance --access public

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          generate_release_notes: true
```

Pokud projekt **má** testy nebo build, přidej `cache` do `setup-node` a kroky před publish (příkazy podle package manageru z tabulky výše):

```yaml
      - uses: actions/setup-node@v6
        with:
          node-version: "24"
          registry-url: "https://registry.npmjs.org"
          cache: npm   # nahraď podle package manageru

      - run: npm ci
      - run: npm run build
      - run: npm test
```

**Klíčové detaily:**
- **`id-token: write`** — nejdůležitější řádek. Bez něj GitHub Actions nevygeneruje OIDC token.
- **`registry-url`** v `setup-node` — povinné, i když je `registry.npmjs.org` default. Bez explicitního nastavení action nevytvoří `.npmrc` soubor nutný pro autentizaci.
- **Node 24** — obsahuje npm ≥ 11.5.1 (minimum pro OIDC). Pro Node 22 přidej `npm install -g npm@latest` před publish.
- **`--provenance`** — doporučeno, někteří hlásí problémy bez něj při prvním publishi.
- **`--access public`** — nutné pro scoped balíčky (`@scope/package`).
- **`NODE_AUTH_TOKEN` nenastavuj** — ani prázdný. Pokud ho npm CLI detekuje, pokusí se o token autentizaci místo OIDC.

## `.github/workflows/main.yml` (pouze pokud projekt má testy)

**Vytvoř pouze pokud `scripts.test` existuje v `package.json`.** Jinak ho nevytvářej.

```yaml
name: CI

on:
  - push
  - pull_request

jobs:
  test:
    name: Node.js ${{ matrix.node-version }} on ${{ matrix.os }}
    runs-on: ${{ matrix.os }}

    strategy:
      fail-fast: false
      matrix:
        node-version: [22, 24, 25]
        os:
          - ubuntu-latest
          - macos-latest

    steps:
      - uses: actions/checkout@v6
      - uses: actions/setup-node@v6
        with:
          node-version: ${{ matrix.node-version }}
          cache: npm
      - run: npm ci
      - run: npm run build --if-present
      - run: npm test
```

## `package.json` — pole `repository`

Musí **přesně odpovídat** (case-sensitive) GitHub repozitáři. npm a Sigstore tuto URL validují — neshoda způsobí chybu `422 Unprocessable Entity`. Shorthand `github:user/repo` nestačí, musí být plná URL:

```json
{
  "repository": {
    "type": "git",
    "url": "git+https://github.com/username/my-package.git"
  },
  "publishConfig": {
    "access": "public"
  }
}
```

## Nastavení Trusted Publishing na npmjs.com

Balíček musí na npm již existovat — trusted publisher nelze nastavit pro nepublikovaný balíček. Při prvním publishi publikuj ručně (`npm publish` lokálně).

1. Jdi na `https://www.npmjs.com/package/NÁZEV-BALÍČKU/access`
2. Sekce **Trusted Publisher** → **GitHub Actions**
3. Vyplň (vše je case-sensitive!):
   - **Organization or user**: GitHub username nebo organizace
   - **Repository**: název repozitáře (bez prefixu username)
   - **Workflow filename**: přesný název souboru, např. `publish.yml`
   - **Environment** (volitelné): název GitHub Actions environment

## Release workflow

```sh
npm version patch   # nebo minor / major
git push origin main --tags
```

GitHub Action automaticky publikuje na npm a vytvoří GitHub Release.

## Časté chyby

- **`NODE_AUTH_TOKEN` je nastaven** — odstraň ho, i prázdný rozbije OIDC autentizaci.
- **Chybí `id-token: write`** — bez toho GitHub nevygeneruje OIDC token; chybové hlášky mohou být zavádějící.
- **Chybí `registry-url`** — bez explicitního nastavení action nevytvoří `.npmrc` a OIDC selže.
- **Case sensitivity** — username, název repozitáře a název workflow souboru musí přesně odpovídat.
- **Self-hosted runners nefungují** — trusted publishing vyžaduje GitHub-hosted runners.
- **Privátní repozitáře** — provenance se negeneruje, ale OIDC autentizace funguje.

## Ověření

Po úspěšném publishi zkontroluj provenance na stránce balíčku na npmjs.com — zelený badge s odkazem na commit. Lokálně:

```bash
npm audit signatures
```
