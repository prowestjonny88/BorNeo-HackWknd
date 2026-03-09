-- ============================================================
-- Migration 003: Complete schema
-- Adds missing user_id columns to 001 tables, creates missing
-- tables (daily_evidence, extraction_records, transcript_records,
-- tap_entries), enables RLS on all tables, and configures Storage.
-- ============================================================

-- ──────────────────────────────────────────────────────────────
-- 1. updated_at helper trigger function
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

-- ──────────────────────────────────────────────────────────────
-- 2. Backfill user_id on tables from migration 001
-- ──────────────────────────────────────────────────────────────
ALTER TABLE merchants
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE order_events
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE payment_evidences
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE payment_events
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

ALTER TABLE match_records
  ADD COLUMN IF NOT EXISTS user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- correction_records: add user_id + field-level correction columns
-- (day_id / field_name / old_value / new_value) alongside the
-- existing match-level columns from 001 (both sets are nullable)
ALTER TABLE correction_records
  ADD COLUMN IF NOT EXISTS user_id     UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  ADD COLUMN IF NOT EXISTS day_id      TEXT,
  ADD COLUMN IF NOT EXISTS field_name  TEXT,
  ADD COLUMN IF NOT EXISTS old_value   TEXT,
  ADD COLUMN IF NOT EXISTS new_value   TEXT,
  ADD COLUMN IF NOT EXISTS timestamp   TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- ──────────────────────────────────────────────────────────────
-- 3. New tables
-- ──────────────────────────────────────────────────────────────

