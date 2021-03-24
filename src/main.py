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
CACHEPATH = os.getenv("HOME")+"/.cache/"+CACHEPATH
TMPBUF = CACHEPATH+"/tmp"
HUBPATH = CACHEPATH+"/HubIncoming/"
IGNORE = []

if not os.path.exists(HUBPATH):
  try:
    f = open(TMPBUF, "w")
    f.write("")
    f.close()
    removeAlltimemark()
  except Exception as e:
    pyotherside.send("error","Can't create cache file:\n"+TMPBUF)
    print(e)
else:
  tmpdata=[]
  for root, dirs, files in os.walk(HUBPATH):
    for filename in dirs:
      tmpdata.append(filename)
      print(filename)
      break
  if len(tmpdata)==0:
    try:
      f = open(TMPBUF, "w")
      f.write("")
      f.close()
    except Exception as e:
      pyotherside.send("error","Can't create cache file:\n"+TMPBUF)
      print(e)
  else:
    if os.path.exists(TMPBUF):
      try:
        f = open(TMPBUF, "r")
        tmp = f.read()
        IGNORE = tmp.split("\n")
        f.close()
      except Exception as e:
        pyotherside.send("error","Can't read cache file:\n"+TMPBUF)
        print(e)

if not os.path.exists(HUBPATH):
  try:
    os.makedirs(HUBPATH)
  except Exception as e:
    pyotherside.send("error","Can't create HubIncoming dir:\n"+HUBPATH)
    print(e)

def removeAlltimemark():
  for root, dirs, files in os.walk(CACHEPATH):
    for filename in files:
      if filename.find(".timemark")>-1:
        os.remove(os.path.join(root, filename))

def addtimemark(filename,timemark):
  if os.path.exists(filename):
    if "/" in filename:
      filename=CACHEPATH+filename[filename.rfind("/"):]+".timemark"
    else:
      filename=CACHEPATH+"/"+filename+".timemark"
    timemark=timemark[9:]
    try:
      f = open(filename, "w")
      f.write(timemark)
      f.close()
    except Exception as e:
      pyotherside.send("error","Can't create Timemark:\n"+e)
      print(e)

def removetimemark(filename):
  if "/" in filename:
    filename=CACHEPATH+filename[filename.rfind("/"):]+".timemark"
  else:
    filename=CACHEPATH+"/"+filename+".timemark"
  if os.path.exists(filename):
    os.remove(filename)

def gettimemark(filename):
  rez=-1
  if "/" in filename:
    filename=CACHEPATH+filename[filename.rfind("/"):]+".timemark"
  else:
    filename=CACHEPATH+"/"+filename+".timemark"
  if os.path.exists(filename):
    f = open(filename, "r")
    rez = f.read()
    f.close()
  return(int(rez))

def addignore(dt=""):
  global IGNORE
  if not (dt in IGNORE):
    IGNORE.append(dt)
    try:
      f = open(TMPBUF, "w")
      tmp=""
      for da in IGNORE:
        tmp+=da+"\n"
      f.write(tmp)
      f.close()
      removetimemark(dt)
    except Exception as e:
      pyotherside.send("error","Can't create cache file:\n"+TMPBUF)
      print(e)

def slow_function(path=""):
  global IGNORE
  fdata=[]
  for root, dirs, files in os.walk(path):
    for filename in files:
      if  filename.find(".mp4")>-1 or filename.find(".ogv")>-1 or filename.find(".webm")>-1:
        if not (os.path.join(root, filename) in IGNORE):
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
        self.bgthread = threading.Thread(target=slow_function(HUBPATH))
        self.bgthread.start()

explorer = Explorer()