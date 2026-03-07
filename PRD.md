# PRD: Pasar Memory

## Multimodal Sales Reconciliation Copilot for Fresh Market & Hawker Merchants

---

## 1. Executive Summary

### What this product is

Pasar Memory is a **mobile-first, reconciliation-first business memory system** for informal merchants, starting with a **fried bihun hawker / fresh market food seller**. It helps merchants reconstruct actual daily sales across **cash + QR / e-wallet payments** using familiar inputs:

* **tap** to record quick sales
* **screenshots** to capture digital payment evidence
* **voice recap** to fill gaps after rush hour

The product produces a **trusted daily sales summary** instead of forcing merchants into full POS or accounting workflows.

### Who it is for

Primary user:

* hawkers and fresh market merchants with repetitive items
* high-frequency walk-in transactions
* mixed cash and digital payments
* low time for manual logging
* low to moderate digital literacy
* weak or nonexistent bookkeeping habits

### Why now

Digital payment usage is rising rapidly, but many small merchants still operate in mixed-payment environments. They can see some digital transactions in wallet apps, but they still struggle to reconcile:

* what was cash
* what was QR/e-wallet
* what items were actually sold
* whether the final total is accurate

At the same time, hawker digitization remains uneven because existing tools often require:

* setup-heavy workflows
* continuous front-of-house transaction logging
* POS-style discipline
* trust in black-box systems

### Why it matters

This is a **first-mile digitization problem**.

Many MSMEs are not invisible because they lack business activity. They are invisible because their business activity is:

* fragmented
* unstructured
* poorly recorded
* difficult to reuse across formal systems

Pasar Memory helps turn messy daily operations into a **merchant-owned digital business memory**, which can later support:

* clearer operations
* better financial tracking
* grant / financing readiness
* stronger digital visibility

### Key differentiator

Pasar Memory is **not another AI chatbot for SMEs**.

Its differentiation comes from the combination of:

* **multimodal capture**
* **reconciliation engine**
* **trust-first correction flow**
* **merchant-owned business memory**
* **workflow-native design for hawker reality**

It is best understood as a **reconciliation notebook and business memory layer**, not a generic assistant.

---

## 2. Problem Statement

### Core merchant problem

At the end of the day, many hawkers cannot confidently answer:

> “How much did I actually sell today?”

More specifically, they struggle to know:

* total daily sales
* cash total
* digital payment total
* item-level estimates sold
* whether any payments or sales were missed

### Root causes

1. **Transactions happen too fast**

   * Hawkers operate in short rush windows.
   * They do not have time to log every sale precisely.

2. **Payment methods are mixed**

   * Some customers pay cash.
   * Others use QR / e-wallet / bank transfer.
   * Digital history exists only partially, while cash often leaves no trace.

3. **Evidence is fragmented**

   * payment screenshots
   * wallet notifications
   * memory
   * handwritten notes
   * mental totals
   * occasional receipt photos

4. **Existing tools assume structured behavior**

   * POS systems assume each sale goes through the system.
   * accounting tools assume merchants are willing to maintain records consistently.
   * wallet dashboards only show digital transactions.

5. **Trust and effort remain barriers**

   * merchants worry about mistakes, hidden complexity, privacy, and wasted time
   * if the tool feels hard or unreliable, they abandon it quickly

### Why current solutions are insufficient

Current solutions are generally:

* **POS-first**
* **channel-specific**
* **logging-first**
* **too heavy for informal merchants**

They usually do not solve the real hawker problem:

> reconstructing the truth from incomplete evidence after a messy day of business

### Why this matters operationally and economically

Operationally, unclear records hurt:

* daily planning
* product prep for tomorrow
* cash management
* confidence in actual earnings

Strategically, lack of structured records prevents merchants from building a digital footprint that could later support:

* financing readiness
* participation in more formal ecosystems
* better merchant support programs

---

## 3. Target User

### Primary persona

**Name:** Kak Lina
**Role:** Fried bihun hawker
**Location:** Fresh market / pasar pagi / roadside food stall
**Business type:** Walk-in, repetitive menu, high-volume short bursts

### Daily operating context

