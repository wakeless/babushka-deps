dep "mount-ebs.upstart", :device, :volume, :mount_path do
  device.ask("Which device would you like it mounted to?")
  volume.ask("What is the volume_id of the ebs volume?")
  mount_path.ask("Which path would you like it mounted to?")

  def executable
    "ec2-attach-volume --private-key /root/.ec2/pk.pem -C /root/.ec2/cert.pem #{volume} -i `curl http://169.254.169.254/latest/meta-data/instance-id 2> /dev/null` -d #{device}"
    "ec2-attach-volume `curl http://169.254.169.254/latest/meta-data/instance-id 2> /dev/null` -i #{volume} #{device}"
  mount #{mount_path} #{device}"

  end

end


dep "aws-sdk.gem" do
  provides ""
end

dep "start.ec2", :id, :region do
  
  def instance
    ec2.instances[id]
  end

  met? { instance.exists? and [:running, :pending].include? instance.status }
  meet { ec2.instances[id].start }
  
end

meta "ec2" do
  template {
    def ec2
      unless @ec2
        configure
        @ec2 = AWS::EC2.new
        @ec2 = @ec2.regions["us-west-1"]
      end
      @ec2
    end

    requires "aws-sdk.gem", "ec2 credentials"

    require "aws-sdk"
    @config = "~" / ".ec2/config.yml"

    def configure
      AWS.config(YAML.load(File.read(@config)))
    end
    
  }

end

dep "ec2 credentials", :access_key_id, :secret_access_key do
  @config = "~" / ".ec2/config.yml"
  met? {
    @config.exists?
  }
  meet {
    @config.write "
access_key_id: #{access_key_id}
secret_access_key: #{secret_access_key}"
  }
end
