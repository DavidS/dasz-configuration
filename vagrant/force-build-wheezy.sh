#!/bin/bash -e

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
rbenv shell 1.9.2-p320 # for the local shell only
rbenv exec bundle install

nice rbenv exec bundle exec veewee vbox define --force 'Debian-7.1.0-amd64' 'Debian-7.1.0-amd64-netboot'
nice rbenv exec bundle exec veewee vbox build --force 'Debian-7.1.0-amd64'
rbenv exec bundle exec veewee vbox validate 'Debian-7.1.0-amd64'
nice rbenv exec bundle exec veewee vbox export --force 'Debian-7.1.0-amd64'
nice vagrant box add --force 'Debian-7.1.0-amd64' 'Debian-7.1.0-amd64.box'

