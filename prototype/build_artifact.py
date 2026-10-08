#!/usr/bin/env python3
"""Bundles the prototype (UI + mock backend running in the browser) into one self-contained HTML file.
Usage: python3 prototype/build_artifact.py OUT.html"""
import re, sys, os
here = os.path.dirname(os.path.abspath(__file__))
rd = lambda p: open(os.path.join(here, p)).read()
S = rd('server.js'); core = S[S.index('let offset = 0;'):S.index('const MIME')]
core = re.sub(r'\bR\b', 'RR', core).replace('async function api(req, res, url)', 'async function mockApi(req, res, url)').replace("const RR = require('./rules.json');", '')
rules = rd('rules.json')
css = rd('public/style.css')
css = re.sub(r'body\{margin:0;[^}]*\}', 'body{margin:0;font-family:-apple-system,"SF Pro Text","Segoe UI",Roboto,sans-serif;color:var(--pg-ink);background:var(--pg-bg)}', css)
css = css.replace('.stage{display:flex;gap:24px;justify-content:center;align-items:flex-start;padding:16px}', '.stage{display:flex;flex-wrap:wrap;gap:24px;justify-content:center;align-items:flex-start;padding-block:16px}')
css = css.replace('.phone{flex:none;width:390px;height:844px;', '.phone{flex:none;width:min(406px,100%);height:min(860px,calc(100vh - 32px));min-height:640px;')
css = css.replace('.dev{width:240px;font-size:12px;color:#333}.dev button{display:block;width:100%;margin:4px 0;padding:8px;border:1px solid #bbb;background:#fff;', '.dev{width:min(260px,100%);font-size:12px;color:var(--pg-ink)}.dev button{display:block;width:100%;margin:4px 0;padding:8px;border:1px solid var(--pg-line);background:var(--pg-card);color:var(--pg-ink);')
tokens = ''':root{--pg-bg:#E4E6EB;--pg-ink:#1C1C1E;--pg-card:#fff;--pg-line:#B9BEC8}
@media (prefers-color-scheme: dark){:root:not([data-theme="light"]){--pg-bg:#16181D;--pg-ink:#E8EAEE;--pg-card:#23252B;--pg-line:#3A3E47;color-scheme:dark}}
:root[data-theme="dark"]{--pg-bg:#16181D;--pg-ink:#E8EAEE;--pg-card:#23252B;--pg-line:#3A3E47;color-scheme:dark}
'''
app = rd('public/app.js').replace('localStorage', '__ls')
body = re.search(r'<body>(.*?)<script src', rd('public/index.html'), re.S).group(1)
shim = '''const __mem={};const __ls={getItem:k=>{try{return window.localStorage.getItem(k)}catch(e){return __mem[k]??null}},setItem:(k,v)=>{try{window.localStorage.setItem(k,v)}catch(e){__mem[k]=v}},removeItem:k=>{try{window.localStorage.removeItem(k)}catch(e){delete __mem[k]}},clear:()=>{try{window.localStorage.clear()}catch(e){}}};
const RR = ''' + rules + ''';
''' + core + '''
const __realFetch = window.fetch.bind(window);
window.fetch = async (u, o = {}) => {
  const url = new URL(u, 'http://x');
  if (url.pathname === '/rules.json') return new Response(JSON.stringify(RR), { headers: { 'content-type': 'application/json' } });
  if (!url.pathname.startsWith('/api')) return __realFetch(u, o);
  const h = {}; Object.entries(o.headers || {}).forEach(([k, v]) => (h[k.toLowerCase()] = v));
  const req = { method: o.method || 'GET', headers: h, on(ev, cb) { if (ev === 'data' && o.body) cb(o.body); if (ev === 'end') cb(); } };
  return await new Promise((ok) => { const res = { writeHead(c) { this.c = c; }, end(t) { ok(new Response(t, { status: this.c, headers: { 'content-type': 'application/json' } })); } }; mockApi(req, res, url); });
};
'''
open(sys.argv[1], 'w').write('<title>ALRT Prototype</title>\n<style>' + tokens + css + '</style>\n' + body + '\n<script>\n' + shim + '\n' + app + '\n</script>\n')
