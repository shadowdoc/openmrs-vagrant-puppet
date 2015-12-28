#!/bin/sh
cd /vagrant/puppet/
puppet -c hiera/hiera.yaml apply manifests/site.pp
