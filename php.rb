dep "php5.managed" do
  on :brew do
    requires "php.recipe"
  end
  met? { which "php" and which "pear" }
  installs {
    via :brew, "php"
    via :apt, "php5", "php5-mysql", "php-pear", "php5-curl"
  }
end

dep "php.recipe" do
  source "https://raw.github.com/ampt/homebrew/php/Library/Formula/php.rb"
end



dep "phpunit.pear" do
  channel "pear.phpunit.de"
  channel_name "phpunit"
  name "PHPUnit"

  met? { which "phpunit" }
end

dep "phpunitselenium.pear" do
  requires "pear channel".with("pear.phpunit.de", "phpunit"), "pear channel".with("pear.symfony-project.com", "symfony")
  channel "phpunit"
  name "PHPUnit_Selenium"
end

dep "git.jenkins"

meta "jenkins" do
  template {
    met? {}
    meet { 
      log_shell "Installing jenkins plugin #{basename}", "jenkins-cli -s http://localhost:8080 install-plugin #{basename} -restart"
    }
  }

end

dep "php jenkins" do
  met? {}
  meet {
    cd "/var/lib/jenkins/jobs", :create => true, :sudo => true do
      log_shell "Downloading sebastian bermann's jenkins templates", "git clone git://github.com/sebastianbergmann/php-jenkins-template.git php-template", :sudo => true
    end
    shell "invoke-rc.d jenkins stop", :sudo => true
    shell "invoke-rc.d jenkins start", :sudo => true
  }
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