-- Evidence files (screenshots, audio, e-wallet exports)
CREATE TABLE IF NOT EXISTS daily_evidence (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID        REFERENCES auth.users(id) ON DELETE CASCADE,
  type        TEXT        NOT NULL,  -- 'screenshot' | 'audio' | 'export'
  file_path   TEXT        NOT NULL,
  storage_url TEXT,
  timestamp   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- OCR / export-parsing results
CREATE TABLE IF NOT EXISTS extraction_records (
  id               UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id          UUID        REFERENCES auth.users(id) ON DELETE CASCADE,
  evidence_id      UUID        REFERENCES daily_evidence(id) ON DELETE SET NULL,
  raw_text         TEXT        NOT NULL,
  amount           NUMERIC     NOT NULL DEFAULT 0,
  reference_number TEXT        NOT NULL DEFAULT '',
  confidence       NUMERIC     NOT NULL DEFAULT 0,
  status           TEXT        NOT NULL DEFAULT 'pending',
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Voice-recap transcriptions and parsed summaries
CREATE TABLE IF NOT EXISTS transcript_records (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID        REFERENCES auth.users(id) ON DELETE CASCADE,
  evidence_id UUID        REFERENCES daily_evidence(id) ON DELETE SET NULL,
  raw_text    TEXT        NOT NULL,
  parsed_json JSONB,
  confidence  NUMERIC     NOT NULL DEFAULT 0,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Live tap entries during selling
CREATE TABLE IF NOT EXISTS tap_entries (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      UUID        REFERENCES auth.users(id) ON DELETE CASCADE,
  menu_item_id UUID,
  amount       NUMERIC     NOT NULL DEFAULT 0,
  timestamp    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ──────────────────────────────────────────────────────────────
-- 4. Indexes
-- ──────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS merchants_user_id_idx         ON merchants(user_id);
CREATE INDEX IF NOT EXISTS order_events_user_id_idx      ON order_events(user_id);
CREATE INDEX IF NOT EXISTS payment_evidences_user_id_idx ON payment_evidences(user_id);
CREATE INDEX IF NOT EXISTS payment_events_user_id_idx    ON payment_events(user_id);
CREATE INDEX IF NOT EXISTS match_records_user_id_idx     ON match_records(user_id);
CREATE INDEX IF NOT EXISTS correction_records_user_id_idx ON correction_records(user_id);
CREATE INDEX IF NOT EXISTS daily_evidence_user_id_idx    ON daily_evidence(user_id);
CREATE INDEX IF NOT EXISTS extraction_records_user_id_idx ON extraction_records(user_id);
CREATE INDEX IF NOT EXISTS transcript_records_user_id_idx ON transcript_records(user_id);
CREATE INDEX IF NOT EXISTS tap_entries_user_id_idx       ON tap_entries(user_id);

-- ──────────────────────────────────────────────────────────────
-- 5. updated_at triggers
-- ──────────────────────────────────────────────────────────────
DO $$
DECLARE
  t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'merchants','order_events','payment_evidences','payment_events',
    'match_records','correction_records',
    'daily_evidence','extraction_records','transcript_records'
  ] LOOP
    EXECUTE format(
      'DROP TRIGGER IF EXISTS trg_%1$s_updated_at ON %1$s;
       CREATE TRIGGER trg_%1$s_updated_at
         BEFORE UPDATE ON %1$s
         FOR EACH ROW EXECUTE FUNCTION update_updated_at();',
      t
    );
  END LOOP;
END;
$$;

-- ──────────────────────────────────────────────────────────────
-- 6. Row Level Security
-- ──────────────────────────────────────────────────────────────
ALTER TABLE merchants           ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_events        ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_evidences   ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_events      ENABLE ROW LEVEL SECURITY;
ALTER TABLE match_records       ENABLE ROW LEVEL SECURITY;
ALTER TABLE correction_records  ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_evidence      ENABLE ROW LEVEL SECURITY;
ALTER TABLE extraction_records  ENABLE ROW LEVEL SECURITY;
ALTER TABLE transcript_records  ENABLE ROW LEVEL SECURITY;
ALTER TABLE tap_entries         ENABLE ROW LEVEL SECURITY;

-- merchants
DROP POLICY IF EXISTS "merchants_select_own" ON merchants;
CREATE POLICY "merchants_select_own" ON merchants
  FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "merchants_write_own" ON merchants;
CREATE POLICY "merchants_write_own" ON merchants
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- order_events
DROP POLICY IF EXISTS "order_events_select_own" ON order_events;
CREATE POLICY "order_events_select_own" ON order_events
  FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "order_events_write_own" ON order_events;
CREATE POLICY "order_events_write_own" ON order_events
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- payment_evidences
DROP POLICY IF EXISTS "payment_evidences_select_own" ON payment_evidences;
CREATE POLICY "payment_evidences_select_own" ON payment_evidences
  FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "payment_evidences_write_own" ON payment_evidences;
CREATE POLICY "payment_evidences_write_own" ON payment_evidences
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- payment_events
DROP POLICY IF EXISTS "payment_events_select_own" ON payment_events;
CREATE POLICY "payment_events_select_own" ON payment_events
  FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "payment_events_write_own" ON payment_events;
CREATE POLICY "payment_events_write_own" ON payment_events
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- match_records
DROP POLICY IF EXISTS "match_records_select_own" ON match_records;
CREATE POLICY "match_records_select_own" ON match_records
  FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "match_records_write_own" ON match_records;
CREATE POLICY "match_records_write_own" ON match_records
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- correction_records
DROP POLICY IF EXISTS "correction_records_select_own" ON correction_records;
CREATE POLICY "correction_records_select_own" ON correction_records
  FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "correction_records_write_own" ON correction_records;
CREATE POLICY "correction_records_write_own" ON correction_records
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- daily_evidence
DROP POLICY IF EXISTS "daily_evidence_select_own" ON daily_evidence;
CREATE POLICY "daily_evidence_select_own" ON daily_evidence
  FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "daily_evidence_write_own" ON daily_evidence;
CREATE POLICY "daily_evidence_write_own" ON daily_evidence
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- extraction_records
DROP POLICY IF EXISTS "extraction_records_select_own" ON extraction_records;
CREATE POLICY "extraction_records_select_own" ON extraction_records
  FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "extraction_records_write_own" ON extraction_records;
CREATE POLICY "extraction_records_write_own" ON extraction_records
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- transcript_records
DROP POLICY IF EXISTS "transcript_records_select_own" ON transcript_records;
CREATE POLICY "transcript_records_select_own" ON transcript_records
  FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "transcript_records_write_own" ON transcript_records;
CREATE POLICY "transcript_records_write_own" ON transcript_records
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- tap_entries
DROP POLICY IF EXISTS "tap_entries_select_own" ON tap_entries;
CREATE POLICY "tap_entries_select_own" ON tap_entries
  FOR SELECT USING (auth.uid() = user_id);
DROP POLICY IF EXISTS "tap_entries_write_own" ON tap_entries;
CREATE POLICY "tap_entries_write_own" ON tap_entries
  FOR ALL USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ──────────────────────────────────────────────────────────────
-- 7. Auto-create profile on sign-up
-- ──────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO profiles (id, display_name, business_name, business_type, email, preferred_language)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'business_name', ''),
    COALESCE(NEW.raw_user_meta_data->>'business_type', 'food_stall'),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'preferred_language', 'English')
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ──────────────────────────────────────────────────────────────
-- 8. Storage bucket for evidence files
-- ──────────────────────────────────────────────────────────────
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'evidence',
  'evidence',
  false,
  52428800,  -- 50 MB per file
  ARRAY['image/jpeg','image/png','image/webp','image/heic','audio/m4a','audio/mpeg','audio/wav','application/pdf']
)
ON CONFLICT (id) DO NOTHING;

-- Storage RLS: users can only access their own folder (evidence/<user_id>/...)
DROP POLICY IF EXISTS "evidence_insert_own" ON storage.objects;
CREATE POLICY "evidence_insert_own" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'evidence'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

DROP POLICY IF EXISTS "evidence_select_own" ON storage.objects;
CREATE POLICY "evidence_select_own" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'evidence'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

DROP POLICY IF EXISTS "evidence_update_own" ON storage.objects;
CREATE POLICY "evidence_update_own" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'evidence'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

DROP POLICY IF EXISTS "evidence_delete_own" ON storage.objects;
CREATE POLICY "evidence_delete_own" ON storage.objects
  FOR DELETE USING (
    bucket_id = 'evidence'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );
