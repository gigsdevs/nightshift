# NIGHTSHIFT — CS2 Community

Georgian CS2 community portal with 18 modes, server browser, regional and capacity filters, durable favorites, editable account profile, leaderboard, mode rules and help. React / TypeScript on Vinext; Cloudflare Worker APIs and D1 persistence.

## Current operation

Without `CS2_SERVERS_JSON`, the catalogue and leaderboard show explicitly labeled sample data. All sample servers have no connect address, so the interface never opens a fake game server. Mode pages describe intended gameplay; a website does not run the game modes.

Favorites and profile edits are persisted in D1 and owned by the verified Site user ID. Authentication uses the hosting platform's ChatGPT sign-in. Steam OpenID, verified Steam account linking, actual CS2 server hosting, plugins, payments and matchmaking are not enabled by this build.

## Connect real game servers

Set the hosted `CS2_SERVERS_JSON` runtime value to an array. Example shape (replace the documentation IP before configuring):

```json
[{"id":"ge-competitive-01","name":"NIGHTSHIFT COMPETITIVE #01","mode":"competitive","region":"GE","city":"თბილისი","address":"192.0.2.1:27015","capacity":10}]
```

Supported regions: GE, DE, TR. Mode slugs live in `lib/catalog.ts`. Merely entering a server does not mark it online. Send current telemetry from a trusted server-side process to `POST /api/ingest`, with `Authorization: Bearer <CS2_INGEST_TOKEN>` and JSON:

```json
{"serverId":"ge-competitive-01","map":"de_mirage","players":7,"capacity":10,"online":true}
```

Use an unpredictable token at least 32 characters long. Never ship it in browser code. Send an update every 30–60 seconds. Status expires after 120 seconds. Browser updates every 30 seconds. Browser-to-server latency is not fabricated: live ping is shown as unavailable. The website cannot make UDP A2S queries; the game-server-side bridge owns that step.

Optional `rankings` on the same authenticated ingest request accepts up to 100 aggregated player records per request, keyed by SteamID64 and mode. These are cumulative authoritative values, not increments. Send the aggregated rating and statistics from a trusted game plugin/collector. SteamID presence in telemetry does not link a website profile; verified identity linking remains separate.

The current Site starts private. An external bridge must also be allowed through the Site's audience/access configuration; a Bearer token does not bypass the hosting platform's private access. Change audience only when ready for public community access.

## Development

Use the configured pnpm installation. `node node_modules/typescript/bin/tsc --noEmit` checks TypeScript. `pnpm run db:generate` generates migration changes. The Sites build script produces a Worker with `fetch` and bundles D1 migrations. In managed Linux use `sites-preview start` for the internal preview; production is published through Sites.

Apply local D1 migrations once after generating the build config:

```sh
node --import ./scripts/sites-env.mjs ./node_modules/wrangler/bin/wrangler.js d1 execute DB --local --config dist/server/wrangler.json --persist-to .wrangler/state --file drizzle/0000_common_tarantula.sql
```

Do not accept player-provided website headers as authentication in a deployment outside Sites. Production relies on platform-verified headers supplied by the dispatcher. All profile/favorite writes additionally require a same-origin request and use bound SQL parameters.

## Artwork

Valve artwork from Counter-Strike and Steam, resized and encoded as WebP for the site. Valve retains copyright. Source URLs and asset notes are in `ASSETS.md`. NIGHTSHIFT is an independent community design, not an official Valve or Cybershoke product.
