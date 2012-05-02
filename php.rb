dep "php5.managed" do
  on :brew do
    requires "php.recipe"
  end
  installs {
    via :brew, "php"
    via :apt, "php5", "php5-mysql", "php-pear", "php5-curl"
  }
end

dep "php.recipe" do
  source "https://raw.github.com/ampt/homebrew/php/Library/Formula/php.rb"
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

  met? { which "phpunit" }
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

dep "pear channel", :channel, :channel_name do
  met? { log_shell("pear channel-info #{channel_name}", "pear channel-info #{channel_name}") }
  meet { log_shell "Discovering channel #{channel}", "pear channel-discover #{channel}", :sudo => true }
end


