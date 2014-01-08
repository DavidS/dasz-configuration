#!/bin/bash -e

VERSION="Debian-7.2.0-amd64"

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"
rbenv shell 1.9.2-p320 # for the local shell only
rbenv exec bundle install

nice rbenv exec bundle exec veewee vbox define --force "$VERSION" "$VERSION-netboot"
nice rbenv exec bundle exec veewee vbox build --force "$VERSION"
rbenv exec bundle exec veewee vbox validate "$VERSION"
nice rbenv exec bundle exec veewee vbox export --force "$VERSION"
nice vagrant box add --force "$VERSION" "$VERSION.box"

