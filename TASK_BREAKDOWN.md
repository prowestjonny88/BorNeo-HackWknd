# Pasar Memory — Hackathon Task Breakdown (5 People)

## Team Roles Overview

| Role | Person | Scope | Primary Directories Owned |
|---|---|---|---|
| **Dev 1** | Architect / Foundation | Project init, data models, local DB, Supabase setup, sync, shared widgets | `pubspec.yaml`, `lib/models/`, `lib/data/`, `lib/services/sync/`, `lib/shared/`, `supabase/migrations/` |
| **Dev 2** | Frontend — Capture | Onboarding, menu setup, selling mode (tap-to-capture) | `lib/features/onboarding/`, `lib/features/menu_setup/`, `lib/features/selling/` |
| **Dev 3** | AI / Intelligence | Screenshot import, OCR, parsing, matching engine, confidence scoring | `lib/features/import/`, `lib/services/ocr/`, `lib/services/matching/`, `supabase/functions/reconcile/` |
| **Dev 4** | Output / Review | Home screen, daily summary, unresolved queue, correction flow, voice recap | `lib/features/home/`, `lib/features/summary/`, `lib/features/unresolved/`, `lib/features/correction/`, `lib/features/voice/`, `lib/services/stt/` |
| **Person 5** | Presentation & Demo | Pitch deck, demo script, narrative, Q&A prep, screen recordings | `docs/`, `presentation/` |

---

## Proposed Folder Structure (Merge-Conflict-Safe)

```
pasar_memory/
├── pubspec.yaml                          # Dev 1 (locked after Phase 0)
├── lib/
│   ├── main.dart                         # Dev 1 (entry point, locked after Phase 0)
│   ├── app.dart                          # Dev 1 (MaterialApp, router, theme)
│   ├── router.dart                       # Dev 1 (go_router config — adds routes once, devs reference only)
│   │
│   ├── models/                           # Dev 1 ONLY
│   │   ├── merchant.dart
│   │   ├── menu_item.dart
│   │   ├── order_event.dart
│   │   ├── payment_evidence.dart
│   │   ├── payment_event.dart
│   │   ├── match_record.dart
│   │   ├── correction_record.dart
│   │   └── daily_summary.dart
│   │
│   ├── data/                             # Dev 1 ONLY
│   │   ├── local/
│   │   │   └── database.dart             # SQLite schema + DAOs
│   │   ├── remote/
│   │   │   └── supabase_client.dart      # Supabase init + helpers
│   │   └── repositories/
│   │       ├── merchant_repo.dart
│   │       ├── menu_repo.dart
│   │       ├── order_repo.dart
│   │       ├── payment_repo.dart
│   │       ├── match_repo.dart
│   │       └── summary_repo.dart
│   │
│   ├── services/                         # Split by domain
│   │   ├── sync/                         # Dev 1
│   │   │   └── sync_service.dart
│   │   ├── ocr/                          # Dev 3 ONLY
│   │   │   ├── ocr_service.dart
│   │   │   └── receipt_parser.dart
│   │   ├── matching/                     # Dev 3 ONLY
│   │   │   ├── matching_engine.dart
│   │   │   └── confidence_scorer.dart
│   │   └── stt/                          # Dev 4 ONLY
│   │       └── stt_service.dart
│   │
│   ├── features/                         # Each dev owns their own subdirectories
│   │   ├── onboarding/                   # Dev 2 ONLY
│   │   │   ├── onboarding_screen.dart
│   │   │   └── onboarding_provider.dart
│   │   ├── menu_setup/                   # Dev 2 ONLY
│   │   │   ├── menu_setup_screen.dart
│   │   │   ├── menu_item_tile.dart
│   │   │   └── menu_setup_provider.dart
│   │   ├── selling/                      # Dev 2 ONLY
│   │   │   ├── selling_screen.dart
│   │   │   ├── order_tray.dart
│   │   │   ├── item_button.dart
│   │   │   └── selling_provider.dart
│   │   ├── import/                       # Dev 3 ONLY
│   │   │   ├── import_screen.dart
│   │   │   ├── processing_screen.dart
│   │   │   └── import_provider.dart
│   │   ├── matching/                     # Dev 3 ONLY
│   │   │   ├── matching_results_screen.dart
│   │   │   └── matching_provider.dart
│   │   ├── home/                         # Dev 4 ONLY
│   │   │   ├── home_screen.dart
│   │   │   └── home_provider.dart
│   │   ├── summary/                      # Dev 4 ONLY
│   │   │   ├── daily_summary_screen.dart
│   │   │   └── summary_provider.dart
│   │   ├── unresolved/                   # Dev 4 ONLY
│   │   │   ├── unresolved_queue_screen.dart
│   │   │   └── unresolved_provider.dart
│   │   ├── correction/                   # Dev 4 ONLY
│   │   │   ├── edit_match_screen.dart
│   │   │   └── correction_provider.dart
│   │   └── voice/                        # Dev 4 ONLY
│   │       ├── voice_recap_screen.dart
│   │       └── voice_provider.dart
│   │
│   └── shared/                           # Dev 1 (shared widgets + theme)
│       ├── theme/
│       │   └── app_theme.dart
│       └── widgets/
│           ├── confidence_badge.dart
│           ├── evidence_link.dart
│           └── loading_indicator.dart
│
├── supabase/
│   ├── config.toml                       # Dev 1
│   ├── migrations/                       # Dev 1 ONLY
│   │   └── 001_initial_schema.sql
│   └── functions/
│       ├── reconcile/                    # Dev 3
│       │   └── index.ts
│       └── transcribe/                   # Dev 4
│           └── index.ts
│
├── docs/                                 # Person 5
│   └── demo_script.md
└── presentation/                         # Person 5
    └── pitch_deck.md
```

