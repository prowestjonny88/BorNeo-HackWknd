# PRD: Market Memory — Multimodal Sales Reconciliation Copilot for Fresh Market & Hawker Merchants

## Executive summary

**What this product is**  
Market Memory is a **mobile-first, reconciliation-first “business memory” system** for informal merchants (starting with a fried bihun hawker). It helps them **reconstruct actual daily sales** across **cash + QR/e-wallet payments** using *workflow-native* inputs (tap + screenshot + voice) and produces one “trusted daily record” they can understand, edit, and export.

**Who it is for (MVP persona)**  
A **fried bihun hawker / fresh market food seller** with high-frequency walk-in sales, repetitive items, and mixed payment methods who currently relies on memory + cash counting + e-wallet app notifications.

**Why now (evidence-based tailwinds)**  
Malaysia’s e-payment adoption (especially QR) is accelerating, which increases the “mixed methods” reality: more merchants accept QR, but cash persists. Bank Negara Malaysia’s Annual Report 2024 (as reported by TNGlobal) cites growth in DuitNow QR acceptance points to **2.6M** by end‑2024 and a more-than-doubling of DuitNow QR transactions to **870M** in 2024, with value **RM31.1B**. citeturn28view0  
At the same time, hawker digitisation remains uneven and constrained by *time/effort costs, onboarding gaps, and cybersecurity concerns*—especially for older merchants. Penang Institute’s 2021 hawker study found both adoption momentum and persistent barriers, including **high monetary + non-monetary costs (time/effort)** and **cybersecurity concerns**. citeturn10view0

**Why it matters (inclusive MSME growth link)**  
ASEAN MSMEs account for **97.2%–99.9%** of establishments and contribute **~85%** of employment regionally, yet many remain informal or poorly documented. citeturn8search0  
WEF highlights that digital finance “does little” for firms **without digital footprints, limited connectivity, or low trust**—even when they have real operations and track records. citeturn18view0  
Market Memory targets this gap by creating a *merchant-owned* “first mile digital footprint” from real activity (cash + QR + voice), without forcing a full POS/accounting migration.

**Key differentiator (not an AI wrapper)**  
Most solutions are either **logging-first** (POS/accounting) or **channel-siloed** (wallet transaction history / marketplace dashboards). Market Memory is **reconciliation-first**: it turns incomplete, messy evidence (taps, payment screenshots, voice recap) into a *traceable, explainable* daily truth, with **confidence labels + evidence links + correction loops** designed to build trust (a known barrier for micro-merchants). citeturn27view0turn10view0turn18view0

## Problem and target users

**Problem statement (core pain)**  
Fresh market hawkers often finish a day unable to answer, confidently and quickly: **“How much did I actually sell today, and what portion was cash vs QR?”**  
They operate in **high-speed environments** where perfect data entry is unrealistic, and proof of sales fragments across:  
- cash (often unrecorded)  
- QR / e-wallet payments (notifications, histories, screenshots)  
- memory / mental math  
- occasional notes  
This missing “trusted daily record” blocks: operational decisions (stock prep tomorrow), tax readiness, and longer-term finance readiness.

**Root causes (validated + inferred)**  
- **Time/effort cost is a real barrier**: Penang Institute reports hawkers cite high *non-monetary costs* like effort/time and low confidence (self-efficacy) as deterrents to adopting digital tools. citeturn10view0  
- **Trust is fragile**: ASEAN’s policy toolkit synthesis notes micro-merchants face loss of funds (errors/scams), data privacy worries, poor pricing transparency (fees discovered after being charged), and time-costly recourse processes—especially for time-poor merchants. citeturn27view0  
- **Channel silos**: wallet/acquirer apps provide transaction history, but only for digital payments and often with limited retention; Touch ’n Go’s Merchant Dashboard explicitly offers transaction history “up to 90 days.” citeturn24view0  
- **POS/accounting suites require “perfect capture”**: MyInvois e‑POS, StoreHub, MePOS, RakyatPOS all offer structured sales recording and e-invoicing flows, but they assume merchants will run transactions through the system front-of-house. citeturn19view0turn22view0turn21view0turn20view0  
- **Digital footprints remain insufficient**: WEF notes many SMEs still operate offline and lack continuous digital transaction histories, keeping them “invisible to fintechs.” citeturn18view0

