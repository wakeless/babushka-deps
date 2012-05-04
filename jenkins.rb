dep "jenkins.managed", :url do
  url.default!("localhost:8080")

  provides "jenkins-cli"
  after {
    append_to_file "JENKINS_URL=#{url}", "/etc/jenkins/cli.conf", :sudo => true
  }
end

dep "jenkins" do
  requires "jenkins.managed", "git.jenkins"
end

dep "jenkins git job", :job_name, :git_url, :email_notification do
  git_url.default("").ask("What's the url of the git repo?")
  
  def git_name
    git_url.to_s.split("/")[-1].split(".").first
  end

  met? { 
  url = git_url
  File.exists? "/var/lib/jenkins/jobs/#{job_name}/config.xml" }
  meet { 
    cd "/tmp" do
      render_erb "jenkins/job.xml.erb", :to => "/tmp/config.xml", :comment => "<!-- ", :comment_suffix => " -->" 
      shell "tail -n +2 config.xml > config_fix.xml"
      shell "jenkins-cli create-job '#{job_name}' < config_fix.xml"
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
    met? { File.exists? "#{home}/plugins/#{basename}/" }
    meet { 
      log_shell "Installing jenkins plugin #{provides.join(" ")}", "jenkins-cli -s http://#{host} install-plugin #{basename} -restart"
    }
  }

end
