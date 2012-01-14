set :stages, %w(production)
set :default_stage, 'production'
require 'capistrano/ext/multistage'

set :application, "hackerspursuit"
set :domain,      "hackerspursuit.com"
set :user,        "hackerspursuit"
set :repository,  "git@github.com:9elements/hackerspursuit.git"

set :use_sudo,    false

ssh_options[:forward_agent] = true
set :scm, :git
set :deploy_via, :remote_cache
set :git_enable_submodules, 1

role :app, domain
role :web, domain
role :db,  domain, :primary => true

namespace :deploy do
  task(:start,   :roles => :app) {}
  task(:stop,    :roles => :app) {}
  task :refresh_symlink do
    run "rm -rf #{current_path}/config.coffee && ln -s #{shared_path}/config.coffee #{current_path}/config.coffee"
  end
  task(:restart, :roles => :app, :except => { :no_release => true }) {
    run "cd #{current_path}; npm install; forever stopall; NODE_ENV=#{node_env} forever start -c coffee server.coffee"
  }
end

after "deploy:symlink", "deploy:refresh_symlink"