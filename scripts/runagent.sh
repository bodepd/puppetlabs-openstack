#!/bin/bash
puppet apply /vagrant/manifests/hosts.pp
puppet agent --server puppetmaster --test --graph --certname $* --graphdir /vagrant/graphs --pluginsync --trace
