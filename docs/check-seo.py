"""Offline SEO/link checks for the static site. No dependencies or network."""
from pathlib import Path
from html.parser import HTMLParser
from urllib.parse import urlsplit, unquote
import json, re, xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
ORIGIN = 'https://triplertrailers.com'
NEW = ['14k-dump-trailer-payload.html', 'what-size-trailer-for-polaris-ranger-crew.html', 'enclosed-trailer-cost.html', 'choosing-a-trailer-manufacturer.html', '6x12-vs-7x16-enclosed-trailer.html']

class Page(HTMLParser):
    def __init__(self, path):
        super().__init__(); self.path=path; self.ids=[]; self.refs=[]; self.canonicals=[]; self.h1=0; self.metas={}; self.json=[]; self.buffer=None
        self.feed(path.read_text())
    def handle_starttag(self, tag, attrs):
        a=dict(attrs)
        if 'id' in a: self.ids.append(a['id'])
        if tag=='h1': self.h1+=1
        if tag=='meta': self.metas[a.get('name',a.get('property',''))]=a.get('content','')
        if tag=='link' and a.get('rel')=='canonical': self.canonicals.append(a.get('href'))
        if tag in ('a','img','script','link'):
            ref=a.get('href') or a.get('src')
            if ref: self.refs.append(ref)
        if tag=='script' and a.get('type')=='application/ld+json': self.buffer=''
    def handle_data(self,data):
        if self.buffer is not None: self.buffer+=data
    def handle_endtag(self,tag):
        if tag=='script' and self.buffer is not None:
            self.json.append(json.loads(self.buffer)); self.buffer=None

pages={p.name:Page(p) for p in ROOT.glob('*.html')}
errors=[]
for name,p in pages.items():
    expected=ORIGIN+('/' if name=='index.html' else '/'+name)
    if p.canonicals != [expected]: errors.append(f'{name}: canonical {p.canonicals}')
    if p.h1!=1: errors.append(f'{name}: {p.h1} H1 headings')
    if len(p.ids)!=len(set(p.ids)): errors.append(f'{name}: duplicate HTML IDs')
    if name.startswith('dealer-') and 'noindex' not in p.metas.get('robots',''): errors.append(f'{name}: account page is indexable')
    if not name.startswith('dealer-') and 'noindex' in p.metas.get('robots',''): errors.append(f'{name}: public page is noindex')
    for ref in p.refs:
        u=urlsplit(ref)
        if u.scheme and u.scheme not in ('http','https'): continue
        if u.netloc and u.netloc!='triplertrailers.com': continue
        rel=unquote(u.path).lstrip('/') if u.path else name
        if not rel: rel='index.html'
        target=ROOT/rel
        if not target.is_file(): errors.append(f'{name}: missing target {ref}'); continue
        if u.fragment and target.suffix=='.html' and unquote(u.fragment) not in pages[target.name].ids:
            errors.append(f'{name}: missing fragment {ref}')

urls=[e.text for e in ET.parse(ROOT/'sitemap.xml').findall('.//{*}loc')]
expected={ORIGIN+('/' if name=='index.html' else '/'+name) for name in pages if not name.startswith('dealer-')}
if len(urls)!=len(set(urls)): errors.append('Duplicate sitemap URLs')
if set(urls)!=expected: errors.append(f'Sitemap differences: {set(urls)^expected}')
for name in NEW:
    p=pages[name]
    article=[j for j in p.json if j.get('@type') in ('Article','BlogPosting')]
    if len(article)!=1 or article[0]['mainEntityOfPage']!=ORIGIN+'/'+name: errors.append(f'{name}: article identity')
    if len(p.metas.get('description',''))>170: errors.append(f'{name}: description over 170 characters')
    inbound=[n for n,other in pages.items() if n!=name and any(urlsplit(r).path.lstrip('/')==name for r in other.refs)]
    if len(inbound)<3: errors.append(f'{name}: only {len(inbound)} inbound pages')
    if len(re.sub('<[^>]+>',' ',p.path.read_text()).split())<1000: errors.append(f'{name}: manuscript may be incomplete')
if errors:
    raise SystemExit('\n'.join(errors))
print(f'PASS: {len(pages)} pages, {len(urls)} sitemap URLs, JSON-LD, H1s, canonicals, local links/fragments and article discovery.')
