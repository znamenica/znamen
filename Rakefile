desc "Prepare bundler"
task :prebundle do
   sh 'gem install bundler --version "~> 1.3.1" --no-rdoc --no-ri'
end

desc "Requires"
task :req do
   $: << File.expand_path( '../lib', __FILE__ )
   require 'bundler/gem_helper'

   Bundler::GemHelper.install_tasks
end

desc "Prepare bundle environment"
task :pre do
   sh 'bundle install'
end

desc "Distilled clean"
task :distclean do
   sh 'git clean -fd'
   sh 'rm -rf $(find -iname "*~")'
end

task :book do
   sh 'knigodej'
end


task(:default).clear
task :default => :pre

