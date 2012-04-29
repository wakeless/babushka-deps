dep "system" do
  requires "git.managed", "lamp", "firefox.managed", "phpunit-pear", "jenkins.managed"
end

dep "jenkins.managed"

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

