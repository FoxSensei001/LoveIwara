import json, re, subprocess, sys, time, urllib.parse, urllib.request
PKG="m.c.g.a.i_iwara.profile"; S="192.168.33.132:38357"
def adb(*a, capture=True):
    cmd=["adb","-s",S]+list(a)
    if capture: return subprocess.run(cmd,capture_output=True,text=True).stdout
    subprocess.run(cmd); return ""
def launch():
    adb("logcat","-c"); adb("shell","am","force-stop",PKG)
    adb("shell","monkey","-p",PKG,"-c","android.intent.category.LAUNCHER","1")
    for _ in range(60):
        time.sleep(1)
        m=re.search(r"The Dart VM service is listening on (http://127\.0\.0\.1:\d+/[^/]*/)",adb("logcat","-d"))
        if m:
            url=m.group(1); port=re.search(r":(\d+)/",url).group(1)
            adb("forward",f"tcp:{port}",f"tcp:{port}"); return url
    sys.exit("no vm service")
def rpc(base,method,**p):
    q=urllib.parse.urlencode(p); last=None
    for _ in range(3):
        try:
            with urllib.request.urlopen(f"{base}{method}?{q}",timeout=20) as r: return json.load(r)
        except Exception as e: last=e; time.sleep(0.5)
    raise last
def isolate(base):
    for _ in range(30):
        for iso in rpc(base,"getVM")["result"].get("isolates",[]):
            d=rpc(base,"getIsolate",isolateId=iso["id"])["result"]
            if any(e.startswith("ext.glassperf.") for e in d.get("extensionRPCs",[])): return iso["id"]
        time.sleep(1)
    sys.exit("no isolate")
def ext(base,iso,name,**p): return rpc(base,"ext.glassperf."+name,isolateId=iso,**p)
def swipe(x1,y1,x2,y2,ms): adb("shell","input","swipe",str(x1),str(y1),str(x2),str(y2),str(ms))
def tap(x,y): adb("shell","input","tap",str(x),str(y))
def shot(path):
    raw=subprocess.run(["adb","-s",S,"exec-out","screencap","-p"],capture_output=True).stdout
    open(path,"wb").write(raw)
def glasslog():
    out=adb("logcat","-d","-s","flutter")
    return [l for l in out.splitlines() if "GLASSPERF" in l]
if __name__=="__main__":
    base=launch(); iso=isolate(base)
    json.dump({"base":base,"iso":iso},open("conn.json","w"))
    print(base,iso); print(ext(base,iso,"state"))
