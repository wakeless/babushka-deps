dep "system" do
  requires "git.managed", "lamp", "firefox.managed", "phpunit.pear", "dbunit.pear", "jenkins", "xvfb.upstart", "selenium.upstart"
  requires "xvfb.managed"
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

dep "ssh keys", :user, :path do
  path.default!("~#{user}")

  met? { File.exists? path / ".ssh" and File.exists? path / ".ssh/id_rsa" and File.exists? path / ".ssh/id_rsa.pub" }
  meet { 
     cd path / ".ssh", :sudo => true, :create => true do
      sudo "ssh-keygen -f id_rsa"
      sudo "chown -R #{user}:#{user} .ssh"
      sudo "chmod -R 600 ."
      log "Here's the public key..."
      log sudo("cat id_rsa.pub") 
    end
  }

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

dep "hostfile line", :host, :address do
  def host_line
    "#{address} #{host}"
  end

  def host_file
    "/etc/hosts"
  end

  met? { !shell("cat #{host_file}").split("\n").grep(host_line).empty? }
  meet { append_to_file host_line, "/etc/hosts", :sudo => true }
end
