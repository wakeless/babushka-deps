dep "php5.managed" do
  provides "php ~> 5.4.3"

  on :brew do
#    configure_args '--with-mysql'
    requires "brewtap".with("josegonzalez/php")
  end

  on :apt do
    requires "ppa".with("ondrej/php5")
  end


  installs {
    via :brew, "php54"
    via :apt, "php5", "php5-mysql", "php-pear", "php5-curl", "php5-fpm"
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
  requires "pear channel".with("pear.phpunit.de", "phpunit"), "pear channel".with("pear.symfony-project.com", "symfony")
  channel "phpunit"
  name "DBUnit"
end

dep "phpunit.pear" do
  requires "pear channel".with("pear.phpunit.de", "phpunit"), "pear channel".with("pear.symfony-project.com", "symfony")
  channel "phpunit"
  name "PHPUnit"

end

dep "phpunitselenium.pear" do
  requires "pear channel".with("pear.phpunit.de", "phpunit"), "pear channel".with("pear.symfony-project.com", "symfony")
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

meta "pear", :version do
  accepts_value_for :channel
  accepts_value_for :name

  template {
    requires "php5.managed"
    before { shell "pear channel-update #{channel}" }
    met? { log_shell "Checking for pear #{channel}/#{name}", "pear info #{channel}/#{name}" }
    meet { log_shell "Installing #{name}", "pear install --alldeps #{channel}/#{name} ", :sudo => true }
  }
end

meta "pecl" do
  template {
    requires "php5.managed"
    met? { log_shell "Checking for PECL #{basename}", "pecl info #{basename}" }
    meet { log_shell "Install pecl #{basename}", "pecl install -f #{basename}", :sudo => true, :input => "\n\r" }
    after { sudo "apachectl -k restart" }
  }
end

dep "yaml.pecl" do
  requires "libyaml.managed"
end

dep "libyaml.managed" do
  provides []
end

dep "pear channel", :channel, :channel_name do
  met? { log_shell("pear channel-info #{channel_name}", "pear channel-info #{channel_name}") }
  meet { log_shell "Discovering channel #{channel}", "pear channel-discover #{channel}", :sudo => true }
end


