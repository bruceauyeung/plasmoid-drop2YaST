import QtQuick 1.1
import org.kde.draganddrop 1.0
import "../code/logger.js" as Log
import "../code/utils.js" as Utils

Rectangle {
    
     width: 240
     height: 100
     color: "transparent"
     border.color: "transparent"
     border.width: 1
     radius: 1
     smooth: true
    Text {
        id: board
        property int minimumWidth: paintedWidth
        property int minimumHeight: paintedHeight
        color:"red"
        textFormat:Text.StyledText
        wrapMode:Text.WordWrap
        text: "drop a ymp file link here...";
    }     
     DropArea {
        enabled: true
        anchors.fill: parent
        onDrop: {
            var ympContentTypes = ["text/x-suse-ymp"];
            var isYmpFile = false;
            
            Log.trace(event.mimeData.url);
            
            // for(var propertyName in event.mimeData.url) {
            //     Log.trace(event.mimeData.url[propertyName]);
            // }
            // Log.trace( typeof (event.mimeData.url));
            
            // it's really weird that event.mimeData.url's type is object, but contains no any property ! 
            // but can get its value by "" + event.mimeData.url
            // and if you directly call string's method on it ,qml script stop execution and raise no error !
            var ympFile="" + event.mimeData.url;
            if(ympFile.startsWithIgnoreCase("file://")){
                Log.trace("local file");
                var ympFile = ympFile.substring(7);
                if(ympFile.endsWithIgnoreCase(".ymp")){
                    
                    if(plasmoid.runCommand("sh", ["-c", "xdg-open " + ympFile])){
                        Log.trace("One-Click-Installer started, <br>drop a ymp file link here...");
                        board.text="One-Click-Installer started, <br>drop a ymp file link here...";  
                    }else{
                        Log.trace("failed to start One-Click-Installer.");
                        board.text="failed to start One-Click-Installer.";                                   
                    }                      
                }
              
            }else{
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
                        }else{
                            // this line code cause plasma-desktop crashed.
                            // xhr.abort();
                            
                        }
                        
                    } else if (xhr.readyState == XMLHttpRequest.DONE) {
                        if (xhr.status == 200)
                        {
                            Log.trace("downloading finished...");
                            board.text="downloading finished...";
                            if(isYmpFile){
                                Log.trace("valid ymp file.");
                                var fileContent = xhr.responseText;
                                var tempYmp = Utils.getTempFile(".ymp");
                                Utils.writeToFile(fileContent, tempYmp);
                                if(plasmoid.runCommand("sh", ["-c", "xdg-open " + tempYmp])){
                                    Log.trace("One-Click-Installer started, <br>drop a ymp file link here...");
                                    board.text="One-Click-Installer started, <br>drop a ymp file link here...";  
                                }else{
                                    Log.trace("failed to start One-Click-Installer.");
                                    board.text="failed to start One-Click-Installer.";                                   
                                }
                            }else{
                                Log.trace("invalid ymp file.");
                                board.text="invalid ymp file.";                            
                            }
                        }
                        else
                        {
                            Log.trace("http request error : " + xhr.status);

                        }                    
                    }
                }

                xhr.open("GET", event.mimeData.url, true);
                xhr.send(); 
                Log.trace("downloading started...");
                board.text="downloading started...";                 
            }
        }
    }
 } 
