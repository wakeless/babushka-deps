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
      render_erb "apache/virtual-host.erb", :to => vhost_path / vhost_conf, :sudo => true
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

meta "apache" do
    def apache_root
      "/usr/local/etc/apache2/httpd.conf".p
    end
end

dep 'self signed cert.apache', :domain, :nginx_prefix, :country, :state, :city, :organisation, :organisational_unit, :email do
  requires "apache.managed"

  def cert_path
    apache_root / "ssl"
  end

  met? { %w[key crt].all? {|ext| (cert_path / "#{domain}.#{ext}").exists? } }
  meet {
    cd cert_path, :create => "700" do
      log_shell("generating private key", "openssl genrsa -out #{domain}.key 2048", :sudo => true) and
      log_shell("generating certificate", "openssl req -new -key #{domain}.key -out #{domain}.csr",
        :input => [
          country.default('AU'),
          state,
          city.default(''),
          organisation,
          organisational_unit.default(''),
          domain,
          email,
          '', # password
          '', # optional company name
          '' # done
        ].join("\n")
      ) and
      log_shell("signing certificate with key", "openssl x509 -req -days 365 -in #{domain}.csr -signkey #{domain}.key -out #{domain}.crt", :sudo => true)
    end
  }
end
