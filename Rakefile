require "bundler/gem_tasks"

desc "Prepare bundle environment"
task :pre do
   sh 'bundle install'
end

task :book do
   sh './bin/book.rb'
end

task(:default).clear
task :default => :pre

