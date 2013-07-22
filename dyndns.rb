dep "ddclient.managed"

dep "dnsdynamic", :username, :password, :domain do
  requires "ddclient.managed"

  def config
    "/etc/default" / "ddclient.conf"
  end

  met? { config.exists? }
  meet { render_erb "dyndns/ddclient.erb", :to => config, :sudo => true, :chmod => 600 }
end
