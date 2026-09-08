import drv, json, time, sys, collections
from scen import scroll_scene
c=json.load(open("conn.json")); base,iso=c["base"],c["iso"]
route=sys.argv[1]; tag=sys.argv[2]
print(drv.ext(base,iso,"mode",value="plain")["result"]); time.sleep(1)
print(drv.ext(base,iso,"go",route=route)["result"]); time.sleep(4)
print(drv.ext(base,iso,"state")["result"]); drv.shot(f"mat_{tag}.png")
for _ in range(2): drv.swipe(720,2300,720,900,150); time.sleep(0.8)
time.sleep(1.5)
print(drv.rpc(base,"setFlag",name="profiler",value="true").get("result"))
fr=scroll_scene(base,iso,tag,swipes=14,pause=0.7,poll=False)
b=fr["budgetUs"]; F=fr["frames"]; bu=[f[1] for f in F]; ra=[f[2] for f in F]
def pct(xs,q):
    xs=sorted(xs); return xs[min(len(xs)-1,int(round((len(xs)-1)*q)))]/1000
print(f"frames={len(F)} build p50={pct(bu,.5):.2f} p90={pct(bu,.9):.2f} p99={pct(bu,.99):.2f} max={max(bu)/1000:.1f}  build>budget={sum(1 for x in bu if x>b)}  raster p50={pct(ra,.5):.2f} p90={pct(ra,.9):.2f} raster>budget={sum(1 for x in ra if x>b)}")
worst=sorted(F,key=lambda f:-f[1])[:10]
t0=F[0][0]
for f in worst: print(f"  t={(f[0]-t0)/1000:7.0f} build={f[1]/1000:5.1f} raster={f[2]/1000:5.1f} total={f[3]/1000:5.1f}")
# CPU samples over the worst 6 build frames
incl=collections.Counter(); leaf=collections.Counter(); n=0
for f in worst[:6]:
    r=drv.rpc(base,"getCpuSamples",isolateId=iso,timeOriginMicros=f[0],timeExtentMicros=f[1]+2000)
    if "result" not in r: print("cpu err",r); continue
    res=r["result"]; funcs=res["functions"]
    for s in res["samples"]:
        st=s["stack"]; n+=1
        if not st: continue
        leaf[funcs[st[0]]["function"].get("name","?")]+=1
        seen=set()
        for i in st:
            nm=funcs[i]["function"].get("name","?")
            if nm in seen: continue
            seen.add(nm); incl[nm]+=1
print(f"\nCPU samples in worst frames: {n}")
print("-- inclusive top 25"); [print(f"  {v/n*100:5.1f}% {k}") for k,v in incl.most_common(25)]
print("-- leaf top 15"); [print(f"  {v/n*100:5.1f}% {k}") for k,v in leaf.most_common(15)]
