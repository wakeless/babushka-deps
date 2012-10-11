
dep "selenium", :version, :path do
  version.default!("2.25.0")
  path.default!("/usr/local")

  def selenium_src
    "http://selenium.googlecode.com/files/#{selenium_file}"
  end

  def selenium_file
    "selenium-server-standalone-#{version}.jar"
  end

  def selenium_bin
    path / "bin/selenium-server"
  end

  met? { which "selenium-server" and File.exists? path / "lib" / selenium_file }
  meet {
    cd "/tmp" do
        Babushka::Resource.download selenium_src
    end
    cd path / "lib", :sudo => true do
      sudo "cp /tmp/selenium-server-standalone-#{version}.jar ."
    end
    render_erb "selenium/selenium-server.erb", :to => selenium_bin, :sudo => true
    sudo "chmod +x #{selenium_bin}"
  }
end

dep "selenium.upstart" do
  requires "selenium-headless", "xvfb.upstart"
  binary "selenium-server-headless"
end

dep "xvfb.managed" do
  provides "xvfb-run"
end

dep "xvfb.upstart" do
  requires "xvfb.managed"
  def executable
    "/usr/bin/Xvfb :99 -ac -screen 0 1024x768x8"
  end
end

dep "selenium-headless", :version, :path do
  path.default!("/usr/local")
  requires "xvfb.managed", "selenium".with(version, path)
  def selenium_bin
    path / "bin" / "selenium-server-headless"
  end

  met? { which "selenium-server-headless" }
  meet {
    render_erb "selenium/selenium-server-headless.erb", :to => selenium_bin, :sudo => true
    sudo "chmod +x #{selenium_bin}"
  }
end
