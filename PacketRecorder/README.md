# openkore Packet Recorder
Plugin to create a log of Received/Sended Packets

### Usage:
* 1 - Create a PacketRecorder folder inside of openkore\plugins folder
* 2 - Copy the PacketRecorder.pl plugin to openkore\plugin\PacketRecorder\
* 3 - Enable Plugin in openkore\control\sys.txt
```
loadPlugins_list PacketRecorder
```
* 4 - add to openkore\src\network\Send.pm in sub sendToServer:
```
Plugins::callHook('sendMessage/pre', { msg => $msg });
```
* before of:
```
$self->encryptMessageID(\$msg);
```
* 5 - Start openkore

### Warnings
Log will be created in:
logs\packtes.txt

### Credits
Plugin made by alisonrag
