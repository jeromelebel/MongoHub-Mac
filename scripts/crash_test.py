#!/usr/bin/python

import subprocess
import os
import pprint
import time
import signal

def launch():
    my_env = os.environ.copy()
    my_env["MallocGuardEdges"] = ""
    my_env["MALLOC_PERMIT_INSANE_REQUESTS"] = "1"
    my_env["MallocNanoZone"] = "1"
    my_env["MallocScribble"] = ""
#    my_env["MallocStackLogging"] = ""
    my_env["NSZombieEnabled"] = "YES"
    out = open('/dev/null', 'w')
#    out = None
    
    p = subprocess.Popen(["/Users/jerome/Library/Developer/Xcode/DerivedData/MongoHub-ghkunjdpnsennughboosbmnhkecd/Build/Products/Debug/MongoHub.app/Contents/MacOS/MongoHub" ], env = my_env, stdout = out, stderr = out)

    return p

crashed = 0
processes = []
while True:
    for x in range(2):
        processes.append(launch())
    time.sleep(8)
    start_time = time.time()
    while len(processes):
        for p in processes:
            if p.poll() is not None:
                processes.remove(p)
                if p.returncode != 0:
                    crashed += 1
        if time.time() - start_time > 4:
            break

    for p in processes:
        pprint.pprint(p.pid)
        os.killpg(p.pid, signal.SIGTERM)
        p.kill()
        processes.remove(p)

    print(crashed)
