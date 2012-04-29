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

dep "selenium" do
  requires "firefox.managed", "java"
end

dep "apache2.managed"

dep "lamp" do
  requires "mysql.managed", "php.managed", "apache2.managed"

  met? { which "mysql" and which "php" and which "apachectl" }
end

dep "pear.managed"
dep "firefox.managed", "default-jdk.managed"
dep "java" do
  requires "default-jdk.managed"
end
