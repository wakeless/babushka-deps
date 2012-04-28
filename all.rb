dep "system" do
  requires "git.managed", "lamp.managed", "firefox.managed"
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

dep "selenium.managed" do
  installs {
    via :apt, "firefox", "java"
  }
end

dep "lamp.managed" do
  requires "benhoskings:mysql.managed", "php.managed"
  installs {
    via :apt, "apache2"
  }
end

dep "pear.managed" do

end

dep "php.managed" do
  on :brew do
    requires "php.recipe"
  end
  met? { which "php" and which "pear" }
  installs {
    via :brew, "php"
    via :apt, "php5", "php5-mysql", "php-pear"
  }
end



dep "php.recipe" do
  source "https://raw.github.com/ampt/homebrew/php/Library/Formula/php.rb"
end


meta :recipe do
  accepts_value_for :source
  template {
    def name
      source.to_s.p.basename 
    end

    def prefix
      `brew --prefix`.chomp + "/Library/Formula"
    end

    before { puts name }

    met? { File.exists? "#{prefix}/#{name}" }
    meet { 
      cd prefix do
        Babushka::Resource.download source
      end
    }
  }
end
