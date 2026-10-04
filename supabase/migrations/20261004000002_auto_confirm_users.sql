-- ==============================================================================
-- Migration: 20261004000002_auto_confirm_users.sql
-- Description: Automatically confirms existing unconfirmed users and sets up a
--              BEFORE INSERT trigger so all future signups are instantly confirmed
--              without sending or requiring email confirmation links.
-- ==============================================================================

-- 1. Confirm all existing users that are currently unconfirmed
UPDATE auth.users
SET email_confirmed_at = timezone('utc'::text, now())
WHERE email_confirmed_at IS NULL;

-- 2. Function to auto-confirm new users at insert time
CREATE OR REPLACE FUNCTION public.auto_confirm_new_users()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public, auth
AS $$
BEGIN
  IF NEW.email_confirmed_at IS NULL THEN
    NEW.email_confirmed_at = timezone('utc'::text, now());
  END IF;
  RETURN NEW;
END;
$$;

-- 3. Trigger to auto-confirm BEFORE INSERT on auth.users
DROP TRIGGER IF EXISTS on_auth_user_auto_confirm ON auth.users;

CREATE TRIGGER on_auth_user_auto_confirm
BEFORE INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.auto_confirm_new_users();
