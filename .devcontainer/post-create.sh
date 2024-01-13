#! /bin/sh
npm install
pip3 install -r requirements.txt --break-system-packages --no-warn-script-location
export PATH="$HOME/.local/bin:$PATH"
