dep "currinda web" do
  requires "vim.managed"
  requires "php54.src", "php composer"
  requires "yaml.pecl"

  user = "currinda"
  domain = "*.currinda.com"
  port = "9001"

  requires "php-fpm".with(:domain => domain, :user => user, :port => 9001)

  requires "benhoskings:user setup for provisioning".with(:username => user, :key => "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAwX61j6ySz/efyE1Zjgowkk25JOn4Fpc//tp1Wwa3ldUhJZO4oTZLzEzhAVcMLNTGzt2AMd3Fgv0A3ayfCVUvBxzSMHC9yJUQbRljBBjvMgH7uFFiLkAarOB9sdNBuct+Q4t/N1EkLGWJc+RU/9vj8ZJffsssndbC9hOTmgezzVpDnKZNnN4JRBakHZHcVWvNTixoKYA5ploZ8MD/DsQJLphYZx8r43ej35vyRArOIqvhJOSYX0/06voAVRnoWiNw65xHbdIcHJks9gFKVee3vLRtgbQw9Z8Lc3QlCDrBgIOPwTxoMqeh+x8dNSlKcG19NyBuzC0iXSVBAKLFDvpEQQ=="),
    "vhost enabled.nginx".with(
      :vhost_type => "php",
      :domain => domain,
      :proxy_host => "127.0.0.1",
      :proxy_port => port,
      :path => "/home/#{user}/site"
    ),
    "benhoskings:self signed cert.nginx".with(:domain => domain, :nginx_prefix => "/opt/nginx", :state => "VIC", :country => "AU", :organisation => "Currinda", :email => "noone@example.com"),
    "running.nginx".with(:nginx_prefix => "/opt/nginx")
end

dep "currinda tunnel" do
  requires "ssh_tunnel.upstart".with(:user => "tunnel-user", :host => "currinda.com", :port => 4040)
  requires "ssh_tunnel.upstart".with(:user => "tunnel-user", :host => "currinda.com", :port => 3306)
end
