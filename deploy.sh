#!/bin/bash

sudo cp -f ces.1 /usr/share/man/man1/
sudo gzip -f /usr/share/man/man1/ces.1
sudo cp -f ces.auto /etc/bash_completion.d/

