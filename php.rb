dep "php5" do
  requires "php54.src"
end

dep "php54.src" do
   requires "envato:libxml.managed", "benhoskings:openssl.lib", "benhoskings:libssl headers.managed", "libcurl4-openssl-dev.managed", "libjpeg-dev.managed", "libpng12-dev.managed", "libmcrypt-dev.managed", "libpcre3-dev.managed", "readline-common.managed", "libreadline-dev.managed", "libfreetype6-dev.managed"

   def version; "5.4.16"; end;

   source "http://au1.php.net/get/php-#{version}.tar.gz/from/us1.php.net/mirror"
   provides "php = #{version}"
   configure_args L{
     [
      '--prefix=/usr/local',
      '--with-mysql',
      '--enable-fpm',
      '--with-readline',
      '--with-pdo_mysql',
      '--with-curl',
      '--enable-pcntl',
      '--enable-mbstring',
      '--enable-debug',
      '--with-zlib',
      '--with-pdo',
      '--with-apxs2',
      '--enable-so',
      '--with-mcrypt',
      '--with-gd',
      '--enable-gd-native-ttf',
      '--with-openssl',
      '--with-png-dir=/usr',
      '--with-jpeg-dir=/usr',
      '--with-freetype-dir=usr',
      '--with-ttf',
      '--with-exif',
      '--enable-bcmath'
     ].compact.join(" ")
   }

   met? { ("/etc/init.d" / "php-fpm").exists? }

   postinstall {
     sudo "cp -f sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm"
     sudo "chmod +x /etc/init.d/php-fpm"
     sudo "update-rc.d -f php-fpm defaults"
   }
end

dep "php-fpm", :domain, :port, :user, :group, :path do
  requires "php54.src"

  def group
    user
  end

  def php_fpm_conf_dir
    "/usr/local" / "etc"
  end

  def php_fpm_conf
    php_fpm_conf_dir / "php-fpm.conf"
  end


  def php_fpm_pool_conf
    php_fpm_conf_dir / "fpm/pool.d" / "#{domain}.conf"
  end

  def vhost_conf
    "/opt/nginx/conf/vhosts/#{domain}.common"
  end

  met? { 
    php_fpm_conf.exists? and php_fpm_pool_conf.exists?
  }

  meet {
    php_fpm_conf_dir.mkdir
    render_erb "php/php-fpm.conf.erb", :to => php_fpm_conf, :sudo => true
    php_fpm_pool_conf.dir.create
    render_erb "php/php-fpm-host.conf.erb", :to => php_fpm_pool_conf, :sudo => true
    sudo "mkdir -p #{path}"
    sudo "chown #{user}:#{group} #{path}"
  }
  after {
    sudo "service php-fpm restart"
  }
end

%w(libfreetype6-dev libcurl4-openssl-dev libjpeg-dev libpng12-dev libmcrypt-dev libpcre3-dev readline-common libreadline-dev).each do |lib|
  dep "#{lib}.managed" do
    provides []
  end
end

dep "php5.managed" do
  provides "php ~> 5.4.11"


  on :brew do
    def apache_conf
      "/usr/local/etc/apache2/httpd.conf".p
    end

    requires "brewtap".with("josegonzalez/php")
	  meet {
	    pkg_manager.install! packages, ["--with-mysql"]
	  }
    after {
      apache_conf.append "LoadModule php5_module    /usr/local/opt/php54/libexec/apache2/libphp5.so"
      apache_conf.append "AddType application/x-httpd-php .php"
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

meta "php" do
  def conf_path
    "/usr/local/etc/php/5.4/php.ini"
  end
end

dep "short tags.php" do
  met? { !shell("cat #{conf_path}").split("\n").grep("short_open_tag = On").empty?}
  meet { shell "sed -i '' -e 's/short_open_tag = Off/short_open_tag = On/' '#{conf_path}'" }
end

dep "php composer" do
  def path 
    "/usr/local/bin" / "composer"
  end
  met? { path.exists? }
  meet { 
    shell "curl -sS https://getcomposer.org/installer | php"
    shell "mv composer.phar #{path}"
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

meta "pear" do
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
    def php_conf
      "/usr/local/lib" / "php.ini"
    end
    
    requires "php5"
    before {
      shell 'pear config-set temp_dir ~/.tmp'
    }

    met? { 
      shell "pecl info #{basename}" and 
      !shell("php -i").split("\n").grep("yaml").empty?
    }
    meet {
      log_shell "Install pecl #{basename}", "pecl install -f #{basename}", :sudo => true, :input => "\n\r" 
      php_conf.append "extension=#{basename}.so"
    }
  }
end

dep "yaml.pecl" do
  requires "libyaml-dev.managed"
end

dep "libyaml-dev.managed" do
  provides []
  on :osx do
    after {
      shell "brew link libyaml"
    }
  end
end

dep "pear channel", :channel, :channel_name do
  met? { log_shell("pear channel-info #{channel_name}", "pear channel-info #{channel_name}") }
  meet { log_shell "Discovering channel #{channel}", "pear channel-discover #{channel}", :sudo => true }
end


dep "php composer" do
  met? { in_path? "composer.phar" }
  meet { 
    `curl -s https://getcomposer.org/installer | php` 
    shell 'mv composer.phar /usr/local/bin/'
  }
end
