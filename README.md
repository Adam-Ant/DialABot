# Dial-A-Bot
A VOIP/SIP bridge to a Teamspeak server

## Usage
This container expects a volume mounted at `/config` inside the container, with a file callued pjsua.cfg containing your VOIP connection details. Please see pjsua.cfg.example for usage.

### Teamspeak Initial setup
As Teamspeak does not provide an easy way to automate its settings & bookmark management, initial configuration must be done manually. Upon container first run, access the Teamspeak GUI by running `docker exec <container_name> vnc`, then connecting via VNC on port 5900.

Upon connecting via VNC, there are a few required steps:
1. Open the Bookmarks Manager. Create a bookmark for the desired server, including a default channel if required. 
2. Select "Go Advanced" in the bookmark manager. Make sure that "Connect on Startup" is selected.
3. Open Settings, and go to Playback. Change the playback device to TeamspeakPlayback.
4. Select Capture and change the capture device to TeamspeakCapture.
5. Save settings & close. Restart the container & verify the bot successfully connects. Place a test call to check sound is being routed correctly.

## Example run line

`docker run -d --name "DialABot" --restart on-failure:10 -v /path/to/config:/config Adam-Ant/DialABot`
