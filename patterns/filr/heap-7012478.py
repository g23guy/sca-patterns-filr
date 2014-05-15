#!/usr/bin/python

# Title:       Check for Suggested Heap Size
# Description: Invalid heap sizes may cause Filr high utilization on Java
# Modified:    2014 Mar 15
#
##############################################################################
# Copyright (C) 2014 SUSE LLC
##############################################################################
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 2 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/>.
#
#  Authors/Contributors:
#   Tom Lee (tlee@novell.com)
#   Jason Record (jrecord@suse.com)
#
##############################################################################

##############################################################################
# Module Definition
##############################################################################

import sys, os, Core, SUSE

##############################################################################
# Overriden (eventually or in part) from SDP::Core Module
##############################################################################

META_CLASS = "Filr"
META_CATEGORY = "Java"
META_COMPONENT = "Heap"
PATTERN_ID = os.path.basename(__file__)
PRIMARY_LINK = "META_LINK_TID"
OVERALL = Core.TEMP
OVERALL_INFO = "NOT SET"
OTHER_LINKS = "META_LINK_TID=https://www.novell.com/support/kb/doc.php?id=7012478|META_LINK_BUG=https://bugzilla.novell.com/show_bug.cgi?id=820312"

Core.init(META_CLASS, META_CATEGORY, META_COMPONENT, PATTERN_ID, PRIMARY_LINK, OVERALL, OVERALL_INFO, OTHER_LINKS)
 ##############################################################################
# Local Function Definitions
##############################################################################

def checkJVMHeapSize():
    fileOpen = "memory.txt"
    section = "/proc/meminfo"
    content = {}
    minTotalKB = 8193832
    memTotalKB = -1
    if Core.getSection(fileOpen, section, content):
        for line in content:
            if "MemTotal" in content[line]:
                memTotalKB = int(content[line].split()[1])
                break

    fileOpen = "plugin-vadump_filr.txt"
    section = "/filrinstall/installer.xml"
    content = {}
    heapMax = -1
    if Core.getSection(fileOpen, section, content):
        for line in content:
            if "<JavaVirtualMachine" in content[line]:
                temp = content[line].split()[1]
                heapMax = temp.split('"')[1].strip()
                if( len(heapMax) == 0 ):
                    Core.updateStatus(Core.ERROR, "Error: Missing heap size")
                if (heapMax.endswith("g")):
                    heapMax = heapMax.strip("g")
                    heapMax = int(heapMax) * 1024 * 1024
                else:
                    heapMax = heapMax.strip("m")
                    heapMax = int(heapMax) * 1024
                break
    #print "heapMax=" + str(heapMax) + " (" + str((heapMax*100/memTotalKB)) + "%), memTotalKB=" + str(memTotalKB) + ", memTotalKB-heapMax=" + str((memTotalKB-heapMax))
    if (memTotalKB < minTotalKB):
        return 1
    if (heapMax > memTotalKB):
        return 2
    if ((memTotalKB - heapMax) < (2 * 1024 * 1024)):
        return 3
    if (heapMax < (memTotalKB / 2)):
        return 4
    return 0

##############################################################################
# Main Program Execution
##############################################################################

status = checkJVMHeapSize()
if( status == 1 ):
	Core.updateStatus(Core.WARN, "Insufficient total memory, 8G recommended for large and 12G for all-in-one")
elif( status == 2 ):
	Core.updateStatus(Core.CRIT, "JVM heap size invalid, exceeds total memory size")
elif( status == 3 ):
	Core.updateStatus(Core.WARN, "JVM heap size is set too high, less than 2G of memory remaining")
elif( status == 4 ):
	Core.updateStatus(Core.WARN, "JVM heap size is set too low at less than 50 percent of total memory")
else:
	Core.updateStatus(Core.IGNORE, "JVM heap size OK")

Core.printPatternResults()
