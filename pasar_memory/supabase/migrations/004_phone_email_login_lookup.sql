-- ============================================================
-- Migration 004: Cross-device phone -> email lookup for login
-- Adds a SECURITY DEFINER RPC function used by clients to resolve
-- an auth email from a normalized phone number.
-- ============================================================

CREATE OR REPLACE FUNCTION public.resolve_login_email_by_phone(input_phone TEXT)
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  normalized_phone TEXT;
  resolved_email TEXT;
BEGIN
  normalized_phone := regexp_replace(COALESCE(input_phone, ''), '[^0-9+]', '', 'g');

  IF normalized_phone = '' THEN
    RETURN NULL;
  END IF;

  SELECT p.email
    INTO resolved_email
  FROM public.profiles p
  WHERE regexp_replace(COALESCE(p.phone, ''), '[^0-9+]', '', 'g') = normalized_phone
  ORDER BY p.updated_at DESC NULLS LAST, p.created_at DESC NULLS LAST
  LIMIT 1;

  RETURN NULLIF(resolved_email, '');
END;
$$;

REVOKE ALL ON FUNCTION public.resolve_login_email_by_phone(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.resolve_login_email_by_phone(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION public.resolve_login_email_by_phone(TEXT) TO authenticated;
