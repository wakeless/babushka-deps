dep "workstation" do
  requires "benhoskings:Google Chrome.app"
  requires "benhoskings:Firefox.app"
  requires "benhoskings:Vim.app"
  requires "benhoskings:Alfred.app"
  requires "wget.managed"
  requires "ack.managed"
  requires "iTerm.app"

  requires "currinda dev"
end

dep "currinda dev" do
  requires "mysql.managed"
  requires "selenium"
  requires "php5.managed"
  requires "php composer"
  requires "short tags.php"
  requires "yaml.pecl"

  requires "2.0.0.rbenv"
  requires "bundler.gem"
end

dep "iTerm.app" do
  source "http://www.iterm2.com/downloads/beta/iTerm2-1_0_0_20130624.zip"
end


dep "ack.managed"
dep "wget.managed"
dep "bundler.gem" do
  provides "bundle"
end

dep "vim.managed"