* opens early in the morning
* has breakfast rushes
* sells a small number of common items
* accepts both cash and QR/e-wallet payments
* often works with minimal staff
* relies on speed and memory rather than formal systems

### Typical products

* fried bihun
* fried mee
* tea / coffee
* kuih / add-ons

### Existing tools / behaviors

* calculator
* cash box
* QR stand / e-wallet merchant QR
* wallet app transaction view
* mental estimates
* sometimes handwritten notes

### Key frustrations

* uncertain end-of-day sales total
* difficult to split cash vs digital revenue accurately
* forgets some sales during rush periods
* no trustworthy history over time
* POS systems feel too heavy or unnecessary

### Jobs-to-be-done

* Help me know my real daily sales with minimal effort.
* Help me see how much was cash vs digital.
* Help me catch missing or unmatched entries.
* Help me keep a useful history without changing how I work too much.

### Secondary personas

* kuih seller
* beverage stall owner
* fruit seller
* vegetable seller
* fish or meat vendor

These users share similar characteristics but may require different menu and pricing logic later.

---

## 4. Market Analysis

### Market categories around this problem

The current market breaks into five main buckets:

1. **POS systems**
2. **Accounting / bookkeeping systems**
3. **Payment app merchant dashboards**
4. **OCR receipt utilities**
5. **AI merchant assistants inside large ecosystems**

### Competitor map

| Product / Category         | Core strength                           | What it solves well                           | Where it falls short for our use case                               |
| -------------------------- | --------------------------------------- | --------------------------------------------- | ------------------------------------------------------------------- |
| MyInvois e-POS             | Free structured POS + e-invoicing       | formal sales recording, reporting, compliance | assumes POS discipline and consistent usage                         |
| StoreHub                   | Full-featured retail/F&B ops platform   | POS, inventory, growth tools                  | too heavy for first-mile informal merchants                         |
| MePOS                      | Offline-capable POS                     | structured transaction recording, reporting   | still logging-first, not reconstruction-first                       |
| RakyatPOS                  | SME POS with e-invoice support          | structured checkout and operations            | not built for messy, partial evidence reconciliation                |
| Merchant wallet dashboards | Digital transaction visibility          | transaction history, settlement reporting     | only covers digital payments, no cash or item inference             |
| ReceiptLah                 | OCR utility                             | receipt scanning and categorization           | expense-focused, not mixed sales reconciliation                     |
| Grab Merchant tools        | AI and merchant operations in ecosystem | platform-specific business help               | closed ecosystem, not designed for informal walk-in cash-heavy flow |
| Lazada seller tools        | AI e-commerce assistance                | listing, seller analytics, online selling     | irrelevant to offline hawker flow                                   |
| QuickBooks / Intuit AI     | AI accounting workflows                 | digitized SMB back-office support             | assumes existing digital accounting behavior                        |
| Xero JAX                   | AI accounting copilot                   | insights and structured accounting tasks      | assumes Xero adoption and higher digital maturity                   |
| SleekFlow                  | chat-driven CRM automation              | customer messaging and conversion             | does not solve mixed-payment reconciliation                         |
| BukuWarung                 | micro-merchant digital bookkeeping      | lightweight merchant tools                    | closer in spirit, but still not this exact Malaysia hawker wedge    |

### Direct vs indirect competition

#### Direct competitors

There is **no strong direct competitor** that clearly owns this exact wedge:

* hawker / fresh market user
* mixed cash + QR
* tap + screenshot + voice inputs
* daily sales summary as hero output
* reconciliation-first logic

#### Indirect competitors

Most adjacent products compete only partially:

* POS tools solve structured logging
* wallet dashboards solve digital payment visibility
* accounting tools solve back-office bookkeeping
* OCR apps solve data extraction

### Whitespace / opportunity gap

The strongest opportunity is:

## **adjacent-crowded, exact-wedge-open**

The market is validated, but the specific wedge remains underbuilt.

### Why this is not “just another AI wrapper”

Pasar Memory is not differentiated by generic conversation or content generation.

Its core moat is the combination of:

