# config valid for current version and patch releases of Capistrano
lock "~> 3.19.2"

set :application, "OmShakthiHydraulics"
set :repo_url, "git@github.com:Deepanhp/Twilight-Inventory-Management.git"

set :deploy_to, "/home/deploy/om_shakthi_twilight"
set :branch, "main"
set :pty, true
set :keep_releases, 5

set :rbenv_type, :user
set :rbenv_ruby, '3.3.7'
set :bundle_bins, fetch(:bundle_bins, []).push('bundler')
set :default_env, {
  'GIT_SSH_COMMAND' => 'ssh -i ~/.ssh/deploy_key -o IdentitiesOnly=yes',
  PATH: "/home/deploy/.rbenv/shims:/home/deploy/.rbenv/bin:$PATH",
  SECRET_KEY_BASE: '84c35f7bc8ce126a8411514625c647c2a5aaab9d251772c2a6ac56ccc90a6a60b3eb58f7f2a57a1b7edef0fdc7a35a46cea0e1eebaddca9ec0ff1172d55663d6'
}
set :ssh_options, {
  keys: ['~/.ssh/deploy_key'],
  forward_agent: false,
  auth_methods: ['publickey']
}

# Puma config
set :puma_threads, [4, 16]
set :puma_workers, 0
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log, "#{release_path}/log/puma.access.log"
set :puma_preload_app, true
set :puma_prune_bundler, true


# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system", "vendor", "storage"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
