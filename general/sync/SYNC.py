#!/usr/bin/python3
# -*- coding: utf-8 -*-
# This script is intended for use on UNIX-Systems and relies on the 'rsync' utility

import json
import os, sys, subprocess
import datetime

'''
0:  No logging
1:  Only Errors
2:  Errors + Warnings
3:  everything (Info + Warnings + Error)
100: include debug messages
'''
LOG_LEVEL = 100;
RETURN_STATUS = 0;
VERBOSE = False;

def printDebug(s):
    if(LOG_LEVEL >= 100): print("[DEBUG]: "+s)

def log_info(s):
    if (LOG_LEVEL >= 3): print("[INFO]: "+s);
    
def log_warning(s):
    global RETURN_STATUS;
    if (LOG_LEVEL >= 2): print("[WARN]: "+s);
    if (RETURN_STATUS < 2): RETURN_STATUS = 2;
    
def log_error(s):
    global RETURN_STATUS;
    if (LOG_LEVEL >= 1): print("[EROR]: "+s);
    if (RETURN_STATUS < 3): RETURN_STATUS = 3;


def log_InvalidJSON(obj, msg = "Not a valid File-SyncJson"):
    log_error(msg);
    log_error(json.dumps(obj, sort_keys=True, indent=4));
    
def logByIndicator(baseMsg, errorFlag):
    if(errorFlag == 0):
        log_info(baseMsg + " succesfully.")
    elif(errorFlag == 1):
        log_warning(baseMsg + " with warnings.")
    else:
        log_error(baseMsg + " with ERRORS.")




def syncPlaces(source, destination, filterRules = None, mode = "EXT4"):
    retCode = 0
    modes = {"EXT4": "-urltEXgop", "NTFS": "-urltEX --no-perms --no-owner --no-group"}
    logPath = "/tmp/oneric_sync_"+str(os.getppid())+"_rsyncLog"
    if(filterRules is not None):
        filterPath = "/tmp/oneric_sync_" + str(os.getppid()) + "_filters"
        filterFile = open(filterPath, "w")
        included = set()
        for line in filterRules:
            filterFile.write(line + "\n")
            #if(line.startswith('+') or linestartswith('include')):
            #    TODO
        #for line in ignore:
        #    if(line.startswith('-')):
        #        excludeFile.write(line[1:] + "\n")
        #    elif(line.startswith('+')):
        #        includeFile.write(line[1:] + "\n")
        #    else:
        #        log_InvalidJSON(line, "Ignore patterns must begin with + To include and with - to exclude")
        #        #### TO DO change JSON to seperate in and exclude to avoid issues wit h file/dirnames starting with +-
        #        ### Report error appropieatly
        filterFile.close()
    else:
        filterPath = None
    #if(include is not None):
    #    inPath = "/tmp/oneric_sync_" + str(os.getppid()) + "_in"
    #    includeFile = open(inPath, "w")
    #    includeFile.close()
    #else:
    #    inPath = None
    
    logFile = open(logPath, "a")
    startTime = str(datetime.datetime.now())
    logFile.write("New rsync-Instance at work\n\t")
    logFile.write("Time: "+startTime+"\n")
    logFile.flush()
    command = "rsync " + modes[mode]
    if (VERBOSE):
        command += " -v"
    command += (" --filter='merge "+filterPath+"' ") if filterPath is not None else " "
    command += '"'+source+'" '
    #command += '"$(dirname "'+destination+'")" '
    command += '"'+destination+'" '
    #command += '2>&1 | tee -a "'+logPath+'"'
    #Now for logging the output including stderr and print it, while keeping exit status
    command += '> >(tee -a "'+logPath+'") 2> >(tee -a "'+logPath+'" >&2)'
    rsync_res = None
    try:
        rsync_res = subprocess.run(command, shell=True, check=True, executable='/bin/bash')
    except subprocess.CalledProcessError as e:
        log_error("Rsync failed, instance started at "+startTime+" check logfile !")
        retCode = 2
    except OSError as e:
        log_error("rsync not installed !")
        sys.exit(10);
        
    logFile.write("Rsync finished:\n")        
    if(rsync_res is not None and rsync_res.returncode != 0):
        log_error("  Rsync-Error occured in instance started at "+startTime+", please check output, or logfile '"+logPath+"' !\n")
        retCode = 2
    if(rsync_res is not None):
        logFile.write("  Rsync exit code: "+str(rsync_res.returncode)+"\n")
    logFile.write("\n")
    logFile.close()

    #print("NOT YET IMPLEMENTED");
    #'''
    #        rsync -urltEX --no-perms --no-owner --no-group --exclude-from="$exPath" --include-from="$exPath" "$SOURCE_ROOT$i" "$(dirname "$DESTIN_ROOT$i")" >> "$LOGFILE" 2>&1
    #'''
    
    if(filterPath is not None):
        os.remove(filterPath)
        printDebug("lol")
    return retCode
    

def getOptionalList(entry, fieldName):
    ignore = entry.get(fieldName, None)
    if(not (ignore is None)):
        if(not isinstance(ignore, list)):
            log_InvalidJSON(entry, "Field 'ignore' must be a string list !")
            ignore = float('Inf');
        if (len(ignore) == 0):
            ignore = None
        elif (not isinstance(ignore[0], str)):
            log_InvalidJSON(entry, "Field 'ignore' must be a string list !")
            ignore = float('Inf')
    return ignore

def processFileInput(files):
    for f in files:
        with open(f, "r", 32) as json_file:
            errorFlag_file = 0;
            data = json.load(json_file);
            for file_set in data:
                if "files" not in file_set: 
                    log_InvalidJSON(file_set)
                    continue
                log_info("Start syncing " + file_set.get("NAME", "[Unnamed]"));
                mode = file_set.get("mode", "EXT4")
                errorFlag_set = 0;
                for entry in file_set["files"]:    
                    if ("source" not in entry) or ("destination" not in entry):
                        log_InvalidJSON(entry);
                        continue
                    filtRules = getOptionalList(entry, "filterRules")
                    if(filtRules == float('Inf')):
                        continue;
                    
                    rc = syncPlaces(entry["source"], entry["destination"], filtRules, mode);
                    if(rc > errorFlag_set):
                        errorFlag_set = rc
                    
                logByIndicator("Finished "+file_set.get("NAME", "[Unnamed]"), errorFlag_set)
                if(errorFlag_set > errorFlag_file):
                    errorFlag_file = errorFlag_set
            logByIndicator("Finished file '"+f+"'", errorFlag_file)
    logByIndicator("Finished", RETURN_STATUS)
                    
                    




def main(argv):
    global VERBOSE;
    #argv = ["/home/koenig/Schreibtisch/SYNC_PC.json"];
    log_info("Starte Script with arguments " + str(argv));
    if(len(argv) > 0 and argv[0] == "-v"):
        VERBOSE = True;
        argv = argv[1:]
    if(len(argv) == 0):
        log_error("No sync file provided")
        log_info("Correct use is 'command [-v] files …'")
        
    for f in argv:
        if not os.path.exists(f):
            log_error(f + " does not exists !");
            return 1;
    
    processFileInput(argv);
    return RETURN_STATUS;
    

if  __name__ =='__main__':
    main(sys.argv[1:])
    sys.exit(RETURN_STATUS)
    
    


