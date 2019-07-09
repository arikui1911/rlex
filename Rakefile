require 'rake/testtask'
Rake::TestTask.new do |t|
  t.warning = true
end

desc 'Run tests and report coverage'
task :cov do
  ENV['COVERAGE'] = '1'
  Rake::Task[:test].invoke
end

begin
  require 'yard'
  require 'yard/rake/yardoc_task'
  YARD::Rake::YardocTask.new do |t|
  end
rescue LoadError
  require 'rdoc/task'
  RDoc::Task.new do |t|
  end
end


