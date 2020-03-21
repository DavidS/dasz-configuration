dasz-configuration
==================

Configuration for my company's infrastructure

[![Build Status](https://travis-ci.org/DavidS/dasz-configuration.png?branch=master)](https://travis-ci.org/DavidS/dasz-configuration)

Deployment
----------

run 

```
bolt task --modulepath ./modules run site::puppet_deploy -t puppetmaster.dasz.at:2200 --run-as root
```

to deploy staged code to the puppetmaster
