desc("Run SinatraProfileManager on port 4567 in TEST environment")
task(:run_testing) do
  system("APP_ENV=test bundle exec rackup -p 4567 config.ru")
end

desc("Run SinatraProfileManager on port 4567 in DEVELOPMENT environment")
task(:run_development) do
  system("APP_ENV=development bundle exec rackup -p 4567 config.ru")
end

desc("Run SinatraProfileManager on port 4567 in PRODUCTION environment")
task(:run_production) do
  system("APP_ENV=production bundle exec rackup -p 4567 config.ru")
end