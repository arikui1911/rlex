if ENV['COVERAGE']
  begin
    require 'simplecov'
    SimpleCov.start
    Dir.glob(File.join(__dir__, "../lib/**/*.rb")).each(&method(:require))
  rescue LoadError
  end
end
