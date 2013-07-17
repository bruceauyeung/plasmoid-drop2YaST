/**
 * print trace information to console, depending on whether trace is enabled or not.
 * @param {string} message the trace message to be printed to console 
 */
function trace(message, traceFile){
    if(true){
        message = "trace : " + message;
        print(message);
        if(!traceFile){
            traceFile = "/tmp/us.suselinks.plasmoid.drop2YaST.trace.log";
        }
        traceCmd="echo '" + message + "' >>" + traceFile;
        plasmoid.runCommand("sh", ["-c",traceCmd]);
    }
}
function info(message, infoFile){
    if(true){
        message = "info : " + message;
        print(message);
        if(!infoFile){
            infoFile = "/tmp/us.suselinks.plasmoid.drop2YaST.info.log";
        }
        infoCmd="echo '" + message + "' >>" + infoFile;
        plasmoid.runCommand("sh", ["-c",infoCmd]);
        
        
    }
}  
