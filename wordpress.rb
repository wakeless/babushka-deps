dep "upgraded wordpress" do
  latest = "3.4"

  def version
    vers = 'include "wp-includes/version.php"; echo $wp_version;'
    `php -r '#{vers}'`
  end
  met? { latest == version }
  meet {
    wordpress = Dir.pwd
    puts wordpress
    Babushka::Resource.extract "http://wordpress.org/latest.tar.gz" do |hrm|
      shell "cp -r * #{wordpress}"
    end
  }
end
