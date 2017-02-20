# -*- coding: utf-8 -*-

require 'pluggaloid'

Delayer.default = Delayer.generate_class(priority: %i<high normal low>, default: :normal)
Plugin = Class.new(Pluggaloid::Plugin)

Dir.glob(File.join(__dir__, 'plugin', '*.rb')) do |file|
  load file
end

Delayer.register_remain_hook do
  Thread.main.wakeup
end

loop do
  Thread.stop if Delayer.empty?
  Delayer.run
end
