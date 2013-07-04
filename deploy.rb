set :application, ""
set :repository,  ""

set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

set :deploy_to, ""

set :deploy_via, :remote_cache
set :copy_exclude, [".git", ".DS_Store", ".gitignore"]
set :git_enable_submodules, 1

set :use_sudo, false

role :web, ""                          # Your HTTP server, Apache/etc
role :web, ""
#role :app, "your app-server here"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

namespace :deploy do

  desc <<-DESC
  A macro-task that updates the code and fixes the symlink.
  DESC
  task :default do
    transaction do
      update_code
      symlink
    end
  end
 

 
  task :update_code, :except => { :no_release => true } do
    on_rollback { run "rm -rf #{release_path}; true" }
    strategy.deploy!
  end

  task :after_deploy do
    cleanup
  end

  task :after_symlink do
      # NFS mounted directory for uploads, this is probably specific to my setup.
      run "ln -nfs " \
      " #{current_path}/wordpress/wp-content/"

      run "ln -sf #{shared_path}/config/wp-config.php #{current_path}/wordpress/wp-config.php"

      # link in plugins
      run "for i in `ls #{current_path}/plugins`; do ln -sf #{current_path}/plugins/$i #{current_path}/wordpress/wp-content/plugins/$i; done"

      # link in templates
      run "for i in `ls #{current_path}/themes`; do echo $i; ln -sf #{current_path}/themes/$i #{current_path}/wordpress/wp-content/themes/$i; done"
  end
    
end
