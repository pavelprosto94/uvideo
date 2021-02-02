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

def videoFinalize():
    fdata=[]
    for root, dirs, files in os.walk(CACHEPATH+"HubIncoming"):
        for dirname in dirs:
            path=CACHEPATH+"HubIncoming/"+dirname
            os.chmod(path, stat.S_IWRITE)
            print(path)
            shutil.rmtree(path)


def slow_function(path=""):
  fdata=[]
  for root, dirs, files in os.walk(path):
        for filename in files:
            if  filename.find(".mp4")>-1 or filename.find(".ogv")>-1 or filename.find(".webm")>-1:
                fdata.append([filename,"video-x-generic",os.path.join(root, filename)])
  
  for line in fdata:
      pyotherside.send('progress', line)   
      time.sleep(0.01)    
  pyotherside.send('finished')

class Explorer:
    def __init__(self):
        self.bgthread = threading.Thread()

    def seach(self, path=""):
        if self.bgthread.is_alive():
            return
        self.bgthread = threading.Thread(target=slow_function(path))
        self.bgthread.start()

explorer = Explorer()
