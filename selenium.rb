
dep "selenium", :version, :path do
  version.default!("2.21.0")
  path.default!("/usr/local")

  def selenium_src
    "http://selenium.googlecode.com/files/selenium-server-standalone-#{version}.jar"
  end

  def selenium_bin
    path / "bin/selenium-server"
  end

  met? { which "selenium-server" }
  meet {
    cd path / "lib" do
      Babushka::Resource.download selenium_src
    end
    render_erb "selenium/selenium-server.erb", :to => selenium_bin
    shell "chmod +x #{selenium_bin}"
  }
end

dep "xvfb.managed" do
  installs {
    via :apt, "xvfb"
  }

  met? { which "xvfb" and File.exists? "/etc/init.d/xvfb" }
  meet { 
    render_erb "selenium/xvfb.erb", :to => "/etc/init.d", :sudo => true 
    sudo "chmod 755 /etc/init.d/xvfb"
  }
end

dep "selenium-headless", :version, :path do
  requires "xvfb.managed", "selenium".with(version, path)

  met? { which "selenium-server-headless" }
  meet {
    render_erb "selenium/selenium-server-headless.erb", :to => selenium_bin
    shell "chmod +x #{selenium_bin}"
  }
end
