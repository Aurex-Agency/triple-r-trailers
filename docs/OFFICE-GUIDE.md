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
anywhere else. Find them under **Who is on the network** and click **Resend**
next to their name, which sends the whole thing again. They can also go to the
dealer login page, put in their email, and click **Email me a sign-in link**.

---

## Somebody cannot get in

Find them under **Who is on the network** and click **Resend** next to their
name. That is the whole job.

The page works out on its own which email they need:

- **Never opened the first one.** They get the invite again, word for word.
- **Has been signing in and forgot the password.** They get a reset link.

Either way they land on a page that asks them to pick a password, and once
they have picked one they are straight into their documents. You never see it
and you never set it.

Nothing about their dealership, their orders or their past requests changes.
Resend as many times as you like; only the newest link works.

---

## There are two of the same dealership on the list

Somebody typed the lot in twice, or typed it in slightly differently, and now
it is on the list twice. Take one off.

Find the wrong one under **Who is on the network** and click **Remove** in its
top right corner.

- **If nothing was ever put on it,** it asks you once and then it is gone.
- **If it has orders, parts requests or people on it,** it will not throw
  those away. It shows you what is on it and asks which dealership they belong
  to. Pick the right one, and every order, every parts request and every login
  moves across exactly as it was, keeping its number. Then the wrong one goes.

That second case is usually what you want with a duplicate anyway. The orders
were always that lot's orders; they were just filed under the wrong spelling.

Nothing is deleted in that move. Open the good dealership afterwards and you
will see the orders sitting on it.

---

## Somebody is out

Find their dealership under **Who is on the network** and click **Remove**
next to their name.

They are gone the moment you click it. Their login is deleted and they cannot
sign in again.

**Nothing you care about is lost.** Every order and parts request they ever
sent stays on the dealership, with the name and phone number they gave at the
time. You are only removing the ability to sign in. If they come back, click
**Add a person** and they get a fresh invite.

If a whole dealership is out, remove every person listed under it. Leave the
dealership itself on the list unless it is a duplicate, because their old
orders live on it.

**Office logins are different.** The page will not let you remove yourself or
anybody else in the office. That is on purpose, so a wrong click cannot lock
Triple R out of its own page. Those are removed in Supabase.

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

**The list only shows what you still have to deal with.** Across the top:

| Tab | What is in it |
| --- | --- |
| Needs a call | Came in, nobody has picked it up yet. This is what opens by default |
| In progress | Confirmed, in the shop, ready, shipped |
| Finished | Delivered, done, cancelled |
| Everything | All of it |

The number beside each tab is how many are in it. Move a request along and it
drops out of Needs a call on its own, so that tab empties as you work through
the day. It does not matter how many hundreds pile up over a year; the tab you
open on only ever shows what is waiting.

The box on the right searches all of them at once. Type a request number, a
dealership, or the name of whoever sent it, and it finds it wherever it is.
Useful when a dealer rings up about one from three months ago. Clear the box to
go back to the normal list.

Long lists load twenty five at a time with a **Show more** button at the
bottom, so the page never takes a minute to open.

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

If one of them should not exist at all, **Remove** clears it out. The red box
is there to tell you something needs doing, so once it is empty it disappears
and the page goes quiet again.

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
- **An order cannot be lost by tidying up.** Removing a dealership that has
  orders on it is refused outright until you say which dealership those orders
  belong to, and then they move rather than go.

---

## If a section of the page looks empty

Ad blockers sometimes hide parts of a page they mistake for advertising. If a
whole section is missing rather than just empty, try the page with the blocker
turned off for this site, and say something so it can be fixed properly.

## When something looks wrong

Nothing on this page deletes an order, so there is no way to lose work by
clicking around on it. Removing a dealership is the only thing that takes
anything off the page at all, and it will not do that until it knows where its
orders should go. If a message on the page does not make sense, it will say
what it wants in plain words. If it still does not make sense, take a picture
of the screen and send it over.
