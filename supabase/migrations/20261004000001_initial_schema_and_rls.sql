-- ==============================================================================
-- Migration: 20261004000001_initial_schema_and_rls.sql
-- Description: Creates custom enums, profiles and todos tables, indexes, 
--              automated triggers, and comprehensive Row Level Security (RLS) policies.
-- ==============================================================================

-- 1. Custom Types / Enums
CREATE TYPE public.todo_status AS ENUM ('TODO', 'IN_PROGRESS', 'COMPLETED');
CREATE TYPE public.todo_priority AS ENUM ('LOW', 'MEDIUM', 'HIGH');

-- 2. Profiles Table
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL CHECK (char_length(trim(full_name)) >= 2),
    email TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Index for profile queries
CREATE INDEX idx_profiles_email ON public.profiles(email);

-- 3. Todos Table
CREATE TABLE public.todos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL CHECK (char_length(trim(title)) > 0),
    description TEXT NOT NULL DEFAULT '',
    status public.todo_status NOT NULL DEFAULT 'TODO',
    priority public.todo_priority NOT NULL DEFAULT 'MEDIUM',
    due_date TIMESTAMPTZ,
    category TEXT NOT NULL DEFAULT 'General',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    completed_at TIMESTAMPTZ
);

-- Indexes for performance, multi-field filtering, and user isolation
CREATE INDEX idx_todos_user_id ON public.todos(user_id);
CREATE INDEX idx_todos_user_status ON public.todos(user_id, status);
CREATE INDEX idx_todos_user_priority ON public.todos(user_id, priority);
CREATE INDEX idx_todos_user_due_date ON public.todos(user_id, due_date);
CREATE INDEX idx_todos_user_category ON public.todos(user_id, category);

-- 4. Helper Function & Trigger: Automatic updated_at timestamping
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.updated_at = timezone('utc'::text, now());
    RETURN NEW;
END;
$$;

CREATE TRIGGER update_profiles_modtime
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER update_todos_modtime
    BEFORE UPDATE ON public.todos
    FOR EACH ROW
    EXECUTE FUNCTION public.set_updated_at();

-- 5. Helper Function & Trigger: Automatic completed_at timestamping
CREATE OR REPLACE FUNCTION public.handle_todo_completion_status()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
    IF NEW.status = 'COMPLETED' AND (OLD.status IS DISTINCT FROM 'COMPLETED' OR NEW.completed_at IS NULL) THEN
        NEW.completed_at = timezone('utc'::text, now());
    ELSIF NEW.status <> 'COMPLETED' THEN
        NEW.completed_at = NULL;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trigger_todo_completion_status
    BEFORE INSERT OR UPDATE ON public.todos
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_todo_completion_status();

-- 6. New User Trigger: Synchronizes auth.users to public.profiles
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = public
AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, email)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'full_name', 'User'),
        COALESCE(NEW.email, '')
    );
    RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- 7. Row Level Security (RLS) Enablement
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.todos ENABLE ROW LEVEL SECURITY;

-- 8. RLS Policies: Profiles
-- SELECT: Users can only view their own profile
CREATE POLICY "Users can view own profile"
    ON public.profiles
    FOR SELECT
    TO authenticated
    USING ( (select auth.uid()) = id );

-- UPDATE: Users can only update their own profile
CREATE POLICY "Users can update own profile"
    ON public.profiles
    FOR UPDATE
    TO authenticated
    USING ( (select auth.uid()) = id )
    WITH CHECK ( (select auth.uid()) = id );

-- 9. RLS Policies: Todos
-- SELECT: Users can only view their own todos
CREATE POLICY "Users can view own todos"
    ON public.todos
    FOR SELECT
    TO authenticated
    USING ( (select auth.uid()) = user_id );

-- INSERT: Users can only insert todos with their own user_id
CREATE POLICY "Users can insert own todos"
    ON public.todos
    FOR INSERT
    TO authenticated
    WITH CHECK ( (select auth.uid()) = user_id );

-- UPDATE: Users can only update their own todos
CREATE POLICY "Users can update own todos"
    ON public.todos
    FOR UPDATE
    TO authenticated
    USING ( (select auth.uid()) = user_id )
    WITH CHECK ( (select auth.uid()) = user_id );

-- DELETE: Users can only delete their own todos
CREATE POLICY "Users can delete own todos"
    ON public.todos
    FOR DELETE
    TO authenticated
    USING ( (select auth.uid()) = user_id );