* **multimodal evidence capture**
* **matching and reconciliation logic**
* **traceable, editable outputs**
* **merchant-owned daily business history**

The defensible asset is the **reconstructed merchant operating record**, not the chat UI.

---

## 5. Product Vision and Positioning

### Recommended category framing

Best category framing:

## **Reconciliation notebook + business memory layer**

This is stronger than:

* lightweight POS alternative
* generic AI assistant
* accounting app

### Why this framing works

* It is lighter than POS.
* It is more useful than a ledger.
* It fits incomplete inputs.
* It emphasizes truth reconstruction instead of perfect logging.

### Recommended positioning statement

**Pasar Memory helps hawkers reconstruct real daily sales across cash and QR using taps, screenshots, and voice — so they always know today’s true numbers.**

### Differentiation thesis

Pasar Memory wins by doing four things together:

1. capture messy real-world merchant evidence
2. reconcile incomplete signals into one daily truth
3. explain results with confidence and traceability
4. accumulate that daily truth into long-term business memory

---

## 6. Scope Definition

### What the MVP solves

The MVP solves a narrow but meaningful problem:

> It helps a fried bihun seller produce a trusted daily sales summary across cash + QR using tap, screenshot, and voice inputs.

### What the MVP does not solve

The MVP does **not** try to become:

* full POS
* full accounting software
* inventory management system
* financing product
* e-invoicing platform
* cross-border trade tool
* customer messaging platform

### Non-goals

* no automated lending or credit scoring
* no supplier management
* no payroll
* no full profit-and-loss accounting
* no complex CRM
* no attempt to replace every merchant app

---

## 7. User Stories / JTBD

* As a hawker, I want to tap common items quickly so I can capture sales during a rush.
* As a hawker, I want to upload QR/e-wallet payment screenshots so digital sales can be counted automatically.
* As a hawker, I want to record a short voice recap after rush hour so I can fill in what I missed.
* As a hawker, I want the app to match my sales and payments with confidence labels so I know what to trust.
* As a hawker, I want unresolved or unmatched entries to be clearly shown so I can fix missing records.
* As a hawker, I want one daily summary screen so I can understand my business in minutes.
* As a hawker, I want my confirmed daily record saved over time so I can build a business history without doing formal bookkeeping.

---

## 8. Core Product Flows

### 8.1 Onboarding / setup

1. Merchant creates profile.
2. Merchant chooses business type template.
3. Merchant adds menu items and prices.
4. Merchant selects accepted payment methods.
5. Merchant enters Today home screen.

### 8.2 Sales capture flow

1. Merchant taps common items.
2. App builds an order tray and total.
3. Merchant taps Done.
4. Order event is saved with timestamp.

### 8.3 Payment screenshot ingestion flow

1. Merchant uploads screenshot(s) from gallery or share sheet.
2. App runs OCR.
3. App extracts amount, timestamp, provider, and reference if available.
4. Payment event is created.
5. Matching engine runs.

### 8.4 Voice recap flow

1. Merchant records short voice note after rush.
2. App transcribes audio.
3. App extracts item quantities / cash hints / corrections.
4. App proposes adjustments.
5. Merchant confirms or edits.

### 8.5 Reconciliation flow

1. App compares order events, payment events, and voice recap signals.
2. App produces:

   * matched entries
   * likely cash-only sales
   * unresolved transactions
3. Merchant reviews issues.
4. Merchant confirms or edits.

### 8.6 Daily summary flow

1. App aggregates confirmed and estimated values.
2. App shows:

   * total daily sales
   * digital payment total
   * cash estimate
   * item counts sold
   * best-selling item
   * unresolved items count
3. Merchant confirms day.
4. Day is written into business memory timeline.

### 8.7 Correction flow

1. Merchant opens a match or unresolved entry.
2. App shows source evidence.
3. Merchant changes assignment / total / item details.
4. App updates summary.
5. Correction is saved into audit trail.

---

## 9. Detailed Feature Requirements

### 9.1 Merchant setup

**Description:** Fast onboarding for item and price setup.
**User value:** Makes the product usable in under 2 minutes.
**Functional requirements:**

