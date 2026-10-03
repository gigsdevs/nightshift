# NIGHTSHIFT store

The blue redesign, `/shop`, Admin price selector, and membership profile badges are implemented. VIP Basic, VIP Major, VIP Grand and VIP ELITE are listed without invented prices or benefits. Admin pricing is USD 10 for one calendar month, USD 15 for three calendar months, USD 25 for lifetime; payments are one-time, not subscriptions. Each purchase starts a new entitlement at confirmation; repeated purchases do not stack time.

## Enable card payments

Set these server-only variables on the existing `nightshift-final` Railway service:

- `STRIPE_SECRET_KEY`: the merchant's Stripe secret key.
- `STRIPE_WEBHOOK_SECRET`: the signing secret for this endpoint: `https://nightshift-final-production.up.railway.app/api/stripe/webhook`.
- `SUPABASE_SERVICE_ROLE_KEY`: a server-side service-role key for the existing Nightshift Supabase project. Never prefix it with `NEXT_PUBLIC_`.

Subscribe the Stripe endpoint to `checkout.session.completed`, `checkout.session.async_payment_succeeded`, and `charge.refunded`. First configure matching test-mode credentials and verify a full test checkout and webhook delivery before switching to live credentials. The code deliberately reports card payments as unavailable when any required server secret is missing. No Stripe merchant connection or actual charge was performed during implementation.

Checkout authenticates the user with Supabase, computes the price on the server, and redirects to hosted Stripe Checkout. The webhook verifies the raw-body HMAC and timestamp, the payment mode, user identity, product, USD currency and exact amount. The session ID uniquely identifies each entitlement, so webhook retries cannot create duplicate grants. Refund notifications revoke matching entitlements. Review refunds/disputes in Stripe; dispute automation is not implemented. Unusual webhook ordering should be reconciled before enabling live sales.

## Memberships

`store_memberships` is deployed with RLS and an owner-only SELECT policy. Browser users cannot insert, update, or delete membership records. Only trusted backend credentials write purchased entitlements. The profile endpoint reads active, unrevoked memberships and falls back to verified Supabase `app_metadata` (`role`, `vip_tier`, `membership_expires_at`) and the existing `ADMIN_EMAILS` allowlist. Editable `user_metadata` and profile-edit requests cannot grant roles.

VIP tier values are `basic`, `major`, `grand`, `elite`. Default accounts display Player; verified VIPs display their tier; active Admin memberships display Admin. Expired purchases no longer grant a profile role. Bought Admin is a community profile status; it does not grant the site's server-management permissions. Those remain restricted to the existing `ADMIN_EMAILS` allowlist. CS2 game-server privileges still require an actual server integration and verified Steam linking.

## Outstanding merchant information

- VIP prices, durations and actual game-server benefits.
- Crypto coin, network, destination wallet and payment-verification/provider details. Crypto is shown as unavailable, with no invented address or transaction flow.
- The Stripe merchant configuration above and an end-to-end test payment.

## Verification

Production build and TypeScript check; focused lint; five tests covering role precedence, expiry, refund revocation filtering, raw-payload signature checks and calendar-month boundaries. Database grants and RLS inspected read-only. An attempted rollback-only Auth/RLS integration test was blocked by automatic approval review; no test accounts were created. Browser inspection covered the desktop store, Admin detail modal and 390px mobile store. Existing password-security advisory: https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection

Run tests with Node 22.18+ or Node 24: `node --test tests/membership.test.mjs`.
