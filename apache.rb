dep "apache vhost", :host, :public_path do
  def apache_root
    "/etc/apache2/"
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

  on :linux do
    def vhost_path
      apache_root / "sites-available"
    end

    met? { 
      File.exists? apache_root / "sites-enabled" / vhost_conf
    }

    meet {
      cd conf_path, :create => true, :sudo => true do
        render_erb "apache/virtual-host.erb", :to => vhost_path / vhost_conf, :sudo => true
      end
      sudo "a2ensite #{vhost_conf}"
      sudo "apachectl -k restart"
    }
  end

  on :osx do
    def vhost_path
      apache_root / "extra/vhosts"
    end

    met? { 
      File.exists?(vhost_path / vhost_conf) and !sudo("cat #{vhost_file}").split("\n").grep(include).empty?
    }

    meet {
      cd vhost_path, :create => true, :sudo => true do
        render_erb "apache/virtual-host.erb", :to => vhost_conf, :sudo => true
      end
      append_to_file include, vhost_file, :sudo => true
      sudo "apachectl -k restart"

    }
  end

end
