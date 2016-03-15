#!/usr/bin/env python
'''
Licensed to the Apache Software Foundation (ASF) under one
or more contributor license agreements.  See the NOTICE file
distributed with this work for additional information
regarding copyright ownership.  The ASF licenses this file
to you under the Apache License, Version 2.0 (the
"License"); you may not use this file except in compliance
with the License.  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
'''
import sys
import math
import xml.etree.ElementTree as ET
from commands import getstatusoutput

''' Reserved for OS + DN + NM,  Map: Memory => Reservation '''
reservedStack = { 4:1, 8:2, 16:2, 24:4, 48:6, 64:8, 72:8, 96:12,
                   128:24, 256:32, 512:64}
''' Reserved for HBase. Map: Memory => Reservation '''

reservedHBase = {4:1, 8:1, 16:2, 24:4, 48:8, 64:8, 72:8, 96:16,
                   128:24, 256:32, 512:64}
GB = 1024

def getMinContainerSize(memory):
    if (memory <= 4):
        return 256
    elif (memory <= 8):
        return 512
    elif (memory <= 24):
        return 1024
    else:
        return 2048

def getReservedStackMemory(memory):
    if (reservedStack.has_key(memory)):
        return reservedStack[memory]
    if (memory <= 4):
        ret = 1
    elif (memory >= 512):
        ret = 64
    else:
        ret = 1
    return ret

def getReservedHBaseMem(memory):
    if (reservedHBase.has_key(memory)):
        return reservedHBase[memory]
    if (memory <= 4):
        ret = 1
    elif (memory >= 512):
        ret = 64
    else:
        ret = 2
    return ret

def update_xml_config(filename, xml_value_dict):
    tree = ET.parse(filename)
    root = tree.getroot()

    for item in xml_value_dict:
        property = ET.SubElement(root, "property")
        name_key = ET.SubElement(parent = property, tag = "name")
        name_key.text = item

        value_key = ET.SubElement(parent = property, tag = "value")
        value_key.text = xml_value_dict[item]

    tree.write(filename)
    retcode, output = getstatusoutput('xmllint --format '+filename+' -o '+filename)

def _get_cores():
    import multiprocessing
    return multiprocessing.cpu_count()

def _get_mem():
    import psutil

    if hasattr(psutil, 'virtual_memory'):
        return psutil.virtual_memory().free / 1000000000

    else:
        return psutil.phymem_usage().free / 1000000000

def main():
    yarn_site = '/usr/local/hadoop-2.7.2/etc/hadoop/yarn-site.xml'
    mapred_site = '/usr/local/hadoop-2.7.2/etc/hadoop/mapred-site.xml'

    yarn_dict = {}
    mapred_dict= {}

    memory = _get_mem()
    cores = 0
    disks = 1
    hbaseEnabled = False

    minContainerSize = getMinContainerSize(memory)
    reservedStackMemory = getReservedStackMemory(memory)
    reservedHBaseMemory = 0
    if (hbaseEnabled):
        reservedHBaseMemory = getReservedHBaseMem(memory)
    reservedMem = reservedStackMemory + reservedHBaseMemory
    usableMem = memory - reservedMem
    memory -= (reservedMem)
    if (memory < 2):
        memory = 2
        reservedMem = max(0, memory - reservedMem)

    memory *= GB

    containers = int (min(2 * cores,
                         min(math.ceil(1.8 * float(disks)),
                              memory/minContainerSize)))
    if (containers <= 2):
        containers = 3

    container_ram =  abs(memory/containers)
    if (container_ram > GB):
        container_ram = int(math.floor(container_ram / 512)) * 512


    yarn_dict["yarn.scheduler.minimum-allocation-mb"] = str(container_ram)
    yarn_dict["yarn.scheduler.maximum-allocation-mb"] = str(containers*container_ram)
    yarn_dict["yarn.nodemanager.resource.memory-mb"] = str(containers*container_ram)
    map_memory = container_ram
    reduce_memory = 2*container_ram if (container_ram <= 2048) else container_ram
    am_memory = max(map_memory, reduce_memory)
    mapred_dict["mapreduce.map.memory.mb"] =  str(map_memory)
    mapred_dict["mapreduce.map.java.opts"] = "-Xmx" + str(int(0.8 * map_memory)) +"m"
    mapred_dict["mapreduce.reduce.memory.mb"] = str(reduce_memory)
    mapred_dict["mapreduce.reduce.java.opts"] = "-Xmx" + str(int(0.8 * reduce_memory)) + "m"
    mapred_dict["yarn.app.mapreduce.am.resource.mb"] = str(am_memory)
    mapred_dict["yarn.app.mapreduce.am.command-opts"] = "-Xmx" + str(int(0.8*am_memory)) + "m"
    mapred_dict["mapreduce.task.io.sort.mb"] = str(int(0.4 * map_memory))

    update_xml_config(yarn_site, yarn_dict)
    update_xml_config(mapred_site, mapred_dict)


if __name__ == '__main__':
    try:
        main()
    except(KeyboardInterrupt, EOFError):
        print("\nAborting ... Keyboard Interrupt.")
        sys.exit(1)
