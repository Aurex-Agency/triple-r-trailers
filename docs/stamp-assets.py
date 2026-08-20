# -*- coding: utf-8 -*-
"""Stamp css/js references with a content hash so a changed file is a changed URL.

A browser cannot serve a stale copy of a URL it has never seen, so this works
regardless of what any visitor already has cached. Re-run after editing
anything in css/ or js/.
"""
import glob, hashlib, os, re

REPO = "/home/user/triple-r-trailers"
ASSETS = ["css/styles.css"] + sorted(glob.glob(f"{REPO}/js/*.js"))
ASSETS = ["css/styles.css"] + [os.path.relpath(p, REPO) for p in sorted(glob.glob(f"{REPO}/js/*.js"))]


def digest(rel):
    with open(os.path.join(REPO, rel), "rb") as f:
        return hashlib.md5(f.read()).hexdigest()[:8]


stamps = {rel: digest(rel) for rel in ASSETS}
changed = 0

for page in sorted(glob.glob(f"{REPO}/*.html")):
    src = open(page, encoding="utf-8").read()
    out = src
    for rel, h in stamps.items():
        # matches the plain path or an already stamped one, in href= or src=
        pattern = re.compile(r'((?:href|src)=")' + re.escape(rel) + r'(?:\?v=[0-9a-f]+)?(")')
        out = pattern.sub(lambda m: m.group(1) + rel + "?v=" + h + m.group(2), out)
    if out != src:
        open(page, "w", encoding="utf-8").write(out)
        changed += 1

print(f"stamped {len(stamps)} assets across {changed} pages")
for rel, h in stamps.items():
    print(f"  {rel:28} v={h}")

# sanity: every stamped reference points at a file that exists
bad = []
for page in glob.glob(f"{REPO}/*.html"):
    for m in re.finditer(r'(?:href|src)="((?:css|js)/[^"?]+)(?:\?v=[0-9a-f]+)?"', open(page, encoding="utf-8").read()):
        if not os.path.exists(os.path.join(REPO, m.group(1))):
            bad.append(f"{os.path.basename(page)} -> {m.group(1)}")
print("broken asset refs:", sorted(set(bad)) or "none")


# sanity: nothing the pages need is excluded from the deploy.
#
# This exists because it already happened. ".vercelignore" follows .gitignore
# rules, where an unanchored "supabase/" matches a directory at ANY depth, so
# it silently took assets/vendor/supabase/ off the deployment and every dealer
# login stopped working. A file that exists locally and 404s in production is
# invisible until somebody tries to sign in.
def ignore_rules(path):
    """Returns (matcher, raw) pairs for each .vercelignore pattern."""
    rules = []
    if not os.path.exists(path):
        return rules
    for raw in open(path, encoding="utf-8"):
        pat = raw.strip()
        if not pat or pat.startswith("#"):
            continue
        anchored = pat.startswith("/")
        name = pat.strip("/")
        rules.append((anchored, name, pat))
    return rules


def excluded(rel, rules):
    """True if rel would be kept out of the deploy by any rule."""
    parts = rel.split("/")
    for anchored, name, pat in rules:
        segs = name.split("/")
        if anchored:
            if parts[:len(segs)] == segs:
                return pat
        else:
            # unanchored: matches at any depth, which is the trap
            for i in range(len(parts) - len(segs) + 1):
                if parts[i:i + len(segs)] == segs:
                    return pat
    return None


# sanity: no class or id an ad blocker hides on sight.
#
# This exists because it already happened too. EasyList ships generic cosmetic
# rules including "###ad-new" and "##.ad-card", so naming the office form
# id="ad-new" class="ad-card" meant every visitor running uBlock, AdBlock Plus,
# AdGuard, or Brave shields had it hidden before they ever saw it. The markup
# was in the page and the server was fine; the browser removed it. Renaming the
# prefix to "od-" fixed it. These are the prefixes those lists sweep for, so
# nothing on this site may use them.
BLOCKED_PREFIXES = ("ad-", "ads-", "advert", "banner-", "sponsor", "promo-",
                    "popup-", "adbox", "adwrap", "ad_")

names = {}
for page in glob.glob(f"{REPO}/*.html"):
    body = open(page, encoding="utf-8").read()
    for attr in ("class", "id"):
        for m in re.finditer(attr + r'="([^"]+)"', body):
            for tok in m.group(1).split():
                names.setdefault(tok, set()).add(os.path.basename(page))
# Comments are stripped first, or the note above explaining the ad-blocker trap
# would trip the check that the note is about.
css_body = re.sub(r"/\*.*?\*/", " ", open(f"{REPO}/css/styles.css", encoding="utf-8").read(), flags=re.S)
for m in re.finditer(r'[.#]([A-Za-z][A-Za-z0-9_-]*)', css_body):
    names.setdefault(m.group(1), set())

risky = sorted(n for n in names if n.lower().startswith(BLOCKED_PREFIXES))
if risky:
    print("\nNAMES AD BLOCKERS ARE LIKELY TO HIDE:")
    for n in risky:
        where = ", ".join(sorted(names[n])) or "css only"
        print(f"   {n}  ({where})")
    raise SystemExit("Rename these. An ad blocker will hide them and the page will look broken.")
print(f"ad blocker check: {len(names)} class and id names, none using a blocked prefix")


rules = ignore_rules(os.path.join(REPO, ".vercelignore"))
refs = set()
for page in glob.glob(f"{REPO}/*.html"):
    body = open(page, encoding="utf-8").read()
    for m in re.finditer(r'(?:href|src)="(?!https?:|//|mailto:|tel:|#)([^"?#]+)', body):
        ref = m.group(1)
        if os.path.exists(os.path.join(REPO, ref)):
            refs.add(ref)

blocked = sorted({f"{ref}  (kept out by \"{excluded(ref, rules)}\")"
                  for ref in refs if excluded(ref, rules)})
if blocked:
    print("\nDEPLOY WOULD BE MISSING FILES THE PAGES NEED:")
    for b in blocked:
        print("  ", b)
    raise SystemExit("Fix .vercelignore before deploying. Anchor patterns with a leading slash.")
print(f"deploy check: {len(refs)} referenced files, none excluded by .vercelignore")
