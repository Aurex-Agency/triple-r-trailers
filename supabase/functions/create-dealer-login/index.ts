// Triple R Trailers: create a dealer login, or send one again.
//
// This is the one job the office screen cannot do on its own. Creating a login
// and sending the invite email needs the project's master key, and a master key
// can never sit in a web page. So it sits here instead, on Supabase's side,
// where the browser can ask for the job to be done but can never see the key.
//
// Two things are asked of it. Without an action, or with action "create", it
// makes the login and sends the invite. With action "resend" it sends somebody
// their login again, picking the invite or a reset link depending on whether
// they ever opened the first one.
//
// The first thing it does is check that whoever is asking is listed in
// staff_users. Everything after that runs through the same staff-checked
// database functions the office screen uses, so there is no shortcut in here
// that a dealer could take.
//
// Deploying it (once, about two minutes):
//   Supabase dashboard -> Edge Functions -> Deploy a new function -> Via editor
//   Name it exactly:  create-dealer-login
//   Paste this whole file over the starter code, then Deploy.
// SUPABASE_URL, SUPABASE_ANON_KEY, and SUPABASE_SERVICE_ROLE_KEY are already
// there for you. Nothing to configure, nothing to install.

import { createClient } from 'jsr:@supabase/supabase-js@2';

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS'
};

function reply(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, 'Content-Type': 'application/json' }
  });
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: CORS });
  if (req.method !== 'POST') return reply({ error: 'Send this as a POST.' }, 405);

  const url = Deno.env.get('SUPABASE_URL')!;
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!;
  const serviceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;

  const authHeader = req.headers.get('Authorization') ?? '';
  if (!authHeader) return reply({ error: 'Sign in first.' }, 401);

  // Everything except the invite runs as the person who clicked the button,
  // so the database applies the same rules it would on any other page.
  const caller = createClient(url, anonKey, {
    global: { headers: { Authorization: authHeader } },
    auth: { persistSession: false }
  });

  const { data: who } = await caller.auth.getUser();
  if (!who?.user) return reply({ error: 'Sign in first.' }, 401);

  const { data: staff, error: staffErr } = await caller.rpc('is_staff');
  if (staffErr) return reply({ error: staffErr.message }, 400);
  if (staff !== true) {
    return reply({ error: 'This is for Triple R office staff only.' }, 403);
  }

  let body: any;
  try {
    body = await req.json();
  } catch {
    return reply({ error: 'Could not read the form.' }, 400);
  }

  const email = String(body?.email ?? '').trim().toLowerCase();
  const fullName = String(body?.full_name ?? '').trim();
  const redirectTo = String(body?.redirect_to ?? '').trim() || undefined;
  const action = String(body?.action ?? 'create').trim().toLowerCase();
  if (!email || email.indexOf('@') < 1) {
    return reply({ error: 'That does not look like an email address.' }, 400);
  }

  // ---------------------------------------------------------------- resend
  //
  // Send somebody their login again. Two different emails can be meant by
  // that, and sending the wrong one wastes a phone call:
  //
  //   never opened their invite   the invite again
  //   has been signing in         a reset link, because they have a password
  //                               already and only need a new one
  //
  // The database says which, so this never has to guess.
  if (action === 'resend') {
    const { data: statusData, error: statusErr } = await caller.rpc('admin_login_status', {
      p_email: email
    });
    if (statusErr) return reply({ error: statusErr.message }, 400);

    const who = statusData as any;
    if (who?.is_staff === true) {
      return reply({
        error: 'That is an office login. Office passwords are reset in Supabase, on purpose.'
      }, 400);
    }

    const admin = createClient(url, serviceKey, { auth: { persistSession: false } });

    if (who?.confirmed !== true) {
      const { error: reErr } = await admin.auth.admin.inviteUserByEmail(email, { redirectTo });
      if (!reErr) {
        return reply({ ok: true, email, sent: 'invite' });
      }
      // Some projects refuse a second invite. A reset link gets them in just
      // the same, so fall through rather than hand the office a dead end.
    }

    // resetPasswordForEmail is deliberately run as an ordinary visitor would
    // run it. The service key has no part to play in sending a reset.
    const plain = createClient(url, anonKey, { auth: { persistSession: false } });
    const { error: resetErr } = await plain.auth.resetPasswordForEmail(email, { redirectTo });
    if (resetErr) {
      return reply({ error: 'Could not send that email: ' + resetErr.message }, 400);
    }
    return reply({ ok: true, email, sent: 'reset' });
  }

  // Either an existing dealership was picked, or a new one is being added.
  let dealerId = String(body?.dealer_id ?? '').trim();
  if (!dealerId) {
    const d = body?.dealer ?? {};
    const { data: newId, error: dealerErr } = await caller.rpc('admin_save_dealer', {
      p_id: null,
      p_name: String(d.name ?? '').trim(),
      p_city: String(d.city ?? '').trim(),
      p_state: String(d.state ?? '').trim(),
      p_phone: String(d.phone ?? '').trim(),
      p_email: String(d.email ?? '').trim(),
      p_active: true
    });
    if (dealerErr) return reply({ error: dealerErr.message }, 400);
    dealerId = newId as string;
  }

  // The one privileged step: make the account and send the invite email.
  const admin = createClient(url, serviceKey, { auth: { persistSession: false } });
  let alreadyHadLogin = false;

  const { error: inviteErr } = await admin.auth.admin.inviteUserByEmail(email, {
    redirectTo,
    data: fullName ? { full_name: fullName } : undefined
  });

  if (inviteErr) {
    const msg = String(inviteErr.message ?? '');
    if (/already|exists|registered/i.test(msg)) {
      // Not a failure. They had a login already, so we just attach it.
      alreadyHadLogin = true;
    } else {
      return reply({ error: 'Could not send the invite: ' + msg }, 400);
    }
  }

  const { data: linked, error: linkErr } = await caller.rpc('admin_link_login', {
    p_email: email,
    p_dealer_id: dealerId,
    p_full_name: fullName || null
  });
  if (linkErr) {
    return reply({
      error: 'The login was created but could not be attached: ' + linkErr.message,
      dealer_id: dealerId,
      email
    }, 400);
  }

  return reply({
    ok: true,
    email,
    dealer_id: dealerId,
    dealer: (linked as any)?.dealer ?? null,
    already_had_login: alreadyHadLogin
  });
});
