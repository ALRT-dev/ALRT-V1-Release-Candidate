# ALRT+ subscription — setup guide

This is the "turn it on" checklist. The **code** is built (app paywall + RevenueCat
wiring + backend entitlement webhook). What remains is **configuration in the
consoles** — that's the part only an account owner can do. Order matters; follow
top to bottom.

**Key facts baked into the code**
- Entitlement id: **`plus`** (must match exactly in RevenueCat).
- Prices are **store-rendered** — the app shows whatever the stores return, so you
  set the price once per store and it converts to every currency automatically.
- Entitlements are written **only by the RevenueCat webhook** — the app can never
  grant ALRT+ to itself.

---

## 1. App Store Connect (iPhone) — create the products
1. **Agreements, Tax, and Banking** → accept the Paid Apps agreement, add your
   **bank account** and **tax forms**. *(This is where Apple pays you. Nothing
   sells until this says "Active".)*
2. Enrol in the **App Store Small Business Program** → drops Apple's cut from 30%
   to **15%** (you qualify under US$1M/year).
3. Your app → **Subscriptions** → create a **Subscription Group** ("ALRT+").
4. Add two subscriptions in that group:
   - **Monthly** — product id `alrt_plus_monthly`, price **$9.99**
   - **Yearly** — product id `alrt_plus_yearly`, price **$99.99**
5. On each, add an **Introductory Offer → Free Trial → 1 month**.

## 2. Google Play Console (Android) — create the products
1. **Setup → Payments profile** → add **bank account + tax info**. *(Google pays
   you here.)* Google's subscription cut is already **15%**.
2. **Monetise → Subscriptions** → create subscription `alrt_plus_monthly`
   (base plan monthly, **$9.99**) and `alrt_plus_yearly` (base plan yearly,
   **$99.99**).
3. On each base plan add an **Offer → Free trial → 1 month**.
4. Keep the **product ids identical to Apple's** (`alrt_plus_monthly`,
   `alrt_plus_yearly`).

## 3. RevenueCat — tie it together (free under ~US$2.5k/mo)
1. Create a project. Add two apps: the **App Store** app and the **Play Store**
   app. Upload the required store credentials (App Store shared secret / Play
   service-account JSON) as RevenueCat instructs.
2. Copy the two **public SDK keys** (one Apple, one Google).
3. **Products** → import `alrt_plus_monthly` and `alrt_plus_yearly` from both
   stores.
4. **Entitlements** → create one called **`plus`** and attach both products to it.
5. **Offerings** → create an offering, add a **Monthly** and **Annual** package,
   and mark it the **current** offering. *(The app reads "current", so this is
   what customers see.)*
6. **Integrations → Webhooks** → add:
   - **URL:** `https://api.safetyalrt.com/api/revenuecat/webhook`
   - **Authorization header:** a long random secret you choose.

## 4. Wire the keys into the code (developer step — hand to Matt)
- **App** (`.env`, injected at build):
  - `REVENUECAT_API_KEY_APPLE=<public Apple SDK key>`
  - `REVENUECAT_API_KEY_GOOGLE=<public Google SDK key>`
- **Backend** (env / AWS Secrets Manager):
  - `REVENUECAT_WEBHOOK_AUTH=<the exact Authorization secret from step 3.6>`
- Deploy the backend (runs the new migration `add_alrt_plus_entitlement`) and
  release the app build.

## 5. Test before going live
- Add **sandbox testers** (App Store Connect → Sandbox; Play → License testing).
- On a real device: create a family circle → the paywall appears → subscribe with
  a sandbox account → confirm the free-trial subscription completes and hosting
  proceeds. Check the user's `isPlus` flips true in the DB (proves the webhook
  fired).

---

## Who does what
| Task | Owner |
|---|---|
| Create products, prices, free trial | **You** (App Store Connect + Play Console) |
| Banking + tax (getting paid) | **You** |
| Small Business Program enrolment | **You** |
| RevenueCat project, entitlement `plus`, offering, webhook | **You** (or Matt) |
| Put SDK keys in app `.env` + webhook secret on backend | **Matt** |
| Deploy backend (migration) + release app | **Matt** |

## Costs summary
- **Store fee:** ~**15%** of each subscription (Small Business Program / Google
  subscription rate). You keep ~85%.
- **RevenueCat:** free until ~US$2.5k/month of tracked revenue.
- **Free trial:** the first month costs the user nothing; you're not charged a fee
  on $0.

## What the customer experiences
Creating a family circle they host → a dark **ALRT+** paywall → "Start your free
month", Yearly (Best value) / Monthly with live store prices → subscribe → 1 month
free, then billed by their app store. Joining someone else's circle is always free
and never shows this.
