public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAuWgOP81QsBrb/l4f/Xi/6eNo8u+DIPV39GRKYAtUWB+Mm+O95AFsnzY0c0l5YI1smtSk/UwcthN/gWPx6eHH/bvBqTIYDSN8BbkWqiyX/P8LDPrzlEp5goGMITi71XYbdLUsW0QV66VZuTbmpZR0YMPiKVk4DE1E13JYNBv+wP8q97nEeL51938eAZiaNtQpuxrTVh7vxiuhNJSwXoIpX8dt9jHrjQ8H2dLF7fJZDEgRMzkJiQhxbHuC5kcpcdEFxinKkcBkQ69RmP5AuvVwkpf9f7Bts8OCxZnrh0ZOMflwYBukDriExg5We/9FsvBpKj5UjEXGhyQd4y0U+Z4faw== michaelgall@Michael-Galls-MacBook-Pro.local"

dep "currinda web" do
  requires "mysql-client.managed"
  requires "vim.managed"
  requires "php54.src", "php composer"
  requires "yaml.pecl"

  user = "live"
  domain = "*.currinda.com"
  port = "9001"
  path = "/home/#{user}/web/current"

  requires "benhoskings:user setup for provisioning".with(:username => "staging", :key => public_key),
    "vhost enabled.nginx".with(
      :vhost_type => "php",
      :domain => "members.asnevents.com.au",
      :proxy_host => "127.0.0.1",
      :proxy_port => 9002,
      :path => "/home/staging/web/current",
      :enable_https => "y"
    ),
    "php-fpm".with(:domain => "members.asnevents.com.au", :user => "staging", :port => 9002, :path => "/home/staging/web/current"),
    "benhoskings:self signed cert.nginx".with(:domain => "members.asnevents.com.au", :nginx_prefix => "/opt/nginx", :state => "VIC", :country => "AU", :organisation => "Currinda", :email => "noone@example.com")

  requires "benhoskings:user setup for provisioning".with(:username => user, :key => public_key),
    "vhost enabled.nginx".with(
      :vhost_type => "php",
      :domain => domain,
      :proxy_host => "127.0.0.1",
      :proxy_port => port,
      :path => path,
      :enable_https => "y"
    ),
    "php-fpm".with(:domain => domain, :user => user, :port => 9001, :path => path),
    "benhoskings:self signed cert.nginx".with(:domain => domain, :nginx_prefix => "/opt/nginx", :state => "VIC", :country => "AU", :organisation => "Currinda", :email => "noone@example.com"),
    "running.nginx".with(:nginx_prefix => "/opt/nginx"),
    "running.postfix"
    requires "benhoskings:ruby.src",
      "god.gem"
end

dep "currinda tunnel" do
  requires "ssh_tunnel.upstart".with(:user => "tunnel-user", :host => "currinda.com", :port => 4040)
  requires "ssh_tunnel.upstart".with(:user => "tunnel-user", :host => "currinda.com", :port => 3306)
end

dep "currinda api", :username, :path, :port, :domain do
  username.default("api")
  port.default("4040")
  path.default("/home/#{username}/current")
  domain.default("api.currinda.com")

  requires [
    "benhoskings:ruby.src",
    "bundler.gem",
    "mysql-client.managed",
    "libmysqlclient-dev.lib",
    'conversation:libxml.lib', # for nokogiri
    'conversation:libxslt.lib', # for nokogiri

    'benhoskings:user exists'.with(:username => username),
    'benhoskings:passwordless ssh logins'.with(username, public_key),
    "vhost enabled.nginx".with(
      :vhost_type => "unicorn",
      :domain => domain,
      :proxy_host => "127.0.0.1",
      :path => path
    ),
    "unicorn.upstart".with(
      :app_path => path
    ),
    "benhoskings:self signed cert.nginx".with(
      :domain => domain,
      :nginx_prefix => "/opt/nginx",
      :state => "VIC",
      :country => "AU",
      :organisation => "Currinda",
      :email => "noone@example.com"
    ),
    "running.nginx".with(:nginx_prefix => "/opt/nginx"),
    "vhost enabled.nginx".with(
      :vhost_type => "unicorn",
      :domain => domain,
      :proxy_host => "127.0.0.1",
      :proxy_port => port,
      :path => path,
      :enable_https => "y"
    ),
  ]
end

dep "bundler.gem" do
  provides "bundle"
end
dep "god.gem"
