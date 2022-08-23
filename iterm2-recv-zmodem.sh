#!/bin/bash
# Author: Matt Mastracci (matthew@mastracci.com)
# AppleScript from http://stackoverflow.com/questions/4309087/cancel-button-on-osascript-in-a-bash-script
# licensed under cc-wiki with attribution required 
# Remainder of script public domain

EXPECTED_RZPATHS=( /usr/local/bin/rz /opt/homebrew/bin/rz `which rz`)
RZ_BINARY="N/A"
for path in ${EXPECTED_RZPATHS[@]}; do
  if [[ -x $path ]]; then
    RZ_BINARY=$path
    break
  fi
done

if [[ "$RZ_BINARY" == "N/A" ]]; then
  echo "Is 'rz' installed? It was not found in any ot the expected locations: $EXPECTED_RZPATHS. Run 'brew install lrzsz'?"
  exit 1
fi

osascript -e 'tell application "iTerm2" to version' > /dev/null 2>&1 && NAME=iTerm2 || NAME=iTerm
if [[ $NAME = "iTerm" ]]; then
	FILE=$(osascript -e 'tell application "iTerm" to activate' -e 'tell application "iTerm" to set thefile to choose folder with prompt "Choose a folder to place received files in"' -e "do shell script (\"echo \"&(quoted form of POSIX path of thefile as Unicode text)&\"\")")
else
	FILE=$(osascript -e 'tell application "iTerm2" to activate' -e 'tell application "iTerm2" to set thefile to choose folder with prompt "Choose a folder to place received files in"' -e "do shell script (\"echo \"&(quoted form of POSIX path of thefile as Unicode text)&\"\")")
fi

if [[ $FILE = "" ]]; then
	echo Cancelled.
	# Send ZModem cancel
	echo -e \\x18\\x18\\x18\\x18\\x18
	sleep 1
	echo
	echo \# Cancelled transfer
else
	cd "$FILE"
	$RZ_BINARY --rename --escape --binary --bufsize 4096
	sleep 1
	echo
	echo
	echo \# Sent \-\> $FILE
fi
