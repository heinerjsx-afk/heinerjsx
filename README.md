# heinerjsx
My business website 


## HNR admin panel (Supabase)

The admin panel is available at `/admin.html`. It is not active until Supabase is configured.

1. Create a Supabase project.
2. In Supabase SQL Editor, run the contents of `supabase-schema.sql`.
3. In Supabase Authentication, create an administrator user with email/password. Keep public sign-ups disabled.
4. Copy the user's UUID from Authentication > Users and run this in SQL Editor, replacing the placeholder:
   `insert into public.hnr_admins (user_id) values ('YOUR-AUTH-USER-UUID');`
5. Edit `supabase-config.js` with the Supabase project URL and the **publishable** key only. Never put a secret/service-role key in browser code.
6. Deploy the branch on Render to preview, or merge the pull request into `main` when ready.

The storefront reads active database products and adds them to its existing illustrative catalog; database products are stored persistently. The sample “Gorra FR” has **not** been inserted. To add it later, sign in at `/admin.html` and enter the details manually.

Security: the SQL enables Row Level Security. Visitors can read active products; only user IDs explicitly listed in `hnr_admins` can create, edit, hide, or delete products. Review Supabase's Security Advisor before launch.
