dep "jenkins.managed" do
  provides "jenkins-cli"
end

dep "jenkins" do
  requires "jenkins.managed", "git.jenkins"
end

dep "jenkins git job", :name, :git_name, :git_url, :email_notification do
  met? { File.exists? "/var/lib/jenkins/jobs/#{name}/config.xml" }
  meet { 
    cd "/tmp" do
      render_erb "jenkins/job.xml.erb", :to => "config.xml"
      shell "jenkins-cli create-job #{name} < config.xml"
    end
  }
end

dep "git.jenkins" do
  requires "ssh keys".with("jenkins", "/var/lib/jenkins")
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
    met? { "#{home}/plugins/#{basename}/" }
    meet { 
      log_shell "Installing jenkins plugin #{provides.join(" ")}", "jenkins-cli -s http://#{host} install-plugin #{basename} -restart"
    }
  }

end
