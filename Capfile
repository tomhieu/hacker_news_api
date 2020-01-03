require 'capistrano/setup'
require 'capistrano/deploy'

require 'capistrano/bundler'
require 'capistrano/rvm'
require 'capistrano/puma'
require 'whenever/capistrano'


install_plugin Capistrano::Puma
install_plugin Capistrano::Puma::Nginx
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

set :rvm_type, :user
set :rvm_ruby_version, '2.6.02'