**Primary persona (MVP)**  
- Role: Fried bihun seller (gerai) at a pasar pagi / wet market  
- Operating context: short bursts of rush hour, minimal staff, often one phone, small menu, frequent repeat orders  
- Current tools: calculator, cash box, e-wallet QR sticker, wallet app notifications/history, memory  
- Key frustrations: unsure daily total, can’t reconcile QR sums vs cash in hand, doesn’t know item counts reliably once tired

**Secondary personas (next edges)**  
- Kuih seller, drinks stall, fruit/veg seller, fish/meat vendor (same structure: high-frequency, repetitive SKUs, mixed payments)

**Jobs-to-be-done (JTBD) examples**  
- “After I close, I want to know my day’s real sales (cash + QR) in one view so I can plan tomorrow’s prep.”  
- “I want to catch missing/odd payments fast (unmatched QR screenshots) so I don’t lose money.”  
- “I want a simple history over weeks so I can show stability if I ever apply for financing or join a program.”

## Market analysis and whitespace

**Competitor landscape summary (direct vs indirect)**  
This concept sits *between* full POS/accounting and payment-channel dashboards.

| Player / Category | Target user | Strengths (what they do well) | Gaps vs our wedge (what they don’t solve) | Competitive type |
|---|---|---|---|---|
| **MyInvois e‑POS (HASiL)** | MSMEs needing e‑invoice compliance | Free POS platform; sales mgmt + accounting + inventory + financial reporting; can generate e‑invoices. citeturn19view0 | Assumes merchants run transactions through a POS workflow; not designed to *reconstruct reality* from partial evidence (screenshots/voice). | Indirect (POS) |
| **StoreHub** | Retail/F&B scaling with POS | Inventory, loyalty, omnichannel, “growing businesses.” citeturn22view0 | Setup/training + POS discipline required; not reconciliation-first from screenshots/voice. | Indirect (POS) |
| **MePOS** | SMEs needing POS + MyInvois | Offline-ready POS that syncs; daily summary; MyInvois integration. citeturn21view0 | Still logging-first; doesn’t solve “I didn’t record everything, help me reconstruct.” | Indirect (POS) |
| **RakyatPOS** | Malaysian MSMEs | Offline POS; integrated payments; auto e-invoicing. citeturn20view0 | POS-first; not multichannel evidence + uncertainty handling as core. | Indirect (POS) |
| **TNG Merchant Dashboard / wallet merchant apps** | QR merchants | View transaction history, daily settlement reports; convenient tracking; 90-day history. citeturn24view0 | Only covers that wallet/acquirer’s digital payments; no cash; no item-level inference; limited retention; no reconciliation logic. | Adjacent (digital-only) |
| **BIMB Biz (Bank Islam)** | SME/MSME merchants | DuitNow QR, transaction history, sales dashboard; even voice notification feature updates. citeturn25view0 | Digital-only streams; no cash + item inference across evidence; not merchant-owned “reconciled ledger.” | Adjacent (digital-only) |
| **ReceiptLah** | Malaysia receipt scanning | Offline-first OCR, on-device data, export reports; uses Google ML Kit. citeturn23view0 | Expenses/receipts focus; not income reconciliation across cash+QR; no order matching. | Adjacent (OCR utility) |
| **Grab Merchant tools / MAI** | Grab merchants | AI advisor for menu updates, promos; merchant finance tools within Grab ecosystem; 1 in 4 merchants using MAI (Dec 2025). citeturn26view0 | Platform-siloed inside Grab; not for offline hawkers not running through Grab; not focused on cash+QR reconciliation. | Indirect (platform) |
| **Lazada seller tools** | E-commerce sellers | AI Smart Listing + adoption support; focused on marketplace operations. citeturn4search4 | Not relevant to offline stall workflow; not sales reconstruction for physical cash transactions. | Indirect (platform) |
| **QuickBooks / Intuit AI agents** | SMBs in accounting stack | AI agents across accounting/payments/analysis; “virtual team of AI agents.” citeturn5search0turn5search1 | Requires the business already lives inside QuickBooks; too heavy for first-mile informal merchants. | Indirect (accounting) |
| **Xero JAX** | Xero customers | AI companion for insights, invoices/quotes; agentic direction. citeturn5search2turn5search3 | Same: assumes Xero adoption; not first-mile reconciliation from messy evidence. | Indirect (accounting) |
| **SleekFlow** | Businesses with chat-driven sales | Omnichannel messaging + AI agents. citeturn4search2 | Solves messaging, not cash+QR reconciliation. | Indirect (CRM/messaging) |
| **BukuWarung (Indonesia)** | UMKM micro merchants | Bookkeeping + payments + QRIS + services; designed for micro merchants. citeturn3search10turn3search6 | Different country/reg rails; still often logging-driven; doesn’t target MY hawker mixed evidence flow. | Analog (regional) |

