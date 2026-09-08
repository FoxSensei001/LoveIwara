import drv, json, time, sys
from scen import launch_fixed, scroll_scene
PROD={"blend":"on","chromeGroup":"on","shadows":"2","blur":"on","bar":"liquid","fab":"on","quality":"premium"}
def pct(xs,q):
    xs=sorted(xs); return xs[min(len(xs)-1,int(round((len(xs)-1)*q)))]/1000
def summ(tag,fr):
    b=fr["budgetUs"]; F=fr["frames"]; ra=[f[2] for f in F]; bu=[f[1] for f in F]
    vs=[f[0] for f in F]; gaps=[(vs[i+1]-vs[i]) for i in range(len(vs)-1)]
    dropped=sum(1 for g in gaps if g>b*1.5)
    line=(f"{tag:26s} n={len(F):4d} raster p50={pct(ra,.5):5.2f} p90={pct(ra,.9):5.2f} p99={pct(ra,.99):5.2f} "
          f"raster>budget={100*sum(1 for x in ra if x>b)/len(F):4.1f}%  build p50={pct(bu,.5):4.2f} p90={pct(bu,.9):4.2f}  dropped-vsync={100*dropped/max(1,len(gaps)):4.1f}%")
    print(line); open("ab2_log.txt","a").write(line+"\n")
def knob(base,iso,n,v):
    r=drv.rpc(base,"ext.glassperf.knob",isolateId=iso,name=n,value=v)
    assert "result" in r and r["result"]["ok"], (n,v,r)
def set_all(base,iso,over):
    cfg=dict(PROD); cfg.update(over)
    for k,v in cfg.items(): knob(base,iso,k,v)
    time.sleep(1.2)
CONFIGS=[("liquid-baseline",{}),("shadows=0",{"shadows":"0"}),("blur=off",{"blur":"off"}),("quality=standard",{"quality":"standard"}),
         ("bar=material",{"bar":"material"}),("fab=off",{"fab":"off"}),("chromeGroup=off",{"chromeGroup":"off"}),
         ("shadows0+blur=off",{"shadows":"0","blur":"off"}),("liquid-baseline#2",{})]
if __name__=="__main__":
    fresh=len(sys.argv)>1 and sys.argv[1]=="fresh"
    if fresh:
        base,iso=launch_fixed(); json.dump({"base":base,"iso":iso},open("conn.json","w"))
        drv.ext(base,iso,"go",route="/community"); time.sleep(4)
    else:
        c=json.load(open("conn.json")); base,iso=c["base"],c["iso"]
    print(drv.ext(base,iso,"mode",value="liquid")["result"]); time.sleep(1)
    print(drv.ext(base,iso,"state")["result"]); drv.shot("ab2_start.png")
    for _ in range(3): drv.swipe(720,2300,720,900,150); time.sleep(0.7)
    time.sleep(1)
    for tag,over in CONFIGS:
        set_all(base,iso,over)
        fr=scroll_scene(base,iso,tag,swipes=10,pause=0.7,poll=False)
        summ(tag,fr)
    set_all(base,iso,{})
    print(drv.ext(base,iso,"mode",value="plain")["result"]); time.sleep(1.5)
    fr=scroll_scene(base,iso,"material-ref",swipes=10,pause=0.7,poll=False); summ("material-ref",fr)
    drv.shot("ab2_end.png")
