import drv, json, time, sys, threading
P="m.c.g.a.i_iwara.profile"
def launch_fixed():
    drv.adb("shell","am","force-stop",P)
    drv.adb("shell","am","start","-n",P+"/m.c.g.a.i_iwara.MainActivity","--ei","vm-service-port","45678","--ez","disable-service-auth-codes","true")
    time.sleep(6); drv.adb("forward","tcp:45678","tcp:45678")
    base="http://127.0.0.1:45678/"; iso=drv.isolate(base); return base,iso
class TLPoller:
    def __init__(s,base): s.base=base; s.ev={}; s.stop=False; s.t=threading.Thread(target=s.run,daemon=True)
    def run(s):
        while not s.stop:
            try:
                tl=drv.rpc(s.base,"getVMTimeline")["result"]["traceEvents"]
                for e in tl: s.ev[(e.get("ts",0),e["name"],e["ph"],e.get("tid"))]=e
            except Exception as ex: print("poll err",ex)
            time.sleep(1.2)
    def start(s): s.t.start()
    def finish(s,path):
        s.stop=True; s.t.join()
        json.dump({"result":{"traceEvents":sorted(s.ev.values(),key=lambda e:e.get("ts",0))}},open(path,"w"))
        return len(s.ev)
def scroll_scene(base,iso,tag,swipes=12,pause=0.7,x=720,y1=2300,y2=900,ms=150,poll=True):
    drv.ext(base,iso,"frames")  # clear
    drv.ext(base,iso,"mark",label=tag)
    p=TLPoller(base) if poll else None
    if p: p.start()
    for _ in range(swipes):
        drv.swipe(x,y1,x,y2,ms); time.sleep(pause)
    time.sleep(1.5)
    n=p.finish(f"tl_{tag}.json") if p else 0
    fr=drv.ext(base,iso,"frames")["result"]
    json.dump(fr,open(f"frames_{tag}.json","w"))
    rep=drv.ext(base,iso,"report")["result"]["reports"]
    print(tag,"timeline events",n); print("\n".join(rep))
    return fr
def frame_summary(fr):
    b=fr["budgetUs"]; F=fr["frames"]
    if not F: print("no frames"); return
    tot=[f[3] for f in F]; bu=[f[1] for f in F]; ra=[f[2] for f in F]
    over=[f for f in F if f[3]>b]
    print(f"frames={len(F)} budget={b/1000:.2f}ms  total>budget: {len(over)} ({100*len(over)/len(F):.1f}%)  build>budget: {sum(1 for x in bu if x>b)}  raster>budget: {sum(1 for x in ra if x>b)}")
    # gaps between vsync starts (dropped frames)
    vs=[f[0] for f in F]; gaps=[(vs[i+1]-vs[i]) for i in range(len(vs)-1)]
    import collections
    h=collections.Counter(min(round(g/b),12) for g in gaps)
    print("vsync gap in budgets:",sorted(h.items()))
    print("worst 15 frames (t_rel_ms, build, raster, total):")
    t0=vs[0]
    for f in sorted(F,key=lambda f:-f[3])[:15]: print(f"  t={(f[0]-t0)/1000:8.0f} build={f[1]/1000:5.1f} raster={f[2]/1000:5.1f} total={f[3]/1000:5.1f} #{f[4]}")
if __name__=="__main__":
    base,iso=launch_fixed(); json.dump({"base":base,"iso":iso},open("conn.json","w"))
    print(drv.ext(base,iso,"mode",value="plain")["result"])
    route=sys.argv[1]; tag=sys.argv[2]
    print(drv.ext(base,iso,"go",route=route)["result"]); time.sleep(4)
    print(drv.ext(base,iso,"state")["result"]); drv.shot(f"shot_{tag}.png")
    for _ in range(2): drv.swipe(720,2300,720,900,150); time.sleep(0.8)
    time.sleep(1.5)
    fr=scroll_scene(base,iso,tag)
    frame_summary(fr)
