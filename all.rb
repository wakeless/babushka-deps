dep "system" do
  requires "git.managed", "lamp", "firefox.managed", "phpunit.pear", "dbunit.pear", "jenkins.managed", "xvfb.upstart", "selenium.upstart"
  requires "xvfb.managed"
end

dep "jenkins.managed" do
  provides "jenkins-cli"
end

dep "apache2.managed" do
  after { 
    sudo "a2enmod rewrite"
    sudo "service apache2 restart"
  }
end

dep "lamp" do
  requires "mysql.managed", "php5.managed", "apache2.managed"

  #met? { which "mysql" and which "php" and which "apachectl" }
end

dep "pear.managed"
dep "firefox.managed"

dep "java.managed" do
  met? { which "java" }
  installs {
    via :apt, "default-jdk.managed"
  }
end


meta "upstart" do
  accepts_value_for :binary, :basename
  accepts_value_for :path, "/usr/local/bin"
  accepts_value_for :start_on, "runlevel [2345]"
  accepts_value_for :stop_on, "runlevel [!2345]"

  def executable
    "#{path / binary}"
  end

  def upstart_path
    "/etc/init"
  end

  def service
    upstart_path / "#{basename}.conf"
  end

  template {
    met? { File.exists? service }
    meet {
      render_erb "system/upstart.erb", :to => service, :sudo => true
    }
  }
end

meta "service" do
  accepts_value_for :binary, :basename
  accepts_value_for :path, "/usr/local/bin"

  def executable
    path / binary
  end

  def service_path
    "/etc/init.d"
  end

  def service
    service_path / basename
  end

  template {
    met? { File.exists? service and service.executable? }
    meet { 
      cd service_path, :create => true, :sudo => true do
        render_erb "system/service.erb", :to => service, :sudo => true 
        sudo "chmod 755 #{service}" 
      end
    }
  }
end
