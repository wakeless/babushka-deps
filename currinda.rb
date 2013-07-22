dep "currinda web" do
  requires "php54.src", "php composer"
  requires "php-fpm".with(:domain => "*.localhost", :user => "currinda")
end
