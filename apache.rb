dep "apache vhost", :host, :public_path do
  def apache_root
    "/etc/apache2/"
  end

  def vhost_path
    if new_config?
      apache_root / "sites-available"
    else
      apache_root / "extra/vhosts/"
    end
  end

  def vhost_conf
    "#{host}.conf"
  end

  def include
    "Include #{vhost_path / vhost_conf}"
  end

  def vhost_file
    apache_root / "extra/httpd-vhosts.conf"
  end

  def new_config?
    File.exists?(apache_root / "sites-available")
  end

  met? { 
    if new_config?
      File.exists? apache_root / "sites-enabled" / vhost_conf
    else
      File.exists?(vhost_path / vhost_conf) and !sudo("cat #{vhost_file}").split("\n").grep(include).empty?}
    end
  meet {
    cd vhost_path, :create => true, :sudo => true do
      render_erb "apache/virtual-host.erb", :to => vhost_conf, :sudo => true
    end

    if new_config?
      sudo "a2ensite #{vhost_conf}"
    else
      append_to_file include, vhost_file, :sudo => true
    end
  }

end
