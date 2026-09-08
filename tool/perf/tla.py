import json, collections, sys, statistics
def load(p): return json.load(open(p))["result"]["traceEvents"]
def durs(tl):
    """pair B/E events per (tid,name) into complete events with dur"""
    out=[]; stacks=collections.defaultdict(list)
    for e in tl:
        k=(e.get("tid"),e["name"])
        if e["ph"]=="B": stacks[k].append(e)
        elif e["ph"]=="E":
            if stacks[k]:
                b=stacks[k].pop(); out.append(dict(name=e["name"],cat=e.get("cat"),tid=e.get("tid"),ts=b["ts"],dur=e["ts"]-b["ts"],args=b.get("args",{})))
        elif e["ph"]=="X":
            out.append(dict(name=e["name"],cat=e.get("cat"),tid=e.get("tid"),ts=e["ts"],dur=e.get("dur",0),args=e.get("args",{})))
    return out
def pct(xs,q):
    xs=sorted(xs); return xs[min(len(xs)-1,int(round((len(xs)-1)*q)))]
def summarize(ev,name,budget=8333):
    d=[e["dur"] for e in ev if e["name"]==name]
    if not d: print(name,"none"); return
    j=sum(1 for x in d if x>budget)
    print(f"{name:32s} n={len(d)} p50={pct(d,.5)/1000:.2f} p90={pct(d,.9)/1000:.2f} p99={pct(d,.99)/1000:.2f} max={max(d)/1000:.2f}ms  >{budget/1000:.1f}ms: {j} ({100*j/len(d):.1f}%)  sum={sum(d)/1000:.0f}ms")
if __name__=="__main__":
    ev=durs(load(sys.argv[1]))
    for n in ["Frame","BUILD","LAYOUT","PAINT","Rasterizer::DoDraw","GPURasterizer::Draw","LayerTree::Paint","SurfaceFrame::Submit","Canvas::saveLayer","CreateGlyphAtlas","DartIsolate::HandleMessage","PipelineItem"]:
        summarize(ev,n)
    gc=[e for e in ev if e["cat"]=="GC" and e["name"]!="NotifyIdle"]
    print("GC events:",collections.Counter(e["name"] for e in gc)); print("GC total ms", sum(e["dur"] for e in gc)/1000, "max", max([e["dur"] for e in gc]+[0])/1000)
    # jank frames: Frame > budget -> what's inside
    frames=sorted([e for e in ev if e["name"]=="Frame"],key=lambda e:e["ts"])
    print("\n--- UI jank frames (Frame >8.3ms), top 12 by dur, with longest children")
    big=sorted(frames,key=lambda e:-e["dur"])[:12]
    for f in big:
        inside=[e for e in ev if e["tid"]==f["tid"] and e["ts"]>=f["ts"] and e["ts"]+e["dur"]<=f["ts"]+f["dur"] and e["name"] not in ("Frame",)]
        inside.sort(key=lambda e:-e["dur"])
        print(f"t={f['ts']/1e6:.3f} dur={f['dur']/1000:.1f}ms :: "+", ".join(f"{e['name']}[{e['dur']/1000:.1f}]" for e in inside[:6]))
    print("\n--- Raster jank (DoDraw >8.3ms) top 12 with children")
    rd=[e for e in ev if e["name"]=="Rasterizer::DoDraw"]
    for f in sorted(rd,key=lambda e:-e["dur"])[:12]:
        inside=[e for e in ev if e["tid"]==f["tid"] and e["ts"]>=f["ts"] and e["ts"]+e["dur"]<=f["ts"]+f["dur"] and e["name"]!="Rasterizer::DoDraw"]
        inside.sort(key=lambda e:-e["dur"])
        print(f"t={f['ts']/1e6:.3f} dur={f['dur']/1000:.1f}ms :: "+", ".join(f"{e['name']}[{e['dur']/1000:.1f}]" for e in inside[:7]))
