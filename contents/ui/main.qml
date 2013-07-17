import QtQuick 1.1
import org.kde.draganddrop 1.0
import "../code/logger.js" as Log
import "../code/utils.js" as Utils

Rectangle {
    
     width: 200
     height: 100
     color: "white"
     border.color: "grey"
     border.width: 1
     radius: 1
     smooth: true
    Text {
        id: board
        property int minimumWidth: paintedWidth
        property int minimumHeight: paintedHeight
        text: "drop a ymp file link here...";
    }     
     DropArea {
        enabled: true
        anchors.fill: parent
        onDrop: {
            var ympContentTypes = ["text/x-suse-ymp"];
            var isYmpFile = false;
            
            Log.trace("URL:"+event.mimeData.url);
            var xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function() {
                if (xhr.readyState == XMLHttpRequest.HEADERS_RECEIVED) {
                    //Log.trace(xhr.getAllResponseHeaders());
                    var ctype = xhr.getResponseHeader("content-type");
                    if(ctype.indexOf(";")){
                        ctype = ctype.substring(0, ctype.indexOf(";"));
                    }
                    Log.trace("content-type : " + ctype);
                    if(ympContentTypes.containsIgnoreCase(ctype)){
                        isYmpFile=true;
                    }
                    
                } else if (xhr.readyState == XMLHttpRequest.DONE) {
                    if (xhr.status == 200)
                    {
                        Log.trace("downloading finished...");
                        board.text="downloading finished...";
                        //var fileContent = xhr.responseXML.xhrumentElement;
                        var fileContent = xhr.responseText;
                        if(isYmpFile){
                            Log.trace("valid ymp file.");
                            
                            var tempYmp = Utils.getTempFile(".ymp");
                            Utils.writeToFile(fileContent, tempYmp);
                            plasmoid.runCommand("sh", ["-c", "xdg-open " + tempYmp]);
                            board.text="drop a ymp file link here...";
                        }else{
                            Log.trace("invalid ymp file.");
                        }
                    }
                    else
                    {
                        Log.trace("http request error : " + xhr.status);
                    }                    
                }
            }

            xhr.open("GET", event.mimeData.url);
            xhr.send(); 
            Log.trace("downloading started...");
            board.text="downloading started...";
        }
    }
 } 
