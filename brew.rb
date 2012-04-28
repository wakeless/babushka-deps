meta :recipe do
  accepts_value_for :source
  template {
    def name
      source.to_s.p.basename 
    end

    def prefix
      `brew --prefix`.chomp + "/Library/Formula"
    end

    before { puts name }

    met? { File.exists? "#{prefix}/#{name}" }
    meet { 
      cd prefix do
        Babushka::Resource.download source
      end
    }
  }
end
