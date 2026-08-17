# Deploying the accept/decline email notification

This sends an email to alex.j@mdf-uk.com whenever a quote's status changes to
`accepted` or `declined`, via a Supabase Edge Function + Resend.

I (Claude) don't have access to your Supabase project or a Resend account, so I
can't deploy this myself — but everything below is copy/paste. Should take
about 10 minutes.

## 1. Get a Resend API key (free)

1. Sign up at https://resend.com (free tier: 3,000 emails/month, no card required).
2. In the Resend dashboard, go to **API Keys** → **Create API Key**.
3. Copy the key (starts with `re_`).

You don't need to verify a domain to test this — Resend's shared sandbox sender
(`onboarding@resend.dev`) works out of the box and can deliver to any address.
Swap it for a verified `@dc-flooring...` address later if you want branded
"from" addresses.

## 2. Install the Supabase CLI and log in

```bash
npm install -g supabase
supabase login
```

This opens a browser to authorize the CLI against your Supabase account.

## 3. Link this folder to your project

```bash
cd "DC Flooring"
supabase link --project-ref <your-project-ref>
```

Your project ref is the subdomain in your Supabase URL — for
`https://lpkdsdfltejgczsuvpay.supabase.co` it's `lpkdsdfltejgczsuvpay`.

## 4. Deploy the function and set the secret

```bash
supabase functions deploy notify-decision
supabase secrets set RESEND_API_KEY=re_your_key_here
```

## 5. Wire it up with a Database Webhook

In the Supabase Dashboard:

1. Go to **Database → Webhooks → Create a new webhook**.
2. Name: `notify-decision`
3. Table: `quotes`
4. Events: **Update** only (leave Insert/Delete unchecked)
5. Type: **Supabase Edge Functions**
6. Edge Function: `notify-decision`
7. HTTP Method: POST, HTTP Headers: leave defaults (the dashboard signs the
   request automatically)
8. Save.

That's it — no SQL needed. The webhook fires on every update to the `quotes`
table; the function itself checks `old_record.status` vs `record.status` and
only sends an email when it actually *changed* to `accepted` or `declined`
(so editing notes on an already-declined quote won't re-notify).

## 6. Test it

Easiest: open the admin panel, open any quote, click **Preview as customer**,
go to the Decision page, and click Accept (or Decline with a reason). Check
alex.j@mdf-uk.com for the email — it should arrive within a few seconds.

If it doesn't arrive:
- Check **Supabase Dashboard → Edge Functions → notify-decision → Logs** for
  errors (e.g. a bad Resend key shows up here).
- Check **Resend Dashboard → Logs** to see if the send was attempted/rejected.
- Check spam — sandbox-sender emails occasionally land there on first send.

## Later: switching the recipient

When you're ready to point this at Dave's real email instead of the test
address, edit `NOTIFY_TO` in `index.ts` and redeploy:

```bash
supabase functions deploy notify-decision
```
