Yes — for **Pasar Memory**, I’d use an **offline-first, mobile-first architecture**.

## Recommended system architecture

```text
[Flutter Mobile App]
   ├─ UI Layer
   ├─ Local DB (SQLite)
   ├─ Capture Layer
   │   ├─ Tap input
   │   ├─ Screenshot / image import
   │   └─ Voice recording
   ├─ On-device OCR
   ├─ Local rules / draft generation
   └─ Sync Queue
          ↓
[Supabase Backend]
   ├─ Postgres
   ├─ Auth
   ├─ Storage (images / audio)
   ├─ Edge Functions
   │   ├─ OCR post-processing
   │   ├─ STT orchestration
   │   ├─ Matching / reconciliation
   │   └─ summary generation
   └─ Realtime / sync
          ↓
[Analytics / Admin / Export Layer]
   ├─ Merchant history
   ├─ Daily summaries
   ├─ Audit trail
   └─ CSV / PDF / dashboard later
```

## Why this architecture fits the product

This product is for hawkers and fresh-market merchants, so it must work in **fast, messy, sometimes low-connectivity environments**. Flutter is a good fit because it supports iOS and Android from a single codebase, and Flutter’s docs explicitly position it as a multi-platform framework with one codebase for mobile and beyond. ([Flutter][1])

For local persistence, I would make the app **offline-first** and keep a local SQL store on-device. Flutter’s own docs recommend SQLite when you need to persist and query larger amounts of data locally, and SQLite itself is an embedded, serverless database already built into mobile environments. ([Flutter Docs][2])

For OCR, I’d use **Google ML Kit Text Recognition** on-device first, because it supports real-time text recognition on Android and iOS and is specifically designed for image-based text extraction such as receipts and other data-entry tasks. ([Google for Developers][3])

For backend, I’d use **Supabase** because it gives you Postgres, Auth, Storage, Realtime, and Edge Functions in one stack, which is unusually efficient for a hackathon or early MVP. Supabase’s docs confirm those pieces are first-class products on the platform, and Edge Functions are TypeScript functions designed to run server-side near users. ([Supabase][4])

For speech-to-text, I’d use **cloud transcription for MVP** rather than on-device. OpenAI’s current transcription docs expose a dedicated transcription endpoint, and `gpt-4o-mini-transcribe` is positioned as a faster, more accurate STT model than original Whisper-family usage for many cases. ([OpenAI Platform][5])

---

# Recommended tech stack

## 1. Mobile app

**Use:** Flutter + Dart
**Why:** one codebase, fast iteration, Android-first friendly, easy to demo and later expand to web/admin if needed. Flutter officially supports building mobile, web, and desktop apps from a single codebase. ([Flutter][1])

### App-layer libraries I’d use

* **Flutter**
* **Riverpod** or **Bloc** for state management
  I’d lean **Riverpod** for faster hackathon development.
* **go_router** for navigation
* **sqflite** or **drift** for local DB
  For MVP, **sqflite** is enough. Flutter’s SQLite cookbook uses `sqflite` for local persistence. ([Flutter Docs][2])
* **dio** for API/network calls
* **freezed + json_serializable** for typed models
* **image_picker / file_picker / share_plus** for screenshot import
* **record** for audio capture

## 2. Local storage and offline layer

**Use:** SQLite on-device
**Why:** the merchant may have weak connectivity, and this app cannot depend on always-on internet. Flutter’s docs recommend SQLite for complex local persistence, and SQLite is embedded and serverless. ([Flutter Docs][2])

### What lives locally

* menu items and prices
* tap events
* imported screenshots metadata
* draft OCR results
* draft matches
* unresolved queue
* daily summary cache
* sync status / retry queue

### Local-first rule

The **phone should be the system of capture**.
The cloud should be the **system of backup, sync, and heavy processing**.

---

## 3. OCR / multimodal extraction

**Use:** Google ML Kit Text Recognition on-device
**Why:** it runs on Android/iOS, supports real-time recognition, and handles Latin script well, which fits Malaysian payment screenshots and receipts. ([Google for Developers][3])

### OCR responsibilities

* extract amount
* extract time
* detect provider text
* detect transaction reference
* keep raw text for traceability

### Why on-device first

* faster user feedback
* better privacy
* works with weak/no internet
* cheaper than always sending images to cloud

### Later additions

* receipt-specific parsing rules
* provider-specific templates
* handwritten-note support later
  ML Kit also has offline digital ink recognition, but that’s more relevant to drawn handwriting input than photographed notes. ([Google for Developers][6])

---

## 4. Speech-to-text

**MVP choice:** cloud transcription
**Use:** OpenAI transcription API (`gpt-4o-mini-transcribe`)
**Why:** better transcription quality for messy recap audio, faster to integrate than on-device speech models for a hackathon MVP. ([OpenAI Platform][5])

### STT responsibilities

* transcribe short recap clips
* detect quantities
* detect item names
* detect cues like “cash”, “QR”, “all sold”, “rest was cash”

