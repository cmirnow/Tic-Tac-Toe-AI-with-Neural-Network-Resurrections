# frozen_string_literal: true

if File.file?('ss.csv')
  require_relative './src/starting'
else
  require_relative './src/training'
end