---

## Phase 0 — Bootstrap (Dev 1 leads, everyone waits)

Dev 1 must complete this BEFORE anyone else starts coding. This creates the skeleton everyone builds on.

### Dev 1 — Bootstrap Tasks

| # | Task | Output | Est. Complexity |
|---|---|---|---|
| 1.0.1 | Run `flutter create pasar_memory` | Project scaffold | Low |
| 1.0.2 | Configure `pubspec.yaml` with ALL dependencies (see list below) | Locked pubspec | Low |
| 1.0.3 | Create folder structure (`lib/models/`, `lib/data/`, `lib/features/`, `lib/services/`, `lib/shared/`) | Empty directories + placeholder files | Low |
| 1.0.4 | Define all data model classes in `lib/models/` (freezed + json_serializable) | 8 model files | Medium |
| 1.0.5 | Set up `app.dart` with MaterialApp + Riverpod + go_router skeleton | Working app shell | Low |
| 1.0.6 | Create `router.dart` with placeholder routes for all screens | Navigation skeleton | Low |
| 1.0.7 | Set up `lib/shared/theme/app_theme.dart` with base colors/typography | Theme file | Low |
| 1.0.8 | Initialize Supabase project + create Postgres schema migration | `supabase/migrations/001_initial_schema.sql` | Medium |
| 1.0.9 | Set up `supabase_client.dart` with init + env config | Supabase connection | Low |
| 1.0.10 | Push skeleton to `main`, create feature branches for each dev | Git branches ready | Low |

**pubspec.yaml dependencies to include upfront:**
```yaml
dependencies:
  flutter_riverpod:
  go_router:
  sqflite:
  path:
  dio:
  freezed_annotation:
  json_annotation:
  image_picker:
  file_picker:
  share_plus:
  google_mlkit_text_recognition:
  record:
  supabase_flutter:
  intl:
  uuid:

dev_dependencies:
  freezed:
  json_serializable:
  build_runner:
```

### Everyone Else During Phase 0

- **Dev 2**: Review PRD flows for onboarding + selling mode, sketch screen layouts on paper/Figma
- **Dev 3**: Research ML Kit text recognition API + test with sample Malaysian payment screenshots
- **Dev 4**: Research OpenAI transcription API + sketch home/summary screen layouts
- **Person 5**: Start structuring pitch narrative, identify key demo moments

---

## Phase 1 — Parallel Feature Build (All devs work simultaneously)

### Dev 1 — Data Layer & Repositories

