'''
 Copyright (C) 2021  Pavel Prosto

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; version 3.

 uVideo is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
'''
import pyotherside
import os, stat
import time
import threading
import shutil

CACHEPATH = os.path.abspath(__file__)
CACHEPATH = CACHEPATH[CACHEPATH.find(".com/")+5:]
CACHEPATH = CACHEPATH[:CACHEPATH.find("/")]
CACHEPATH = "/home/phablet/.cache/"+CACHEPATH+"/"

'''
def remove_readonly(fn, path, excinfo):
    print("try chmod:", path)
    try:
        os.chmod(path, 0o755)
        fn(path)
    except Exception as exc:
        print ("Skipped:", path, "because:\n", exc)

def videoFinalize():
    fdata=[]
    for root, dirs, files in os.walk(CACHEPATH+"HubIncoming"):
        for dirname in dirs:
            path=CACHEPATH+"HubIncoming/"+dirname
            shutil.rmtree(path, onerror=remove_readonly)
'''

def slow_function(path=""):
  print(path)
  fdata=[]
  for root, dirs, files in os.walk(path):
        for filename in files:
            if  filename.find(".mp4")>-1 or filename.find(".ogv")>-1 or filename.find(".webm")>-1:
                fdata.append([filename,"video-x-generic",os.path.join(root, filename)])
  if len(fdata)>0:
    for i in range(1,len(fdata)+1):
        pyotherside.send('progress', fdata[len(fdata)-i])   
        time.sleep(0.01)    
    pyotherside.send('finished')

class Explorer:
    def __init__(self):
        self.bgthread = threading.Thread()

    def seach(self, path=""):
        if self.bgthread.is_alive():
            return
        self.bgthread = threading.Thread(target=slow_function(CACHEPATH+"HubIncoming"))
        self.bgthread.start()

explorer = Explorer()
