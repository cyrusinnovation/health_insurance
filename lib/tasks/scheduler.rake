desc "This task is called by the Heroku scheduler add-on"
task :process_new_eobs => :environment do
  puts "Running process new eob jobs"
  FindNewEobs.new
  puts "done."
end

task :submit_eobs => :environment do
  puts 'Running process new eob jobs'
  SubmitEobs.new
  puts 'done.'
end
