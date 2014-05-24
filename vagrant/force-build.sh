#!/bin/bash -e

VERSION="${VERSION:-Debian-7.5.0-amd64}"
TEMPLATE="${TEMPLATE:-$VERSION-netboot}"
BOXNAME="${BOXNAME:-$VERSION-$(date --utc --iso)}"
export VEEWEE_USE_SYSTEMD=yes

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
rbenv shell 1.9.2-p320 # for the local shell only
rbenv exec bundle install

rbenv exec bundle exec veewee vbox define --force "$BOXNAME" "$TEMPLATE"
rbenv exec bundle exec veewee vbox build --force "$BOXNAME"
rbenv exec bundle exec veewee vbox validate "$BOXNAME"
rbenv exec bundle exec veewee vbox halt "$BOXNAME"
sleep 10 # yes, really: virtualbox doesn't unlock the VM fast enough after this (vagrant-1.4.3)
nice rbenv exec bundle exec veewee vbox export --force "$BOXNAME"
nice vagrant box add --force "$BOXNAME" "$BOXNAME.box"

