# The Office Desk

One page, one address, everything the office needs.

**Where it is:** go to the dealer portal like a dealer would, sign in with the
Triple R office login, and click **Office** in the row of tabs. The address is
triplertrailers.com/dealer-admin.html if you would rather bookmark it.

Nobody else can see that tab. A dealer who types the address in gets sent
straight back to their own portal, and even if they got past the page, the
factory computer refuses every request that does not come from an office login.

---

## Somebody wants to be a dealer

They fill in the Request Access form on the website, or they call. Either way
it comes to triplertrailers@gmail.com with their dealership, their name, and
the email they want to use.

When you decide to take them on:

1. Open the **Office** page.
2. Top box, **Set up a dealer**.
   - If the dealership is already on the network, pick it from the list.
   - If it is new, leave the list on **Add a new dealership** and fill in the
     name, town, state, and lot phone.
3. Put in their name and their email.
4. Click **Send them a login**.

That is it. They get an email from Triple R with a button in it. They click it,
pick their own password, and they are in. You never see or set their password,
and you never have to.

**Two people at the same lot?** Do it again with the second person's email and
pick that dealership from the list. Or find them further down the page and click
**Add a person**. As many as they need.

**Their invite email never showed up?** It goes to junk more often than
anywhere else. If it is truly gone, they can go to the dealer login page,
put in their email, and click **Email me a sign-in link**.

---

## Somebody is out

Find their dealership under **Who is on the network** and click
**Remove access** next to their name.

They are cut off the moment you click it. No pricing, no documents, no
ordering. Their login still exists, so if they come back you can put them
right back on with **Add a person**. Nothing is lost either way.

If a whole dealership is out, remove every person listed under it.

---

## A request comes in

You get an email the second a dealer sends one, with everything on it. The
dealer gets their own copy at the same time, showing what they asked for at
their pricing and saying you will call to confirm. If they reply to it, the
reply comes to you. The
same request is also listed on the Office page under **Requests coming in**,
newest first, trailers and parts together.

Each one has a box on the right that says **Where it stands**. Change it and
the dealer sees the new answer on their own My Requests page. That is the whole
point of it: they stop calling to ask.

For trailer orders:

| Pick this | It means |
| --- | --- |
| Just came in | Nobody has looked at it yet |
| Confirmed | You called them, it is a real order |
| In the shop | It is being built |
| Ready | Sitting on the lot, come get it |
| Delivered | Gone |
| Cancelled | Not happening |

For parts it is the same idea: Just came in, Confirmed, Shipped, Ready for
pickup, Done, Cancelled.

Nothing on that page charges anybody. A request is a request until you pick up
the phone. Freight, lead time, and anything unusual still get settled the way
they always have.

---

## Somebody already has a login but sees nothing

That means the login is not attached to a dealership yet. It happens when a
login gets made in the Supabase dashboard instead of on the Office page.

Those show up in a red box near the bottom called **Logins with no dealership
yet**. Pick the right dealership beside their email and click **Attach**. They
are in.

---

## A dealer says the price list is missing

The price list is a file, not part of this page. Somebody with the Supabase
login uploads the new PDF and deletes the old one, and every dealer sees the
new one immediately. Kalob or whoever handles the website can do that in two
minutes.

Prices inside the ordering screens are separate again, and they get rebuilt
from the office price list whenever it changes. Send the new list over and it
gets loaded.

---

## Things that cannot go wrong

- **A dealer cannot see another dealer's anything.** Not their orders, not
  their parts requests, not their people. The factory computer sorts that out,
  not the web page.
- **A dealer cannot change a price.** The prices on a submitted request are
  looked up fresh from the factory price list when it is sent. Whatever shows
  up in your email is the factory's own number.
- **A dealer cannot change where a request stands.** Only office logins can.
- **Nobody can sign themselves up.** The only accounts that exist are ones you
  sent an invite to.

---

## If a section of the page looks empty

Ad blockers sometimes hide parts of a page they mistake for advertising. If a
whole section is missing rather than just empty, try the page with the blocker
turned off for this site, and say something so it can be fixed properly.

## When something looks wrong

Nothing on this page deletes an order or a dealership, so there is no way to
break something by clicking around on it. If a message on the page does not
make sense, it will say what it wants in plain words. If it still does not make
sense, take a picture of the screen and send it over.