| # | Task | Details |
|---|---|---|
| 1.1.1 | Implement SQLite database helper (`lib/data/local/database.dart`) | Create tables for all 8 objects; CRUD operations; migrations |
| 1.1.2 | Implement `merchant_repo.dart` | Create/read/update merchant profile |
| 1.1.3 | Implement `menu_repo.dart` | CRUD for menu items; toggle active state |
| 1.1.4 | Implement `order_repo.dart` | Create order events from tap input; list by date; update status |
| 1.1.5 | Implement `payment_repo.dart` | Store payment evidence + payment events; link evidence to events |
| 1.1.6 | Implement `match_repo.dart` | Store/update match records; query by confidence; audit trail |
| 1.1.7 | Implement `summary_repo.dart` | Compute daily aggregates; confirm day; list history |
| 1.1.8 | Implement `sync_service.dart` | Background sync to Supabase (queue + retry); upload screenshots/audio to Storage |
| 1.1.9 | Build shared widgets: `confidence_badge.dart`, `evidence_link.dart` | Reusable UI components that Dev 3 + Dev 4 will use |
| 1.1.10 | Supabase Edge Function: `summary/index.ts` | Serverside daily summary generation (backup to on-device) |
| 1.1.11 | Wire up go_router with actual screen widgets (once Devs 2/3/4 export their screen classes) | Final navigation integration |

**Interfaces Dev 1 must publish early (by end of Phase 0):**
- Repository abstract classes / method signatures so Devs 2/3/4 can code against them
- Model classes with `toJson()` / `fromJson()`
- Example usage patterns for Riverpod providers accessing repos

---

### Dev 2 — Onboarding + Menu Setup + Selling Mode

| # | Task | Details |
|---|---|---|
| 2.1.1 | Build `onboarding_screen.dart` | Merchant profile creation (stall name, business type); minimal fields |
| 2.1.2 | Build `onboarding_provider.dart` | State management for onboarding flow; calls `merchant_repo` |
| 2.1.3 | Build `menu_setup_screen.dart` | Add/edit/delete menu items with name + price; preset suggestions ("Bihun", "Mee", "Teh Ais") |
| 2.1.4 | Build `menu_item_tile.dart` | Reusable list tile for menu item with edit/delete |
| 2.1.5 | Build `menu_setup_provider.dart` | State for menu list; calls `menu_repo` |
| 2.1.6 | Build `selling_screen.dart` | Large item grid buttons; quantity counter; auto-calculated total |
| 2.1.7 | Build `order_tray.dart` | Bottom sheet / panel showing current order items + total |
| 2.1.8 | Build `item_button.dart` | Big tap-friendly button widget (item name + price + quantity badge) |
| 2.1.9 | Implement "Done" action | Creates `OrderEvent` via `order_repo`, saves with timestamp, clears tray |
| 2.1.10 | Implement "Undo" action | Removes last item from current order tray |
| 2.1.11 | Implement "Repeat Last Order" | Copies previous order items into new order |
| 2.1.12 | Build `selling_provider.dart` | Current order state; order history for today; calls `order_repo` |
| 2.1.13 | Handle edge case: exit mid-order | Auto-save as "open order" with status flag |
| 2.1.14 | Handle edge case: price change mid-day | Allow price edit from selling screen (modal) |

**Key UX targets from PRD:**
- Setup must complete in under 60 seconds
- Selling mode: 1-3 taps per item, minimal navigation
- Large buttons, icon + color, minimal text entry

---

### Dev 3 — Screenshot Import + OCR + Matching Engine

