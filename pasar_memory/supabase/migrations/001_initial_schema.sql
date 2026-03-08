CREATE TABLE merchants (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  business_type TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE menu_items (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  price NUMERIC NOT NULL,
  is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE order_events (
  id UUID PRIMARY KEY,
  items JSONB NOT NULL,
  total_amount NUMERIC NOT NULL,
  timestamp TIMESTAMPTZ NOT NULL,
  status TEXT DEFAULT 'pending'
);

CREATE TABLE payment_evidences (
  id UUID PRIMARY KEY,
  image_path TEXT NOT NULL,
  imported_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE payment_events (
  id UUID PRIMARY KEY,
  evidence_id UUID REFERENCES payment_evidences(id),
  amount NUMERIC NOT NULL,
  timestamp TIMESTAMPTZ NOT NULL,
  provider_name TEXT NOT NULL,
  reference_number TEXT NOT NULL,
  raw_text TEXT NOT NULL,
  extraction_confidence NUMERIC NOT NULL,
  status TEXT DEFAULT 'unmatched'
);

CREATE TABLE match_records (
  id UUID PRIMARY KEY,
  payment_event_id UUID REFERENCES payment_events(id),
  order_event_id UUID REFERENCES order_events(id),
  confidence_score NUMERIC NOT NULL,
  reasons JSONB NOT NULL,
  matched_at TIMESTAMPTZ NOT NULL,
  is_manual_correction BOOLEAN DEFAULT FALSE
);

CREATE TABLE correction_records (
  id UUID PRIMARY KEY,
  match_record_id UUID REFERENCES match_records(id),
  old_order_event_id UUID REFERENCES order_events(id),
  new_order_event_id UUID REFERENCES order_events(id),
  reason TEXT NOT NULL,
  corrected_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE daily_summaries (
  id UUID PRIMARY KEY,
  date DATE NOT NULL,
  total_sales NUMERIC NOT NULL,
  digital_total NUMERIC NOT NULL,
  cash_estimate NUMERIC NOT NULL,
  unresolved_count INTEGER NOT NULL,
  is_confirmed BOOLEAN DEFAULT FALSE
);