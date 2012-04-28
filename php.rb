dep "php5.managed" do
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