**Whitespace conclusion**  
The market is **adjacent-crowded but the exact wedge is open**:  
- POS/accounting tools exist (some even free via government), but they rely on disciplined transaction logging and feel “system-heavy” for a hawker’s rush-hour reality. citeturn19view0turn10view0  
- Wallet/acquirer dashboards show digital payments but cannot reconcile with cash or item counts, and may limit history retention (e.g., 90 days). citeturn24view0  
- Micro-merchants face trust and time-cost barriers; black-box automation increases drop-off. citeturn27view0turn10view0  

**Opportunity thesis**  
Create a new category: **Reconciliation Notebook / Business Memory Layer** — lighter than POS, smarter than a ledger, designed for incomplete inputs and explainable matching.

## Scope definition and MVP requirements

**Product vision & positioning**  
- Category framing: **“Reconciliation-first notebook”** (not POS, not accounting, not generic chatbot)  
- Positioning statement: *“Market Memory helps hawkers reconstruct daily sales across cash + QR from taps, screenshots, and voice—so they always know today’s true numbers.”*  
- Differentiation thesis: **multimodal capture + reconciliation engine + trust layer + merchant-owned history** (not an LLM chat wrapper).

**What MVP solves (in scope)**  
- Capture item-level sales quickly via **tap** (rush hour friendly)  
- Ingest **payment screenshots** (e-wallet / QR / bank) and extract key fields  
- Allow **voice recap** post-rush to fill gaps / correct estimates  
- Run a **matching + reconciliation engine** to label sales as cash vs digital and surface uncertainty  
- Produce an **end-of-day sales summary** that is editable and exportable  
- Build a **time-series business memory** (day-by-day)

**Non-goals (explicitly out of scope for MVP)**  
- Full inventory procurement + COGS accounting  
- Payroll, invoicing compliance automation, and tax filing  
- Chat order ingestion (future)  
- Direct integration to every wallet/bank API (future; MVP uses screenshots)  
- Lending / underwriting (future; but we create the “data exhaust”)

**MVP boundary (hackathon-ready, demoable)**  
A believable MVP demo should show:  
1) merchant sets menu prices in 60 seconds  
2) merchant records a handful of orders via tap in a rush simulation  
3) merchant imports 3–5 payment screenshots (or a single “transaction history” screenshot)  
4) system auto-matches with confidence labels  
5) daily summary shows cash vs digital totals + unresolved queue  
6) user corrects one mismatch and the summary updates instantly

**User stories (examples)**  
- As a hawker, I want to tap my common items fast so that I can record sales without slowing my line.  
- As a hawker, I want to upload my QR payment screenshots so that the app can total digital sales automatically.  
- As a hawker, I want the app to match payments to my orders and show “why” so that I trust the results.  
- As a hawker, I want to see an “unmatched” list so that I can catch missing taps or suspicious payments.  
- As a hawker, I want to confirm my final daily record so that I can keep a reliable history.

**Core product flows (realistic daily journey)**  
- Morning setup: open stall → check yesterday’s summary → confirm menu & prices  
- Rush-hour selling: tap items per order → quick “Done” → repeat  
- Mixed payments: customer pays cash or QR; hawker continues tapping items, does not need to tag payment method  
- Post-rush: upload payment screenshots (from wallet transaction history or individual receipts)  
- Voice recap: “Today I think 30 bihun, 12 mee…” and/or “I forgot to tap a few during the crowd”  
- End-of-day: review daily summary → resolve unmatched items → confirm day → optionally export/share

**Detailed feature requirements (Must / Should / Could)**  

