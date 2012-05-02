dep "jenkins.managed" do
  provides "jenkins-cli"
end

dep "jenkins" do
  requires "jenkins.managed", "git.jenkins"
end

dep "git.jenkins" do
  after {
    cd home / ".ssh", :sudo => true, :create => true do
      sudo "ssh-keygen -f id_rsa"
      sudo "chown -R jenkins:jenkins .ssh"
      sudo "chmod -R 600 .ssh"
    end
  }
end

meta "jenkins" do
  accepts_list_for :provides, :basename
  def host
    "localhost:8080"
  end

  def home
    "/var/lib/jenkins"
  end

  template {
    before { 
      log_shell "Updating plugins", "curl  -L http://updates.jenkins-ci.org/update-center.json | sed '1d;$d' | curl -X POST -H 'Accept: application/json' -d @- http://#{host}/updateCenter/byId/default/postBack" 
    }
    met? {}
    meet { 
      log_shell "Installing jenkins plugin #{provides.join(" ")}", "jenkins-cli -s http://#{host} install-plugin #{basename} -restart"
    }
  }

end
