dep "mount-ebs.upstart", :device, :volume, :mount_path do
  device.ask("Which device would you like it mounted to?")
  volume.ask("What is the volume_id of the ebs volume?")
  mount_path.ask("Which path would you like it mounted to?")

  def executable
    "ec2-attach-volume `curl http://169.254.169.254/latest/meta-data/instance-id 2> /dev/null` -i #{volume} #{device}
  mount #{mount_path} #{device}"

  end

end