* create merchant profile
* add/edit menu items
* set prices
* create simple templates
* select payment methods

**Edge cases:**

* merchant changes price mid-day
* item temporarily unavailable

**Dependencies:** local storage, onboarding UI
**Priority:** Must

### 9.2 Tap-to-capture order

**Description:** Large buttons for fast item entry.
**User value:** Minimal friction during busy selling periods.
**Functional requirements:**

* large item buttons
* quantity increment
* quick order tray
* Done button
* Undo / Repeat Last
* timestamp capture

**Edge cases:**

* user exits without finishing order
* accidental tap

**Dependencies:** menu setup
**Priority:** Must

### 9.3 Screenshot import

**Description:** Import payment screenshots as evidence.
**User value:** Lets merchants use existing digital payment proofs instead of retyping.
**Functional requirements:**

* gallery import
* multi-select
* share-sheet support
* local evidence storage

**Edge cases:**

* blurry screenshot
* cropped screenshot
* unsupported payment layout

**Dependencies:** OCR engine
**Priority:** Must

### 9.4 OCR extraction

**Description:** Extract structured data from screenshots.
**User value:** Reduces manual logging of digital payments.
**Functional requirements:**

* detect amount
* detect timestamp
* detect provider / wallet label
* capture raw text
* store source link to screenshot

**Edge cases:**

* multi-transaction history view
* mixed languages
* partial screenshot

**Dependencies:** OCR model, parsing rules
**Priority:** Must

### 9.5 Matching and reconciliation engine

**Description:** Match digital payments to likely order events and infer daily totals.
**User value:** Core product intelligence; reconstructs the truth.
**Functional requirements:**

* amount-based matching
* timestamp proximity logic
* uniqueness scoring
* unresolved queue generation
* duplicate detection
* cash vs digital split

**Edge cases:**

* repeated same-value sales
* missing taps
* delayed screenshot upload
* ambiguous matches

**Dependencies:** order data, OCR data, rules engine
**Priority:** Must

### 9.6 Confidence + explainability layer

**Description:** Show why the system matched entries.
**User value:** Builds trust and reduces black-box feeling.
**Functional requirements:**

* confidence badge
* match reasons list
* evidence traceability
* estimated vs confirmed labels

**Edge cases:**

* low-confidence results dominating the screen

**Dependencies:** reconciliation engine
**Priority:** Must

### 9.7 Unresolved queue

**Description:** Surface unmatched transactions and incomplete events.
**User value:** Prevents money loss and hidden errors.
**Functional requirements:**

* unmatched payment list
* unmatched order list
* quick actions to fix
* filters

**Edge cases:**

* too many unresolved items

**Dependencies:** reconciliation engine
**Priority:** Must

### 9.8 Daily summary

**Description:** Primary outcome screen for the merchant.
**User value:** Provides the answer the merchant actually wants.
**Functional requirements:**

* total sales
* digital total
* cash estimate
* item count estimates
* best-selling item
* unresolved count
* confirm day button

**Edge cases:**

* very incomplete day
* summary based mostly on estimates

**Dependencies:** aggregation layer
**Priority:** Must

### 9.9 Correction / audit trail

**Description:** Track user edits and allow reversal.
**User value:** Lets merchant stay in control and trust the system.
**Functional requirements:**

* editable matches
* edit history
* revert
* user-visible correction log

**Edge cases:**

* repeated conflicting edits

**Dependencies:** data model
**Priority:** Must

### 9.10 Voice recap

**Description:** Post-rush speech input for gap-filling.
**User value:** Lets merchants recover missed data without heavy manual entry.
**Functional requirements:**

* record short clip
* transcribe audio
* extract quantities / corrections
* present draft suggestions

**Edge cases:**

* noise
* code-switching
* unclear transcription

**Dependencies:** STT engine
**Priority:** Should

### 9.11 Export summary

**Description:** Share or save end-of-day output.
**User value:** Portable record outside the app.
**Functional requirements:**

* markdown / csv / pdf-friendly export
* simple summary format

**Edge cases:**

* sensitive evidence accidentally included

**Dependencies:** summary layer
**Priority:** Should

