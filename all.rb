dep "system" do
  requires "git.managed", "lamp", "firefox.managed", "jenkins", "xvfb.upstart", "selenium.upstart", "phpunit"
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

  met? { File.exists? path / ".ssh"}
  meet { 
     cd path / ".ssh", :sudo => true, :create => "700" do
      sudo "ssh-keygen -f id_rsa"
      sudo "chown -R #{user}:#{user} ."
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

dep "tmp tmpfs" do
  def fstab
    "tmpfs /tmp tmpfs rw,nosuid,mode=0777 0 0"
  end
  met? { '/etc/fstab'.p.grep(fstab) }
  meet { append_to_file "tmpfs /tmp tmpfs rw,nosuid,mode=0777 0 0", "/etc/fstab", :sudo => true }
end


dep "shutdown_on_startup.upstart", :minutes do
  minutes.default("50").ask("In how many minutes do you want to shutdown?")

  def executable
    "shutdown -h +#{minutes}"
  end

end

dep "logrotate_on_boot.upstart" do
  def executable
    "logrotate -f /etc/logrotate.conf"
  end
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
