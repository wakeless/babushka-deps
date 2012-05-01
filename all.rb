dep "system" do
  requires "git.managed", "lamp", "firefox.managed", "phpunit-pear", "jenkins.managed"
end

dep "jenkins.managed" do
  provides "jenkins-cli"
end

dep "apache2.managed" do
  after { sudo "a2enmod rewrite"
    sudo "service apache2 restart"
  }
end

dep "lamp" do
  requires "mysql.managed", "php.managed", "apache2.managed"

  met? { which "mysql" and which "php" and which "apachectl" }
end

dep "pear.managed"
dep "firefox.managed"

dep "java.managed" do
  met? { which "java" }
  installs {
    via :apt, "default-jdk.managed"
  }
end

dep "selenium.service" do
  binary "selenium-server-headless"
  path "/usr/local/bin"
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
