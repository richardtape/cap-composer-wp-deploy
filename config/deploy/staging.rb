# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

role :app, %w{deployer@123.456.789.013}

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.

server '123.456.789.013', user: 'deployer', roles: %w{web app}

set :deploy_to, '/sites/www.yourdomain.com/staging'

set :ssh_options, {
    forward_agent: true,
    keys: %w(~/.ssh/id_rsa),
    auth_methods: %w(publickey),
    user: 'deployer'
}

# If we're doing a rollback, we don't want to do our custom tasks
namespace :deploy do

	# Add a file to say we're rolling back
	# This is only run if we are doing a rollback
	desc 'Declare rollback by creating temp file'
	task :declarerollback do

		on roles :app do

			execute "cd /sites/www.yourdomain.com/staging/ && touch isrollback.txt"

		end

	end

	before :reverting, :declarerollback

	# At the end of the rollback, remove the file
	desc 'Remove the temp file we created to declare we are rolling back'
	task :undeclarerollback do

		on roles :app do

			execute "cd /sites/www.yourdomain.com/staging/ && rm isrollback.txt"

		end

	end

	before :finishing_rollback, :undeclarerollback

end


# Our custom tasks for running composer and making WP Symlinks
namespace :deploy do

	namespace :symlink do

		task :runcomposer do

			on roles :app do

				if test "[ -f /sites/www.yourdomain.com/staging/isrollback.txt ]"

					execute "echo 'ROLLBACK: Skip Composer'"

				else

					thisnewreleasedir = capture('ls -t /sites/www.yourdomain.com/staging/releases | head -1')

					execute "cd /sites/www.yourdomain.com/staging/releases/#{thisnewreleasedir} && composer install"

				end

			end

		end


		task :makewpsymlinks do

			on roles :app do

				if test "[ -f /sites/www.yourdomain.com/staging/isrollback.txt ]"

					execute "echo 'ROLLBACK: Skip Creating WP Symlinks'"

				else

					thisnewreleasedir = capture('ls -t /sites/www.yourdomain.com/staging/releases | head -1')

					execute "cd /sites/www.yourdomain.com/staging/releases/#{thisnewreleasedir} && cd content && mkdir -p mu-plugins"
					execute "cd /sites/www.yourdomain.com/staging/releases/#{thisnewreleasedir} && ln -s /sites/www.yourdomain.com/staging/shared/index.php index.php"
					execute "cd /sites/www.yourdomain.com/staging/releases/#{thisnewreleasedir} && ln -s /sites/www.yourdomain.com/staging/shared/wp-config.php wp-config.php"
					execute "cd /sites/www.yourdomain.com/staging/releases/#{thisnewreleasedir} && cd content && ln -s /sites/www.yourdomain.com/staging/shared/uploads uploads"
					execute "cd /sites/www.yourdomain.com/staging/releases/#{thisnewreleasedir} && cd content/plugins/memcached && rm object-cache.php"
					execute "cd /sites/www.yourdomain.com/staging/releases/#{thisnewreleasedir} && cd content/plugins/memcached && ln -s /sites/www.yourdomain.com/staging/shared/object-cache.php object-cache.php"
					execute "cd /sites/www.yourdomain.com/staging/releases/#{thisnewreleasedir} && cd content/mu-plugins && ln -s /sites/www.yourdomain.com/staging/shared/subdir-loader.php subdir-loader.php"

				end

			end

		end

		before :release, :runcomposer
		before :release, :makewpsymlinks

	end

end