| Feature | Description | User value | Functional requirements | Edge cases | Priority |
|---|---|---|---|---|---|
| Menu & price setup | Create 5–20 items + prices; optional combos | Enables totals & matching | Quick add; edit prices; “common combo” button | Price changes mid-day | Must |
| Tap-to-capture order | Big buttons; build order; “Done” creates order event w timestamp | Low-friction capture | Offline local save; quick undo; repeat last order | Merchant forgets “Done” | Must |
| Screenshot import | Import from gallery/share sheet | Capture digital evidence without integrations | Multi-select; store locally; allow delete | Blurry screenshots; different wallet formats | Must |
| OCR extraction | Parse amount, time/date, wallet name, reference | Automates digital totals | On-device OCR; regex + layout heuristics | Multi-transaction screenshots | Must |
| Matching engine | Link payment events to order events and label cash/digital | Reconstruct reality | Amount match + time proximity + ambiguity scoring | Same-amount repeated; partial orders | Must |
| Confidence + “why match” | Show confidence badge + evidence trail | Trust-first UX | Explain match factors; link to screenshot crop | User distrusts AI | Must |
| Unresolved queue | Lists unmatched payments and unmatched orders | Catch missing records | Filter by type; quick fix flows | Overwhelming queue | Must |
| Daily summary screen | Total sales, cash estimate, digital total, top items | Primary outcome | Show confirmed/unconfirmed state | Missing data | Must |
| Correction / audit trail | Edit a match; adjust order items; keep history | Control & accountability | Every edit recorded; revert | User changes mind | Must |
| Voice recap capture | STT + entity extraction (“10 bihun”) | Fill gaps fast | Record ≤60s; transcribe; propose adjustments | Mixed language; noisy market | Should |
| Export (PDF/CSV) | Share daily summary | Accountability; portability | Simple export; privacy-safe | Sensitive data in screenshot | Should |
| Multi-day trends | Weekly view; best day; avg sales | Early insight | Basic charts later | Sparse data | Could |
| Chat order ingestion | WhatsApp order parsing | Expansion | Not in MVP | — | Out of scope (MVP) |

## AI and intelligence requirements

**Design principle: reconciliation-first, not logging-first**  
Instead of requiring the merchant to perfectly record cash and digital methods at transaction time, we treat **digital payment evidence as a “hard signal”** and taps/voice as “soft signals,” then reconcile them into a final truth with uncertainty handling.

**OCR requirements (payment screenshots)**  
- Preferred: **on-device OCR** for privacy + offline reliability; ML Kit is explicitly designed for on-device processing and works offline. citeturn29search1  
- Minimum extracted fields: amount, time/date, merchant name or wallet label, reference/transaction id (if present)  
- Multi-format strategy:  
  - “Receipt screenshot” format: extract single transaction  
  - “History screenshot” format: detect repeated rows; extract multiple transactions  
- Output structure per extracted transaction: `{amount, timestamp, currency, provider, reference?, raw_text, bbox_map, source_image_id}`

**Speech-to-text requirements (voice recap)**  
- MVP approach options:  
  - Device speech recognition if on-device service is available (Android provides checks like `isOnDeviceRecognitionAvailable`). citeturn29search7  
  - Whisper for robust transcription in noisy environments; Whisper is open-sourced for multilingual ASR. citeturn29search2turn29search6  
- Language reality: Malay + English code-switching; optionally Mandarin/Tamil later  
- Output: transcript + extracted quantities + item mentions (entity extraction)

**Entity extraction (from voice + OCR text)**  
- Voice: parse patterns like “bihun 30,” “30 bihun,” “teh ais sepuluh,” etc.  
- OCR: parse “RM 6.00,” “Amount: 6.00,” timestamps, reference IDs

**Matching logic (core intelligence)**  
We recommend a layered approach:

**Layer one: candidate generation**  
- Build an ordered list of `OrderEvent`s from tap captures: each has `{timestamp_start, timestamp_end, items[], total_amount}`  
- Build a list of `PaymentEvent`s from OCR: `{timestamp, amount, provider, reference, source_image}`  

**Layer two: scoring**  
Score each (payment, order) pair using:
- Amount match: exact = high; near within tolerance (±RM0.10) = medium  
- Time proximity: within X minutes = stronger (tunable)  
- Uniqueness: if only one candidate order matches that amount/time window → boost  
- Sequence sanity: payments should generally align with chronological orders

**Layer three: assignment**  
- Use greedy assignment when volumes are low (MVP)  
- Upgrade to bipartite matching (Hungarian / min-cost max-flow) when scaling (v1.5)

**Layer four: ambiguity surfacing**  
If multiple plausible matches exist, show:
- “Possible matches” list  
- Confidence label (High/Med/Low)  
- Why it’s ambiguous (same totals appear twice, missing timestamps, etc.)

**Confidence scoring and explainability**  
Confidence is not a single number. It should be a structured explanation:  
- `confidence_level`: High/Med/Low  
- `reasons`: [“Exact amount match”, “2 min apart”, “Unique candidate”]  
- `evidence_links`: screenshot crop + order breakdown

