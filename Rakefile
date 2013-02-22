#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require 'rvm/capistrano'
require File.expand_path('../config/application', __FILE__)

Bringit::Application.load_tasks

namespace :repo do
  desc "Resets all repositories"
  task reset: 'db:migrate:reset' do
    system("rm -rf " + Bringit::Application.config.git_root)
    system("mkdir -p " + Bringit::Application.config.git_root)
    Rake::Task["db:seed"].execute
    puts "Repositories reset"
  end
end
