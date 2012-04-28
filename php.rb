dep "phpunit" do
  requires "php"
end

dep "php.managed", :version do
  installs {
    via :apt, "php5"
  }
end

dep "phpunit.pear" do
  channel "pear.phpunit.de"
  channel_name "phpunit"
  name "PHPUnit"

  met? { which "phpunit" }
end

meta "pear", :version do
  accepts_value_for :channel
  accepts_value_for :channel_name
  accepts_value_for :name

  template {
    prepare { sudo "pear channel-discover #{channel}" }
    met? {}
    meet { sudo "pear install --alldeps #{channel_name}/#{name} " }
  }
end

