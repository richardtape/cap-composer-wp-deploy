## Deployment mechanism for WordPress using Capistrano and Composer

+ Clone repo to your local machine
+ Change the config/deploy/production.rb and config/deploy/staging.rb files to match your server credentials (IP Address, user, roles, paths)
+ Adjust the composer.json file to match what you want to install
+ Possibly adjust the createsymlinks() function in deploy.rb depending on what you run on composer install
+ "cap staging deploy" or "cap production deploy" then...
+ type 'debug' (no quotes) if you want to see everything that happens or just press enter if you just want it to run with pretty messages
+ cap staging deploy:rollback or cap production deploy:rollback if you want to rollback to the previous finished deploy

See more details at https://richardtape.com/?p=123

Win!