| # | Task | Details |
|---|---|---|
| 3.1.1 | Build `import_screen.dart` | Gallery multi-select via `image_picker`/`file_picker`; thumbnail previews; "Process" button |
| 3.1.2 | Build `import_provider.dart` | Manage selected images; track processing state |
| 3.1.3 | Implement `ocr_service.dart` | Integrate `google_mlkit_text_recognition`; accept image path → return raw text blocks with bounding boxes |
| 3.1.4 | Implement `receipt_parser.dart` | Parse OCR raw text to extract: amount (RM), timestamp, provider name, transaction reference; regex + layout heuristics |
| 3.1.5 | Build parsing rules for top 3 Malaysian wallets | TNG eWallet, DuitNow QR, Boost — study common screenshot layouts |
| 3.1.6 | Create `PaymentEvent` from parsed OCR data | Store extracted fields + link to `PaymentEvidence` (the screenshot); store raw_text + extraction_confidence |
| 3.1.7 | Build `processing_screen.dart` | Progress indicator: importing → OCR → extracting → matching; show per-image status |
| 3.1.8 | Handle OCR failures gracefully | "Needs clearer image" message; retry/crop tips; never silently discard |
| 3.1.9 | Implement `matching_engine.dart` | Core reconciliation logic (see algorithm below) |
| 3.1.10 | Implement `confidence_scorer.dart` | Score each (payment, order) pair; output: confidence_level + reasons[] + evidence_links |
| 3.1.11 | Build `matching_results_screen.dart` | List of payments with matched order; confidence badges; tap row for "why this match" explanation |
| 3.1.12 | Build `matching_provider.dart` | Trigger matching runs; expose results; allow re-runs after corrections |
| 3.1.13 | Handle edge case: duplicate screenshots | Hash-based deduplication on import |
| 3.1.14 | Handle edge case: multi-transaction history screenshots | Detect multiple rows in a single screenshot; extract each as separate `PaymentEvent` |
| 3.1.15 | Supabase Edge Function: `reconcile/index.ts` | Server-side matching endpoint (backup path if on-device is insufficient) |

**Matching Algorithm (rules-based MVP):**
```
1. Build ordered list of OrderEvents (from taps) for today
2. Build list of PaymentEvents (from OCR) for today
3. For each PaymentEvent:
   a. Find candidate OrderEvents where:
      - amount matches exactly (±RM 0.10 tolerance)
      - timestamp within configurable window (e.g., ±30 min)
   b. Score candidates:
      - exact_amount: +40 pts
      - near_amount: +20 pts
      - time_proximity (closer = higher): +30 pts max
      - uniqueness (only 1 candidate?): +20 pts
      - sequence_sanity (chronological): +10 pts
   c. Assign:
      - Score >= 80: High confidence → auto-match
      - Score 50-79: Medium → match but flag "review suggested"
      - Score < 50: Low → send to unresolved queue
4. Remaining unmatched OrderEvents → label as "likely cash" or "unmatched"
5. Remaining unmatched PaymentEvents → send to unresolved queue
```

---

### Dev 4 — Home / Summary / Unresolved / Correction / Voice

| # | Task | Details |
|---|---|---|
| 4.1.1 | Build `home_screen.dart` | Today's draft total (big number), cash vs digital cards, unresolved count badge, contextual CTA button |
| 4.1.2 | Build `home_provider.dart` | Aggregate today's data from repos; determine current state (selling / importing / reviewing / confirming) |
| 4.1.3 | Implement contextual CTA logic | "Start Selling" → "Import Payments" → "Review Unmatched" → "Confirm Day" based on state |
| 4.1.4 | Build `daily_summary_screen.dart` | Total sales, digital total, cash estimate, item counts, best-selling item, unresolved count, "Confirm Day" button |
| 4.1.5 | Build `summary_provider.dart` | Compute aggregates from match records + order events; handle estimated vs confirmed states |
| 4.1.6 | Implement "Confirm Day" action | Lock daily summary, write to `DailySummary`, mark as confirmed |
| 4.1.7 | Build `unresolved_queue_screen.dart` | Two tabs: unmatched payments / unmatched orders; quick action buttons per item |
| 4.1.8 | Build `unresolved_provider.dart` | Query unmatched records; expose quick actions |
| 4.1.9 | Implement quick actions for unresolved items | "Match manually" (pick from candidates), "Mark as cash-only", "Delete duplicate" |
| 4.1.10 | Build `edit_match_screen.dart` | Show payment screenshot crop + order details; dropdown to reassign; manual amount override |
| 4.1.11 | Build `correction_provider.dart` | Save corrections to `CorrectionRecord`; update match + summary; maintain audit log |
| 4.1.12 | Implement audit trail UI | Show correction history per match; revert capability |
| 4.1.13 | Build `voice_recap_screen.dart` | One-tap record button (≤60s); show transcript; show extracted suggestions; "Apply changes" button |
| 4.1.14 | Build `voice_provider.dart` | Audio recording via `record` package; manage recording state |
| 4.1.15 | Implement `stt_service.dart` | Send audio to OpenAI transcription API (`gpt-4o-mini-transcribe`); return transcript |
| 4.1.16 | Implement entity extraction from transcript | Regex + keyword matching: extract item names (matched to menu), quantities, cash/QR cues |
| 4.1.17 | Build suggestion UI for voice results | Show "Did you mean: 30 bihun, 12 mee?" with accept/reject per suggestion |
| 4.1.18 | Handle STT failures | Keep audio file; show "Needs review" with raw/failed transcript; allow typed correction |
| 4.1.19 | Supabase Edge Function: `transcribe/index.ts` | Proxy for OpenAI STT API (keeps API key server-side) |
| 4.1.20 | Implement "Estimated" vs "Confirmed" labels | Visual distinction everywhere a number appears; one-tap path to "Why / Fix" |

