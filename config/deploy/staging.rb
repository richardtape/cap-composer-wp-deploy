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