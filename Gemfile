source 'https://rubygems.org'

gem 'berkshelf'
gem 'chef-rewind'
group :test do
  gem 'rake'
end

group :integration do
  gem 'test-kitchen', '~> 1.0'
  gem 'kitchen-vagrant', '~> 0.11'
  gem 'kitchen-digitalocean'
  gem 'kitchen-ec2'
  gem 'kitchen-openstack', '= 1.6.0'
  gem 'rvm'
  gem 'vagrant-wrapper'
end
