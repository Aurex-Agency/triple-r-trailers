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