---

### Person 5 — Presentation & Demo

| # | Task | Details |
|---|---|---|
| 5.1.1 | Draft pitch narrative structure | Problem → Who → Why Now → Solution → Demo → Differentiation → Market → Roadmap → Ask |
| 5.1.2 | Write problem statement slide | Use PRD stats: ASEAN MSMEs = 97-99% of establishments, DuitNow QR 870M transactions in 2024, hawker trust barriers |
| 5.1.3 | Create persona slide | "Kak Lina" — fried bihun hawker; daily context; key frustrations |
| 5.1.4 | Create solution overview slide | Three input modes (tap + screenshot + voice) → reconciliation engine → trusted daily record |
| 5.1.5 | Create product architecture slide | Simplified visual of the architecture diagram from architecture doc |
| 5.1.6 | Script the live demo flow | 6-step demo: setup (60s) → tap orders → import screenshots → auto-match → review summary → correct mismatch |
| 5.1.7 | Prepare demo data / seed data | Pre-configured merchant profile, menu items, sample screenshots for smooth demo |
| 5.1.8 | Create competitive landscape slide | 2x2 matrix or table: POS vs wallet vs accounting vs Pasar Memory |
| 5.1.9 | Create market opportunity slide | TAM/SAM framing: Malaysia hawkers, fresh market merchants, ASEAN MSMEs |
| 5.1.10 | Create "why not just a POS" differentiation slide | Reconciliation-first vs logging-first; trust layer; merchant-owned memory |
| 5.1.11 | Create roadmap slide | MVP → v1.5 → v2 with concrete feature bullets |
| 5.1.12 | Prepare judge Q&A cheat sheet | Anticipated questions: "How is this different from X?", "How do you make money?", "What about accuracy?", privacy concerns |
| 5.1.13 | Record/capture screen recordings of app during dev | Work with devs to capture demo clips as fallback |
| 5.1.14 | Final rehearsal run with full team | Dry run of pitch + demo; time it; refine |

---

## Phase 2 — Integration & Polish

This phase begins once Phase 1 core tasks are done.

| # | Task | Owner | Details |
|---|---|---|---|
| INT.1 | Dev 1 wires all screen routes into `router.dart` | Dev 1 | Connect all feature screens to go_router with proper navigation |
| INT.2 | Dev 2 + Dev 3 integration test: tap orders → import screenshot → match | Dev 2 + Dev 3 | End-to-end flow from selling to matching |
| INT.3 | Dev 3 + Dev 4 integration test: matching results → unresolved queue → correction | Dev 3 + Dev 4 | Unresolved items flow through to correction and back to summary |
| INT.4 | Dev 4 integration: home screen pulls live data from all repos | Dev 4 | Home screen reflects real state from orders, payments, matches |
| INT.5 | Full flow test: onboarding → selling → import → match → summary → confirm | All devs | Complete happy path walkthrough |
| INT.6 | Error state polish (empty states, loading states, OCR failures) | Dev 2 + Dev 3 | Address edge cases from PRD |
| INT.7 | UI consistency pass (theme, spacing, font sizes, button sizes) | Dev 2 | Ensure selling buttons are large enough, consistent styling |
| INT.8 | Seed demo data for presentation | Dev 1 + Person 5 | Pre-populate realistic data for smooth demo |

