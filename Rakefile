# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "rake/extensiontask"
require "rb_sys/extensiontask"

GEMSPEC = Gem::Specification.load("magika.gemspec")

RbSys::ExtensionTask.new("magika", GEMSPEC) do |ext|
  ext.lib_dir = "lib/magika"
  ext.cross_compile = true
end

Rake::TestTask.new do |task|
  task.libs << "test"
  task.pattern = "test/**/*_test.rb"
end

task default: :test
