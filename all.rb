dep "system" do
  requires "git.managed", "lamp.managed", "firefox.managed", "phpunit-pear"
end

dep "ci-system.managed" do
  on :apt do
    requires "tissak:jenkins.managed"
  end
  on :brew do
    installs { 
      via :brew, "jenkins"
    }
  end
end

dep "apache2.managed"

dep "lamp" do
  requires "mysql.managed", "php.managed", "apache2.managed"

  met? { which "mysql" and which "php" and which "apachectl" }
end

dep "pear.managed"
dep "firefox.managed"

dep "java.managed" do
  met? { which "java" }
  installs {
    via :apt, "default-jdk.managed"
  }
end

