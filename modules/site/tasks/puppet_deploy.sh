#!/bin/bash

set -xe

cd /srv/puppet/secrets/

git pull --ff-only

cd /srv/puppet/configuration/

git pull --ff-only

git submodule update --init --recursive

systemctl restart puppetmaster.service

sleep 1
