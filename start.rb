# frozen_string_literal: true

if File.file?('ss.csv')
  require_relative 'bin/starting'
else
  require_relative 'bin/training'
end
