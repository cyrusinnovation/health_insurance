desc "This task is called by the Heroku scheduler add-on"
task :process_new_eobs => :environment do
  puts "Updating users..."
  FindNewEobs.new
  puts "done."
end

task :submit_new_eobs => :environment do
  #User.send_reminders
end
