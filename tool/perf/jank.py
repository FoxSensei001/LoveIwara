import json, sys, collections
from tla import load, durs
tag=sys.argv[1]
fr=json.load(open(f"frames_{tag}.json")); tl=load(f"tl_{tag}.json")
names={e["tid"]:e["args"]["name"].split(" (")[0] for e in tl if e.get("ph")=="M" and e["name"]=="thread_name"}
ev=durs(tl)
F=fr["frames"]; t0=F[0][0]
worst=sorted(F,key=lambda f:-f[3])[:int(sys.argv[2]) if len(sys.argv)>2 else 8]
worst.sort(key=lambda f:f[0])
for f in worst:
    vs,b,r,tot,num=f
    lo=vs-70000; hi=vs+tot
    print(f"\n=== frame #{num} t={(vs-t0)/1000:.0f}ms build={b/1000:.1f} raster={r/1000:.1f} total={tot/1000:.1f}")
    inside=[e for e in ev if e["ts"]+e["dur"]>lo and e["ts"]<hi and e["dur"]>1500]
    inside.sort(key=lambda e:e["ts"])
    for e in inside[:25]:
        print(f"  {names.get(e['tid'],e['tid']):18s} +{(e['ts']-vs)/1000:7.1f}ms dur={e['dur']/1000:6.1f} {e['name']} {str(e['args'])[:80] if e['args'] else ''}")
    # instant/flow events near
    inst=[e for e in tl if e.get("ph") in ("i","I") and lo<=e.get("ts",0)<=hi]
    if inst: print("  instants:",collections.Counter(e["name"] for e in inst).most_common(5))