### 9.12 Multi-day trends

**Description:** Show weekly patterns and memory growth.
**User value:** Gives long-term value and habit reinforcement.
**Functional requirements:**

* weekly totals
* best day
* average daily sales

**Edge cases:** sparse data
**Dependencies:** historical summaries
**Priority:** Could

---

## 10. AI / Intelligence Requirements

### OCR requirements

* on-device preferred for privacy and offline reliability
* support major Malaysian wallet / QR screenshot patterns first
* extract amount, timestamp, provider, and reference if possible
* store bounding box map or source anchors for explainability

### Speech-to-text requirements

* support Malay + English code-switching for MVP
* short audio clips only
* allow manual text correction after transcription
* highlight uncertain words

### Entity extraction

* item names from merchant menu
* quantities mentioned in speech
* payment amounts from screenshots
* time/date and source app cues

### Matching logic

#### Candidate generation

* generate possible payment-order matches based on amount and time

#### Scoring factors

* exact amount match
* time proximity
* uniqueness of candidate
* consistency with nearby order sequence

#### Assignment logic

* use a simple greedy / rule-based matching system in MVP
* upgrade to graph matching / min-cost assignment later if needed

### Confidence scoring

Confidence should be interpretable, not hidden.

Each match should include:

* confidence level: high / medium / low
* reasons
* evidence source
* whether merchant has confirmed it

### Explainability

The system should always answer:

* why this was matched
* what evidence was used
* what is uncertain

### Model fallback behavior

If OCR / STT fails:

* store evidence anyway
* let merchant review manually
* do not silently discard failed inputs

### Human-in-the-loop design

The merchant must always be able to:

* correct matches
* reassign payments
* mark entry as cash-only or unmatched
* confirm final daily truth

---

## 11. Data Model / System Logic

### Core objects

#### Merchant

* id
* name
* business type
* locale
* timezone

#### MenuItem

* id
* merchant_id
* name
* price
* active
* tags

#### OrderEvent

* id
* merchant_id
* timestamp_start
* timestamp_end
* items[]
* total_amount
* source = tap / voice-adjusted
* status

#### PaymentEvidence

* id
* merchant_id
* type = screenshot / audio / receipt
* local_path
* source_app
* created_at
* hash

#### PaymentEvent

* id
* merchant_id
* evidence_id
* amount
* timestamp
* provider
* reference
* raw_text
* extraction_confidence

#### MatchRecord

* id
* order_event_id
* payment_event_id
* confidence_level
* reasons[]
* created_at
* edited_at
* audit_log

#### CorrectionRecord

* id
* target_type
* target_id
* old_value
* new_value
* edited_by
* edited_at
* reason_optional

#### DailySummary

* id
* merchant_id
* date
* gross_sales
* digital_total
* cash_estimate
* item_counts
* unmatched_count
* confirmed

### Key system logic

1. Orders are captured as events.
2. Screenshots become payment evidence.
3. OCR turns evidence into payment events.
4. Matching engine links payment events and orders.
5. Unmatched entries stay visible.
6. Merchant corrections update the summary.
7. Final day confirmation writes one daily truth into memory.

---

## 12. Trust and Safety Requirements

### Core trust requirements

* every inferred number must be traceable
* every uncertain result must be visibly labeled
* merchant must be able to fix anything
* no silent automation for ambiguous cases

### Confidence labels

* High = likely safe to trust
* Medium = likely correct but worth checking
* Low = needs review

### Source traceability

Every summary or match should link back to:

* source screenshot
* source order event
* source voice recap

### Correction audit trail

* every manual edit is recorded
* merchant can review what changed
* merchant can revert mistakes

### Data privacy expectations

* evidence stays local by default where possible
* cloud backup should be opt-in
* screenshot and audio handling should be explicit

### False match handling

* ambiguous matches should go to unresolved queue
* system should prefer “needs review” over false certainty

### Merchant confidence UX

* use plain language
* show “estimated” vs “confirmed” clearly
* prioritize transparency over over-automation

---

## 13. UX / Interaction Principles

### Low-friction

The app should require the fewest possible actions during rush hour.

