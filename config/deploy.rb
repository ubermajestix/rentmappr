set :application, "rentmappr"

#SCM settings
set :repository,  "git@github.com:ubermajestix/rentmappr.git"
set :scm, "git"
set :branch, "origin/master"
# set :repository_cache, "git_cache"
 set :deploy_via, :remote_cache


# Sudoer settings      
set :use_sudo               , true
set :user                   , "tyler"
set :runner                 , "root"
default_run_options[:shell] = false
default_run_options[:pty]   = true
set :ssh_options, { :forward_agent => true }
set :chmod755, "app config db lib public vendor script script/* public/disp*"

# Deployment servers
role :app, "rentmappr.com"
role :web, "rentmappr.com"
role :db,  "rentmappr.com", :primary => true
set :deploy_to, "/home/tyler/apps/deployed/#{application}"

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end

  desc "restart apache"
  task :bounce_apache do
    sudo "/etc/init.d/httpd restart"
  end

  desc "reload apache configs"
  task :reload_apache do
    sudo "/etc/init.d/httpd reload"
  end
end

desc "tail log files"
task :tail_logs, :roles => :app do
  run "tail -f #{shared_path}/log/production.log" do |channel, stream, data|
    puts  # for an extra line break before the host name
    puts "#{channel[:host]}: #{data}"
    break if stream == :err
  end
end

#	Restart Passenger(mod_rails)
namespace :passenger do
  desc "Restart Application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end
end
after :deploy, "passenger:restart"