This is aligned with the region’s trust barriers: micro-merchants lose confidence when tools feel opaque, when fees appear unexpectedly, or when recourse is slow/time-consuming. citeturn27view0

## Screen-by-screen MVP UX

**Interaction principles (must be felt in every screen)**  
- **Fast during rush**: 1–3 taps per item, minimal navigation  
- **Low literacy tolerance**: icon + color + large hit targets, bilingual later  
- **Trust-first**: every number can be traced back to evidence  
- **Editable**: user can always correct, and system learns locally over time  
- **Offline-first**: capture always works; processing degrades gracefully

**MVP screen list (wireframe-level breakdown)**  

| Screen | Purpose | Main UI elements | Empty state | Error/unresolved behavior |
|---|---|---|---|---|
| Home (Today) | “Single source of truth” for today | Big: Today total (draft), Cash estimate, Digital total; “Start Selling”; “Import Payments”; “Review Unmatched” | Shows “Start your first day” + 60s setup CTA | If data incomplete, show “Draft” badge + “Finish reconciliation” CTA |
| Quick Setup | Add menu items fast | Item name + price; “Add common items” presets; “Done” | Suggest defaults: “Bihun”, “Mee”, “Teh ais” | Validation: price missing/invalid |
| Selling Mode | Capture orders fast | Big item buttons; order tray; auto total; “Done”; “Undo”; “Repeat last” | Shows “Tap items to build an order” | If user exits mid-order, save as “open order” |
| Import Payments | Add screenshots | Gallery multi-select; recent suggestions; “Process now” | “No screenshots yet—open your wallet history and screenshot” | If OCR fails: show “Needs clearer image” + tips |
| Processing Progress | Show work happening | Step indicators: OCR → Extract → Match | N/A | If offline and model missing: “Process later” with queue |
| Matching Results | Explain matches | List of payments with matched order; confidence badges; tap row for “Why” | If none: “No payments found—import screenshots” | Ambiguous: label “Needs review” |
| Unmatched Queue | Resolve issues | Tabs: Unmatched Payments / Unmatched Orders | “All matched—great!” | Quick actions: “Match manually”, “Mark as cash-only”, “Delete duplicate” |
| Daily Summary | Primary output | Total sales; cash vs digital; items sold; best-seller; “Confirm day” | “Draft summary—import payments or voice recap” | If low confidence: “Estimated” labels + “Review” CTA |
| Edit Match (Detail) | Human-in-the-loop correction | Show payment receipt crop; show order items; dropdown to reassign; manual split | N/A | Audit log entry on every change |
| Voice Recap | Fill gaps | 1-tap record; transcript; extracted suggestions; “Apply changes” | “Record 30 seconds after rush” | If STT uncertain: highlight unclear words; allow manual edit |

**What the Home screen should prioritize (MVP)**  
1) **Today’s draft total** (big)  
2) **Cash estimate vs Digital total** (two cards)  
3) **Unmatched count** (red badge)  
4) One primary CTA depending on state:  
   - If selling ongoing: “Start Selling”  
   - If selling done but not reconciled: “Import Payments”  
   - If imported but unresolved remain: “Review Unmatched”  
   - If all done: “Confirm Day”

**Empty / error / unresolved state behaviors (critical trust UX)**  
- Any number derived from inference must show “Estimated” and a one-tap path to “Why / Fix.”  
- OCR failures must be recoverable: “Retake screenshot,” “Try history view,” “Crop image.”  
- Unmatched payments cannot be silently dropped: must always surface as “money you might miss.”

## Technical architecture, data model, metrics, risks, roadmap

**Mobile-first and offline-first stance (recommendation)**  
Given hawker environments and trust concerns (data privacy, scams, cognitive overload), start **offline-first** with on-device processing where possible. citeturn27view0turn29search1  
Cloud is optional for backup/export and model-heavy tasks later.

**Proposed system architecture (MVP)**  
- **Client (Android-first, then iOS)**  
  - Local DB: SQLite  
  - Evidence store: encrypted file storage for screenshots/audio  
  - On-device OCR: ML Kit Text Recognition (fast, offline) citeturn29search1  
  - On-device speech (if available) or Whisper via lightweight server option citeturn29search2turn29search7  
  - Matching engine runs locally (low volume per day)  
- **Backend (optional for MVP, recommended for v1.5)**  
  - Auth (phone OTP)  
  - Encrypted backup (S3-compatible)  
  - Model services (if Whisper server-side)  
  - Analytics (privacy-preserving, opt-in)