### Fast during rush

* large buttons
* minimal text entry
* one-screen selling mode

### Usable for low-tech merchants

* simple language
* obvious CTAs
* strong visual cues
* not too many tabs or charts

### Minimal cognitive load

* one main screen for today
* one main task per state
* clear unresolved queue

### Local-language considerations

* Malay-first or bilingual-ready
* code-switching support in voice transcription later

### Image / voice / tap balance

* **tap** for live capture
* **screenshot** for hard payment evidence
* **voice** for post-rush recovery

This three-part balance is core to the product.

---

## 14. MVP Scope

### Must-have

* merchant setup
* menu + price setup
* tap-to-capture orders
* screenshot import
* OCR extraction
* matching engine
* unresolved queue
* daily sales summary
* correction flow
* confidence + traceability

### Nice-to-have

* voice recap
* export summary
* weekly summary
* repeat-last order shortcut
* batch screenshot parsing

### Out of scope

* full inventory
* profit and loss
* e-invoice generation
* financing / underwriting
* supplier workflows
* chat order ingestion
* direct bank/wallet integrations

---

## 15. Success Metrics

### Usage metrics

* setup completion rate
* daily active merchants
* weekly retention

### Capture metrics

* percentage of active days with at least one tap entry
* percentage of active days with payment evidence imported
* number of days confirmed by merchant

### Matching metrics

* percentage of payment events matched
* unresolved queue size before and after review
* proportion of high / medium / low confidence matches

### Accuracy metrics

* merchant-confirmed accuracy of daily summary
* discrepancy between draft and confirmed total

### Efficiency metrics

* self-reported time saved versus manual checking
* number of corrections needed per day

### Business memory metrics

* number of confirmed days stored
* growth in completeness of merchant history over time

---

## 16. Risks and Open Questions

### Key risks

1. **Poor OCR quality**

   * wallet UIs vary
   * screenshots may be blurry or cropped

2. **Ambiguous payment-item matching**

   * repeated same-value orders create confusion

3. **Merchant unwillingness to tap during rush**

   * live capture may still feel like too much effort

4. **Voice input may be noisy**

   * wet markets can be loud
   * STT may be imperfect

5. **Over-automation risk**

   * false certainty will destroy trust quickly

6. **Scope creep toward POS/accounting**

   * strong temptation to add too many SMB features too early

7. **Generalization risk**

   * a fried bihun seller is a good wedge, but some merchant types have different pricing structures

### Open questions

* Is live tapping realistic for the majority of target hawkers, or only some?
* Should the first version prioritize individual payment screenshots or transaction-history screenshots?
* Is voice recap core enough for MVP, or better as v1.5?
* Which wallet providers should be supported first?
* Will merchants prefer a notebook metaphor or a mini-POS metaphor?

---

## 17. Roadmap

### MVP

Focus on one believable end-to-end loop:

* menu setup
* tap capture
* screenshot OCR
* matching
* daily summary
* unresolved queue
* correction trail

### v1.5

Expand reliability and habit value:

* voice recap
* weekly summary
* export
* common bundle learning
* better unresolved resolution tools

### v2

Expand into broader business memory and optional integrations:

* expense capture
* simple net sales estimate
* business passport / shareable merchant summary
* wallet export integrations
* richer merchant trend analysis

---

## 18. Final Recommendation

### Is this a strong enough wedge?

Yes.

This is a strong wedge because it is:

* specific enough to build and demo
* grounded in real merchant pain
* adjacent to existing software categories without being swallowed by them
* extensible to other fresh market merchant types

### Strongest differentiator

The strongest differentiator is not any single AI feature.

It is the combination of:

* **multimodal capture**
* **reconciliation-first system logic**
* **trust-first explainability**
* **merchant-owned business memory**

### Best narrative for judges / investors / stakeholders

**Pasar Memory solves the missing first mile of digitization for informal merchants. Instead of forcing hawkers to adopt full POS or accounting software, it helps them reconstruct the truth of daily business from taps, payment screenshots, and voice — turning messy daily activity into a trusted business record.**

That is what makes it practical, differentiated, and more than an AI wrapper.
