-- Personas are no longer part of NexSpend's single-user product model.
drop trigger if exists on_auth_user_created on auth.users;
drop function if exists public.create_profile_for_new_user();
drop table if exists public.profiles;