---

## Coordination Rules (Merge Conflict Prevention)

### Golden Rules

1. **Never edit files outside your owned directories** without coordinating on Slack/chat first
2. **`pubspec.yaml` is locked after Phase 0** — if you need a new package, tell Dev 1
3. **`router.dart` is owned by Dev 1** — give Dev 1 your screen class names and route paths, they wire it
4. **Models are owned by Dev 1** — if you need a model field added/changed, request it from Dev 1
5. **Each feature screen exports a single top-level widget** — Dev 1 imports it into the router

### Branch Strategy

```
main
├── dev1/foundation      # Dev 1
├── dev2/capture-ui      # Dev 2
├── dev3/ocr-matching    # Dev 3
├── dev4/summary-review  # Dev 4
└── docs/presentation    # Person 5
```

- Dev 1 merges to `main` first (foundation)
- Devs 2/3/4 rebase on `main` after Dev 1's merge
- Devs 2/3/4 merge independently (no overlapping files)
- Integration fixes go on a shared `integration` branch

### Communication Checkpoints

| When | What |
|---|---|
| After Phase 0 | Dev 1 announces: "Skeleton merged to main, rebase your branches" |
| When models change | Dev 1 announces: "Model X updated, pull latest" |
| When repos are ready | Dev 1 announces: "Repo X is ready with these methods: ..." |
| When screen is ready | Dev 2/3/4 announce: "Screen X exported as `WidgetName`, add to router" |
| Before Phase 2 | Everyone syncs, resolves any interface mismatches |

---

## Dependency Map (What Blocks What)

```
Phase 0 (Dev 1: scaffold + models + repos)
    │
    ├──→ Dev 2 can start UI (uses model classes + repo interfaces)
    ├──→ Dev 3 can start OCR service (independent) + import UI (uses models)
    ├──→ Dev 4 can start home/summary UI (uses models + repo interfaces)
    └──→ Person 5 can start full pitch deck (independent)

Dev 1 repos ready
    │
    ├──→ Dev 2 wires selling_provider to order_repo
    ├──→ Dev 3 wires import_provider to payment_repo + matching to match_repo
    └──→ Dev 4 wires summary_provider to summary_repo + match_repo

Dev 3 matching engine ready
    │
    └──→ Dev 4 can populate unresolved queue screen with real data

All screens ready
    │
    └──→ Dev 1 wires router → Integration testing begins
```

---

## Summary: Who Does What, Who Touches What

| File/Directory | Dev 1 | Dev 2 | Dev 3 | Dev 4 | P5 |
|---|---|---|---|---|---|
| `pubspec.yaml` | **Own** | — | — | — | — |
| `lib/main.dart`, `app.dart`, `router.dart` | **Own** | — | — | — | — |
| `lib/models/*` | **Own** | Read | Read | Read | — |
| `lib/data/*` | **Own** | Read | Read | Read | — |
| `lib/shared/*` | **Own** | Use | Use | Use | — |
| `lib/services/sync/` | **Own** | — | — | — | — |
| `lib/services/ocr/` | — | — | **Own** | — | — |
| `lib/services/matching/` | — | — | **Own** | — | — |
| `lib/services/stt/` | — | — | — | **Own** | — |
| `lib/features/onboarding/` | — | **Own** | — | — | — |
| `lib/features/menu_setup/` | — | **Own** | — | — | — |
| `lib/features/selling/` | — | **Own** | — | — | — |
| `lib/features/import/` | — | — | **Own** | — | — |
| `lib/features/matching/` | — | — | **Own** | — | — |
| `lib/features/home/` | — | — | — | **Own** | — |
| `lib/features/summary/` | — | — | — | **Own** | — |
| `lib/features/unresolved/` | — | — | — | **Own** | — |
| `lib/features/correction/` | — | — | — | **Own** | — |
| `lib/features/voice/` | — | — | — | **Own** | — |
| `supabase/migrations/` | **Own** | — | — | — | — |
| `supabase/functions/reconcile/` | — | — | **Own** | — | — |
| `supabase/functions/transcribe/` | — | — | — | **Own** | — |
| `docs/`, `presentation/` | — | — | — | — | **Own** |
