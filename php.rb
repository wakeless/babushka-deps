dep "php54.src" do
   requires "envato:libxml.managed", "benhoskings:openssl.lib", "benhoskings:libssl headers.managed", "libcurl4-openssl-dev.managed", "libjpeg-dev.managed", "libpng12-dev.managed", "libmcrypt-dev.managed", "libpcre3-dev.managed", "readline-common.managed", "libreadline-dev.managed"

   source 'http://au1.php.net/get/php-5.4.16.tar.gz/from/us1.php.net/mirror'
   provides 'php'
   configure_args L{
     [
        '--enable-fpm',
        '--with-mysql',
        '--with-readline',
'--with-libdir=/lib/x86_64-linux-gnu',
        '--with-pdo_mysql',
        '--with-curl',
        '--enable-pcntl',
        '--enable-mbstring',
        '--enable-debug',
        '--with-zlib',
        '--with-pdo',
        '--enable-so',
        '--with-mcrypt',
        '--with-gd',
        '--with-openssl',
        '--with-jpeg-dir',
        '--with-png-dir',
        '--with-jpeg-dir=/usr'
     ].compact.join(" ")
   }

   met? { ("/etc/init.d" / "php-fpm").exists? }

   after {
     sudo "cp -f sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm"
     sudo "chmod +x /etc/init.d/php-fpm"
     sudo "update-rc.d -f php-fpm defaults"
   }
end

dep "php-fpm", :domain, :port, :user, :group do
#  requires "php54.src"
  requires "benhoskings:user setup for provisioning".with(:username => user), "benhoskings:vhost enabled.nginx".with(:vhost_type => "proxy", :domain => domain, :proxy_host => "127.0.0.1", :proxy_port => port

  def group
    user
  end

  def php_fpm_conf
    "/etc/php5/fpm/pool.d" / "#{domain}.conf"
  end

  met? { php_fpm_conf.exists? }

  meet {
    render_erb "php/php-fpm.conf.erb", :to => php_fpm_conf, :sudo => true
  }
end

%w(libcurl4-openssl-dev libjpeg-dev libpng12-dev libmcrypt-dev libpcre3-dev readline-common libreadline-dev).each do |lib|
puts "#{lib}.managed"
  dep "#{lib}.managed" do
    provides []
  end
end

dep "php5.managed" do
  provides "php ~> 5.4.11"

  on :brew do
    requires "brewtap".with("josegonzalez/php")
	  meet {
	    pkg_manager.install! packages, ["--with-mysql"]
	  }
  end

  on :apt do
    requires "ppa".with("ppa:ondrej/php5")
  end


  installs {
    via :brew, "php54"
    via :apt, "php5", "php5-mysql", "php-pear", "php5-curl", "php5-fpm"
  }
end

dep "brewtap", :tap_repo do
  met? {
    !shell("brew tap").split("\n").grep(tap_repo).empty?
  }
  meet {
        shell "brew tap #{tap_repo}"
  }
end

dep "phpunit" do
  requires "phpunit.pear", "dbunit.pear", "phpunitselenium.pear"
end


dep "dbunit.pear" do
  requires "phpunit.pear"
  channel "phpunit"
  name "DBUnit"
end

dep "phpunit.pear" do
  requires "pear channel".with("pear.phpunit.de", "phpunit"), "pear channel".with("pear.symfony.com", "symfony2")
  channel "phpunit"
  name "PHPUnit"

end

dep "phpunitselenium.pear" do
  requires "phpunit.pear"
  channel "phpunit"
  name "PHPUnit_Selenium"
end

dep "php jenkins" do
  def jenkins_jobs
    "/var/lib/jenkins/jobs"
  end

  met? { File.exists? jenkins_jobs / "php-template/config.xml" }
  meet {
    cd jenkins_jobs, :create => true, :sudo => true do
      log_shell "Downloading sebastian bermann's jenkins templates", "git clone git://github.com/sebastianbergmann/php-jenkins-template.git php-template", :sudo => true
    end
    shell "invoke-rc.d jenkins stop", :sudo => true
    shell "invoke-rc.d jenkins start", :sudo => true
  }
end

dep "phpunit.jenkins" do
  provides "checkstyle", "cloverphp", "dry", "htmlpublisher", "jdepend", "plot", "pmd", "violations", "xunit"
end

meta "pear", :version do
  accepts_value_for :channel
  accepts_value_for :name

  template {
    #requires "php5.managed"
    #before { shell "pear channel-update #{channel}" }
    met? { log_shell "Checking for pear #{channel}/#{name}", "pear info #{channel}/#{name}" }
    meet { log_shell "Installing #{name}", "pear install --alldeps #{channel}/#{name}", :sudo => true }
  }
end

meta "pecl" do
  template {
    requires "php5.managed"
    met? { log_shell "Checking for PECL #{basename}", "pecl info #{basename}" }
    meet { log_shell "Install pecl #{basename}", "pecl install -f #{basename}", :sudo => true, :input => "\n\r" }
    after { sudo "apachectl -k restart" }
  }
end

dep "yaml.pecl" do
  requires "libyaml.managed"
end

dep "libyaml.managed" do
  provides []
end

dep "pear channel", :channel, :channel_name do
  met? { log_shell("pear channel-info #{channel_name}", "pear channel-info #{channel_name}") }
  meet { log_shell "Discovering channel #{channel}", "pear channel-discover #{channel}", :sudo => true }
end


dep "php composer" do
  provides "composer.phar"
  meet { `curl -s https://getcomposer.org/installer | php` }
end
