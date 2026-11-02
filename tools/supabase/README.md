# Progress tracking with Supabase

Today every student's progress lives in their own browser's localStorage: it is
lost when they switch devices or clear the browser, and the coach cannot see any
of it. This replaces that with a real database the students sign in to.

## What gets stored

One row per answered question: who, which event, which question id, the topic,
the difficulty, right or wrong, what they entered, and how long they took.
That is enough to answer "who is practising", "which topics are weak across the
team", and "which questions almost everyone gets wrong" (usually a sign the
explanation needs work).

## Setup

**1. Create the project.** supabase.com, new project, region West US. Free tier
is far more than this needs.

**2. Create the tables.** SQL editor, paste all of `schema.sql`, run.

**3. Add the roster.** Nobody can sign up unless their email is listed first,
so the pages can stay public. In the SQL editor:

```sql
insert into public.roster (email, display_name) values
  ('student1@example.com', 'Jayden C.'),
  ('student2@example.com', 'Alex P.');
```

**4. Turn on email sign-in.** Authentication, then Providers, enable Email.
The pages will use a one-time code sent by email rather than a password —
nothing for a student to forget, and no password resets for you to handle.

**5. Make yourself the coach.** The pages do not have sign-in yet, so create
your account from the dashboard: Authentication, then Users, then Add user,
with your own email. Add that email to the roster in step 3 first, or the
signup gate will reject it. Then:

```sql
update public.profiles set is_coach = true
where id = (select id from auth.users where email = 'you@example.com');
```

**6. Send me the Project URL and the anon key.** Settings, then API. The anon
key is designed to sit in public page source — row level security is what
protects the data, not the key. The service role key is the secret one; never
put that anywhere near these pages.

## What the policies allow

- A student can insert their own attempts and read their own attempts.
- A student cannot update or delete an attempt — no erasing a wrong answer.
- A student cannot see anyone else's rows, or the roster.
- The coach reads everything.
- Signup is refused for any email not on the roster.

## Before you start

These are middle school students, so their emails are children's personal
information. Worth checking what your team or school already does about parent
consent before collecting them. Using a parent's email, or a team-issued
address, sidesteps most of it.