**Suggested rapid MVP stack options**  
- App: Flutter (fast UI, Android/iOS) + `google_mlkit_text_recognition` plugin; or React Native with native ML Kit bridging  
- Local DB: Drift (Flutter) / SQLite  
- Backend (if needed): FastAPI (Python) or NestJS (Node)  
- Storage: Supabase Storage or S3 compatible  
- Whisper option: small Whisper model hosted on a minimal GPU instance (or CPU for short clips) using openai/whisper repo citeturn29search2

**Data model / objects and relationships**  
- `Merchant`: id, stall_name, locale, timezone  
- `MenuItem`: id, merchant_id, name, price, tags, active  
- `OrderEvent`: id, merchant_id, start_ts, end_ts, items[{menu_item_id, qty, unit_price}], total_amount, status(open/closed), created_by  
- `PaymentEvidence`: id, merchant_id, type(screenshot/audio), local_path, created_ts, source_app(optional), hash  
- `PaymentEvent`: id, merchant_id, timestamp, amount, currency, provider, reference, evidence_id, extracted_fields(json), extraction_confidence  
- `MatchRecord`: id, merchant_id, payment_event_id, order_event_id, confidence_level, reasons[], created_ts, edited_ts, edited_by, audit_trail  
- `DailySummary`: id, merchant_id, date, totals{gross,cash_est,digital}, item_counts, unmatched_counts, confirmed(boolean)

**Trust & safety requirements (non-negotiable)**  
- Evidence traceability: every payment number links to its screenshot crop (stored locally by default)  
- Confidence labels: no hidden automation; “Estimated” always visible  
- Corrections: full audit trail; ability to revert  
- Privacy-by-default: on-device processing where possible; cloud backup opt-in  
- Fraud-aware UX: unmatched payments are highlighted as potential “lost money” scenarios, reflecting micro-merchant loss-of-funds fears. citeturn27view0

**Success metrics (MVP)**  
- Activation: % who complete setup + record ≥10 orders in first week  
- Daily usage: DAU/WAU among onboarded merchants  
- Capture: % of days with both taps and at least one payment screenshot  
- Matching: % of PaymentEvents matched; distribution by confidence level  
- Resolution: reduction in unmatched count after user review  
- Accuracy proxy: merchant-confirmed daily total vs their own end-of-day cash count + wallet totals (self-reported)  
- Time saved: self-reported minutes saved vs manual checking

**Key risks and mitigation**  
- Merchants won’t tap during rush → mitigate with combo buttons, repeat-last, and forgiving segmentation; voice recap to fill gaps (Should).  
- OCR variability across wallet UIs → start with a small set of common formats; support “history screenshot” parsing; provide crop tools.  
- Ambiguous matching when many identical totals occur → show “needs review” rather than guessing; emphasize trust-first.  
- Trust/privacy concerns → default on-device processing, transparent explanations, no surprise uploads; aligns with ASEAN trust-barrier findings. citeturn27view0  
- Competition from POS → clarify category: we’re not competing on inventory/loyalty; we compete on “first-mile reconciliation under imperfect capture.”

**Extensibility beyond fried bihun (why this wedge scales)**  
The pattern generalizes wherever merchants have: repetitive SKUs + mixed cash/QR + limited logging time. Penang Institute’s hawker sample included both F&B and market produce hawkers, suggesting adjacent applicability. citeturn10view0  
Next verticals: drinks stalls (simple menu), kuih sellers (many SKUs but repetitive), fruit/veg (weight-based pricing—requires later enhancements), fish/meat (higher ticket, fewer transactions).

**Roadmap**  
- MVP (hackathon): taps + screenshot OCR + matching + daily summary + unresolved + edit trail  
- v1.5: voice recap + learning common bundles + weekly insights + export + light backup  
- v2: chat ingestion, integrations with select acquirer exports, expense capture, profit estimate, lender-ready “business snapshot”

**Final recommendation (judge/investor narrative)**  
This is a strong wedge because it targets the **first-mile invisibility** problem WEF highlights—businesses without continuous digital footprints remain underserved. citeturn18view0  
It is also grounded in real adoption constraints documented among hawkers (time/effort costs, onboarding gaps, cybersecurity concerns). citeturn10view0  
Your moat is not “LLM chat,” but the **reconciliation engine + trust layer + workflow-native multimodal capture**, built for the messy reality of micro merchants and aligned with known trust barriers in ASEAN digital payments. citeturn27view0turn29search1