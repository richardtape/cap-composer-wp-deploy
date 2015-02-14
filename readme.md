== Deployment mechanism for WordPress using Capistrano and Composer

+ Clone repo to your local machine
+ Change the config/deploy/production.rb and config/deploy/staging.rb files to match your server credentials (IP Address, user, roles, paths)
+ Adjust the composer.json file to match what you want to install
+ cap staging deploy or cap production deploy
+ type 'debug' if you want to see everything that happens or just press enter if you just want it to run

See more details at https://richardtape.com/?p=123

Win!