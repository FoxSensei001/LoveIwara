import drv, json, time, collections
from tla import durs
c=json.load(open("conn.json")); base,iso=c["base"],c["iso"]
def tail(tag, swipes=3):
    for _ in range(3): drv.swipe(720,2300,720,900,150); time.sleep(0.7)
    drv.rpc(base,"clearVMTimeline")
    for _ in range(swipes): drv.swipe(720,2300,720,900,150); time.sleep(0.7)
    time.sleep(0.3)
    tl=drv.rpc(base,"getVMTimeline")["result"]["traceEvents"]
    json.dump({"result":{"traceEvents":tl}},open(f"tl_{tag}.json","w"))
    ev=durs(tl); names={e["tid"]:e["args"]["name"].split(" (")[0] for e in tl if e.get("ph")=="M" and e["name"]=="thread_name"}
    nf=len([e for e in ev if e["name"]=="Rasterizer::DoDraw"]) or 1
    def per(n): return sum(1 for e in ev if e["name"]==n)/nf
    def ms(n): return sum(e["dur"] for e in ev if e["name"]==n)/nf/1000
    ui=[e["dur"] for e in ev if e["name"]=="Animator::BeginFrame"]
    r=f"{tag:28s} frames={nf:4d} saveLayer/f={per('Canvas::saveLayer'):5.1f} raster={ms('Rasterizer::DoDraw'):5.2f}ms encode={ms('SurfaceFrame::Encode'):5.2f}ms snapshot/f={per('DoMakeRasterSnapshot'):4.2f} ui={sum(ui)/max(1,len(ui))/1000:4.2f}ms"
    print(r); open("ab_log.txt","a").write(r+"\n"); return r
def knob(n,v): return drv.rpc(base,"ext.glassperf.knob",isolateId=iso,name=n,value=v)["result"]
