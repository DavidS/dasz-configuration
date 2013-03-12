# Installing the requirements

## rbenv, to make the ruby experience bearable

https://github.com/sstephenson/rbenv/
https://github.com/sstephenson/ruby-build

    git clone git://github.com/sstephenson/rbenv.git ~/.rbenv
    git clone git://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
    export PATH="$HOME/.rbenv/bin:$PATH"
    eval "$(rbenv init -)"

Note: sstephenson recommends putting init commands into .bash\_profile, which
will disable your normal .profile processing in Debian.

## create a local ruby install to disconnect us from any system installation

    sudo aptitude install build-essential zlib1g-dev libssl-dev libxslt-dev libxml2-dev libreadline-dev
    rbenv install 1.9.2-p320
    rbenv shell 1.9.2-p320 # for the local shell only

## veewee, to build local test boxes for vagrant

https://github.com/jedi4ever/veewee/blob/master/doc/installation.md

I've added the snapshot of veewee I've used as submodule at vagrant/veewee.

    cd vagrant/veewee
    rbenv exec gem install bundler
    rbenv exec bundle install

## building your baseboxes

All of the following commands need to run from the vagrant/veewee directory, in
veewee's development mode:

    rbenv exec bundle exec vagrant basebox define 'Debian-7.0.0-amd64' 'Debian-7.0-rc1-amd64-netboot'
    rbenv exec bundle exec vagrant basebox build 'Debian-7.0.0-amd64'
    
Now you have a virtual box with wheezy running. You can login either with
vagrant:vagrant or using vagrant's low-security ssh key to connect as root.
Let's check whether everything installed fine.

    rbenv exec bundle exec vagrant basebox validate 'Debian-7.0.0-amd64'

Now package up the box as basebox, which we can use for our work.

    rbenv exec bundle exec vagrant basebox export 'Debian-7.0.0-amd64'

Copy the 'Debian-7.0.0-amd64.box' file to some permanent storage.
Then, import it from there into vagrant proper. This can use the non-veewee
vagrant as packaged in Debian. Taste the sweetness of freedom!

    vagrant box add 'Debian-7.0.0-amd64' 'Debian-7.0.0-amd64.box'

