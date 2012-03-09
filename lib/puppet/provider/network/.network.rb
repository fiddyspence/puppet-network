Puppet::Type.type(:network).provide(:default) do

  desc "Basic /etc/networks support"

  NETWORKSFILE="/etc/networks"

  def exists?
    lines.find do |line|
      line.chomp =~ /#{resource[:network]}/
    end
  end


  def create
    File.open(NETWORKSFILE, 'a') do |fh|
      fh.puts resource[:name] + " " + resource[:network] + " " + resource[:aliases]
    end
  end

  def destroy
    local_lines = lines
    File.open(NETWORKSFILE,'w') do |fh|
      fh.write(local_lines.reject{|l| l.chomp == resource[:network] }.join(''))
    end
  end

  def self.instances
    lines.each do |line|
    end
  lines
  end

  def self.lines
    @lines ||= File.readlines(NETWORKSFILE)
  end

  private
  def lines
      @lines ||= File.readlines(NETWORKSFILE)
  end

end

