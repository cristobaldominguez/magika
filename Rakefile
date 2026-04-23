# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"
require "rake/extensiontask"
require "rb_sys/extensiontask"
require "socket"
require "timeout"

GEMSPEC = Gem::Specification.load("magika.gemspec")

module MagikaBuild
  ONNX_RUNTIME_HOST = "cdn.pyke.io"
  ONNX_RUNTIME_PORT = 443
  NETWORK_TIMEOUT_SECONDS = 3

  class Error < StandardError; end

  module_function

  def check_onnx_runtime_network!
    return if ENV["MAGIKA_SKIP_NETWORK_PREFLIGHT"] == "1"
    return if ENV["ORT_LIB_LOCATION"] || ENV["ORT_IOS_XCFWK_LOCATION"]

    Timeout.timeout(NETWORK_TIMEOUT_SECONDS) do
      TCPSocket.open(ONNX_RUNTIME_HOST, ONNX_RUNTIME_PORT, &:close)
    end
  rescue SocketError, SystemCallError, Timeout::Error => error
    raise Error, <<~MESSAGE
      Magika native build cannot reach ONNX Runtime binaries.

      The first native build downloads ONNX Runtime via ort-sys from:
        https://#{ONNX_RUNTIME_HOST}

      Network check failed: #{error.class}: #{error.message}

      Fix one of these before running `bundle exec rake compile` again:
        - connect to the internet or allow HTTPS access to #{ONNX_RUNTIME_HOST}
        - configure a local ONNX Runtime with ORT_LIB_LOCATION
        - set MAGIKA_SKIP_NETWORK_PREFLIGHT=1 if the runtime is already cached
    MESSAGE
  end
end

namespace :magika do
  namespace :build do
    desc "Check whether ONNX Runtime binaries can be downloaded or provided locally"
    task :check_onnx_runtime_network do
      MagikaBuild.check_onnx_runtime_network!
    rescue MagikaBuild::Error => error
      abort "\n#{error.message}"
    end
  end
end

desc "Compile all the extensions"
task "compile" => ["magika:build:check_onnx_runtime_network"]

RbSys::ExtensionTask.new("magika", GEMSPEC) do |ext|
  ext.lib_dir = "lib/magika"
  ext.cross_compile = true
end

Rake::TestTask.new do |task|
  task.libs << "test"
  task.pattern = "test/**/*_test.rb"
end

task default: :test
