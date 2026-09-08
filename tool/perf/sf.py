import drv, re, sys, time
def hist(out, pkg):
    i=out.find(f'SurfaceView[{pkg}/'); 
    seg=out[i:i+4000]
    m=re.search(r"present2present histogram is as below:\n([^\n]+)",seg)
    tot=re.search(r"totalFrames = (\d+)",seg).group(1); fps=re.search(r"averageFPS = ([\d.]+)",seg).group(1)
    h=[(int(a),int(b)) for a,b in re.findall(r"(\d+)ms=(\d+)",m.group(1)) if int(b)>0]
    return tot,fps,h
def measure(pkg, swipes=16, pause=0.7):
    drv.adb('shell','dumpsys','SurfaceFlinger','--timestats','-clear')
    for _ in range(swipes): drv.swipe(720,2300,720,900,150); time.sleep(pause)
    time.sleep(1.5)
    out=drv.adb('shell','dumpsys','SurfaceFlinger','--timestats','-dump')
    return hist(out,pkg)
if __name__=="__main__":
    pkg=sys.argv[1]; tag=sys.argv[2]
    drv.adb('shell','am','start','-n',pkg+'/m.c.g.a.i_iwara.MainActivity'); time.sleep(2.5)
    for _ in range(2): drv.swipe(720,2300,720,900,150); time.sleep(0.8)
    time.sleep(1.5)
    tot,fps,h=measure(pkg)
    print(f"{tag}: pkg={pkg} frames={tot} avgFPS={fps} present2present={h}")
