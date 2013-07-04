dep "workstation" do
  requires "benhoskings:Google Chrome.app"
  requires "benhoskings:Firefox.app"
  requires "benhoskings:Vim.app"
  requires "benhoskings:Alfred.app"
  requires "benhoskings:Skype.app"
  requires "benhoskings:Twitter.app"
  requires "wget.managed"
  requires "iterm2.app"

  requires "currinda dev"
end

dep "currinda dev" do
  requires "selenium"
  requires "php5.managed"
  requires "php composer"
end

dep "iterm2.app" do
  source "http://www.iterm2.com/downloads/beta/iTerm2-1_0_0_20130624.zip"
end

dep "wget.managed"