### Fallback behavior

If STT fails:

* keep the audio
* show the raw failed transcript or “needs review”
* allow typed correction

### Production evolution

Later, if privacy/offline become critical, you can evaluate an on-device STT path.
For MVP, cloud STT is the fastest serious option.

---

## 5. Backend

**Use:** Supabase

### Why Supabase

Supabase gives you:

* **Postgres** database
* **Auth**
* **Storage**
* **Realtime**
* **Edge Functions**
  all in one platform. ([Supabase][4])

### Recommended Supabase pieces

* **Postgres** for merchant/account/day summaries
* **Storage** for screenshots and audio files
* **Auth** for merchant identity
* **Edge Functions** for:

  * server-side parsing
  * STT orchestration
  * reconciliation jobs
  * daily summary generation
* **Realtime** only if you later add multi-device sync or live admin views. ([Supabase][7])

---

## 6. Reconciliation engine

**MVP choice:** rules-based first
**Where:** Supabase Edge Functions + Postgres

### Why rules-based first

You do **not** need ML-heavy matching on day one.
For a fried bihun seller, simple rules can already be strong:

* amount match
* time proximity
* known menu prices
* whether multiple identical orders exist
* whether merchant confirmed or corrected before

### Matching flow

1. OCR extracts RM amount + timestamp
2. app checks nearby tap events
3. backend creates candidate matches
4. score candidates:

   * exact amount
   * time distance
   * duplicate ambiguity
   * merchant history
5. assign:

   * matched
   * likely match
   * unresolved

### Why this is better

It is faster to ship, easier to explain, and more trustworthy.

### Later evolution

When you have more data:

* weighted scoring model
* graph matching
* merchant-specific learned patterns
* bundle detection

---

## 7. Storage architecture

## Local

* SQLite

## Cloud

* Supabase Postgres + Storage

### Suggested data objects

* `merchant`
* `menu_item`
* `order_event`
* `payment_evidence`
* `payment_event`
* `match_record`
* `correction_record`
* `daily_summary`

This matches the PRD direction and keeps the app auditable.

---

## 8. Admin / analytics layer

For MVP, keep this minimal.

### Recommended

* Supabase dashboard for raw inspection
* simple internal web view later using Flutter web or Next.js
* exports as CSV/JSON first

### Later

* merchant dashboard
* weekly trends
* ops/admin tool for debugging OCR and matching failures

---

# Best stack choice for hackathon MVP

## Frontend

* Flutter
* Riverpod
* sqflite
* go_router
* dio
* image_picker / file_picker / share_plus
* record

## AI / multimodal

* Google ML Kit OCR
* OpenAI STT for voice recap
* custom rules-based parser/matcher

## Backend

* Supabase Postgres
* Supabase Auth
* Supabase Storage
* Supabase Edge Functions

## Dev / infra

* GitHub
* GitHub Actions
* Sentry or Firebase Crashlytics for crash reporting
* PostHog or Supabase logs for product analytics

---

# What should run on-device vs cloud

## On-device

* taps
* local order creation
* local SQLite persistence
* screenshot import
* OCR first pass
* draft summary cache
* sync queue

## Cloud

* file backup
* speech transcription
* reconciliation jobs
* summary finalization
* analytics
* cross-device sync

This split gives you:

* fast UX
* resilience in weak internet
* lower cloud cost
* simpler MVP ops

---

# My strongest recommendation

If you want the cleanest serious build:

## Architecture decision

**Offline-first Flutter mobile app + local SQLite + on-device OCR + Supabase backend + cloud STT + rules-based reconciliation engine**

That is the best balance of:

* speed to build
* demoability
* operational realism
* future extensibility

## Best framing

This is **not** a POS stack.
It is a **reconciliation notebook with a business-memory backend**.

If you want, I can turn this next into a **proper system design doc in Markdown** with:

* component diagram
* API list
* database schema
* and folder structure for the repo.

[1]: https://flutter.dev/?utm_source=chatgpt.com "Flutter - Build apps for any screen"
[2]: https://docs.flutter.dev/cookbook/persistence/sqlite?utm_source=chatgpt.com "Persist data with SQLite"
[3]: https://developers.google.com/ml-kit/vision/text-recognition/?utm_source=chatgpt.com "Text recognition v2  |  ML Kit  |  Google for Developers"
[4]: https://supabase.com/docs?utm_source=chatgpt.com "Supabase Docs"
[5]: https://platform.openai.com/docs/models/gpt-4o-mini-transcribe?utm_source=chatgpt.com "GPT-4o mini Transcribe Model | OpenAI API"
[6]: https://developers.google.com/ml-kit/vision/digital-ink-recognition?utm_source=chatgpt.com "Digital ink recognition  |  ML Kit  |  Google for Developers"
[7]: https://supabase.com/docs/guides/realtime?utm_source=chatgpt.com "Realtime | Supabase Docs"
