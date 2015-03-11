# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'test_deploy'
set :repo_url, 'git@bitbucket.org:mbcx9rvt/deploy-test.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
# set :deploy_to, '/sites'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :error
set :log_level, ask('What log level?', 'error')

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 3





# If we're doing a rollback, we don't want to do our custom tasks
namespace :deploy do

	# Add a file to say we're rolling back
	# This is only run if we are doing a rollback
	desc 'Declare rollback by creating temp file'
	task :declarerollback do

		on roles :app do

			createrollbackfile()

		end

	end

	before :reverting, :declarerollback

	# At the end of the rollback, remove the file
	desc 'Remove the temp file we created to declare we are rolling back'
	task :undeclarerollback do

		on roles :app do

			deleterollbackfile()

		end

	end

	before :finishing_rollback, :undeclarerollback

end



# Our custom tasks for running composer and making WP Symlinks and error log file
namespace :deploy do

	namespace :symlink do

		task :runcomposer do

			on roles :app do

				if test "[ -f #{fetch(:deploy_to)}/isrollback.txt ]"

					puts "\n" + '[ ' + green( 'ROLLBACK' ) + " ] Skipping composer "

				else

					runcomposer( 'install' )

				end

			end

		end


		task :makewpsymlinks do

			on roles :app do

				if test "[ -f #{fetch(:deploy_to)}/isrollback.txt ]"

					puts "\n" + '[ ' + green( 'ROLLBACK' ) + " ] Skipping symlinks "

				else

					createsymlinks()

				end

			end

		end

		task :makeerrorlog do

			on roles :app do

				if test "[ -f #{fetch(:deploy_to)}/isrollback.txt ]"

					puts "\n" + '[ ' + green( 'ROLLBACK' ) + " ] Skipping error logs "

				else

					makeerrorlog()

				end

			end

		end

		before :release, :runcomposer
		before :release, :makewpsymlinks
		before :release, :makeerrorlog

	end

end


# some output methods to declare we've started and ended
namespace :deploy do

	timestart = Time.now
	username=`whoami`

	# Let's announce we've started
	desc 'Put message on the console that the process has begun'
	task :declarestarted do

		on roles :app do

			puts "\n" + '[ ' + green( 'STARTED' ) + " ] deployment to " + blue( "#{fetch(:deploy_to)}" ) + " at #{timestart} by " + blue( "#{username}" )

		end

	end

	# Let's announce we've finished
	desc 'Put message on the console that the process has ended'
	task :declarefinished do

		on roles :app do

			timefinished = Time.now

			timeTaken = time_diff_milli timestart, timefinished
			puts "\n" + '[ ' + green( 'COMPLETED' ) + " ] Deployment in #{timeTaken} seconds. Nice!"

			# If we are on a mac, then display a notification
			darwinifmac=`uname`
			if [[ darwinifmac == 'darwin' ]]
				`osascript -e 'display notification "Deployment has completed to #{fetch(:deploy_to)}" with title "Deployment Complete"'`
			end

		end

	end

	before :starting, :declarestarted
	before :finished, :declarefinished

end


# Realistically this task is only here to be used once, at the very beginning. But it's necessary to test everything and
# set up directories. I don't like the fact it's needed on both stages, but what can you do? (someone tell me, please!)
namespace :deploy do

	# This task should only be needed once, but simply sets up the bits and pieces we need for a cap setup
	desc 'Set up the directories we need for capistrano deploy'
	task :setup do

		on roles :app do

			createdirectories()

		end
		
	end

end





# Helper function to get elapsed time
def time_diff_milli( start, finish )

	( finish - start )

end


# Helper functions for colorizing our output
def colorize( text, color_code )

	"#{color_code}#{text}\e[0m"

end

# Extra helper functions for specific colours
def red( text ); colorize( text, "\e[31m" ); end
def green( text ); colorize( text, "\e[32m" ); end
def blue( text ); colorize( text, "\e[34m" ); end
def yellow( text ); colorize( text, "\e[33m" ); end


# Wrapper function to create error logs
# changes into the release path/content then creates a debug.log file chmods to 777 so it's writable
def makeerrorlog()

	puts "\n" + '[ ' + yellow( 'RUNNING' ) + " ] Make error logs"
	execute "cd #{release_path} && cd content && touch debug.log && chmod 777 debug.log"
	puts '[ ' + green( 'SUCCESS' ) + ' ] Error Logs Created'

end;

# Wrapper function for composer install
# Argument is the actual composer command to run (as it may be different on different stages)
def runcomposer( command )

	composertimestart = Time.now
					
	puts "\n" + '[ ' + yellow( 'RUNNING' ) + " ] Composer #{command} (may take a while)"

	execute "cd #{release_path} && composer #{command}"

	composertimefinished = Time.now
	timeTaken = time_diff_milli composertimestart, composertimefinished

	puts '[ ' + green( 'SUCCESS' ) + ' ] composer ' + "#{command} completed in " + "#{timeTaken}seconds"

end


# Wrapper function for the setup command on the server
# Simply creates the requisite directories
def createdirectories()

	puts "\n" + '[ ' + yellow( 'RUNNING' ) + " ] Setup"

	execute "mkdir -p #{fetch(:deploy_to)}/releases"
	execute "mkdir -p #{shared_path}"

	puts '[ ' + green( 'SUCCESS' ) + ' ]'

end


# Wrapper function to make symlinks
def createsymlinks()

	puts "\n" + '[ ' + yellow( 'RUNNING' ) + " ] Make WordPress symlinks"

	execute "cd #{release_path} && cd content && mkdir -p mu-plugins"
	execute "cd #{release_path} && ln -s #{shared_path}/index.php index.php"
	execute "cd #{release_path} && ln -s #{shared_path}/wp-config.php wp-config.php"
	execute "cd #{release_path} && cd content && ln -s #{shared_path}/uploads uploads"
	execute "cd #{release_path} && cd content/ && ln -s #{release_path}/wp/wp-content/themes themes"
	execute "cd #{release_path} && cd content/mu-plugins && ln -s #{shared_path}/subdir-loader.php subdir-loader.php"
	execute "cd #{release_path} && cd content/plugins/memcached && rm object-cache.php"
	execute "cd #{release_path} && cd content/plugins/memcached && ln -s #{shared_path}/object-cache.php object-cache.php"

	puts '[ ' + green( 'SUCCESS' ) + ' ] Symlinks Created'

end


# Wrapper function to make a rollback.txt file if we're actually doing a rollback
def createrollbackfile()

	execute "cd #{fetch(:deploy_to)}/ && touch isrollback.txt"

end

# Wrapper function to delete the rollback.txt file on cleanup after finishing a rollback
def deleterollbackfile()

	execute "cd #{fetch(:deploy_to)}/ && rm isrollback.txt"

end