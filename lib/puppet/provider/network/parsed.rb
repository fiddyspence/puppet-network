require 'puppet/provider/parsedfile'

  networks = "/etc/networks"


Puppet::Type.type(:network).provide(:parsed,:parent => Puppet::Provider::ParsedFile,
  :default_target => networks,:filetype => :flat) do
  confine :exists => networks

  text_line :comment, :match => /^#/
  text_line :blank, :match => /^\s*$/

  record_line :parsed, :fields => %w{name subnet host_aliases},
    :optional => %w{host_aliases},
    :match    => /^(\S+)\s+(\S+)\s*(.*?)?(?:\s*#\s*(.*))?$/,
    :post_parse => proc { |hash|
      # An absent aliases should match "aliases => ''"
      hash[:host_aliases] = '' if hash[:host_aliases].nil? or hash[:host_aliases] == :absent
      unless hash[:host_aliases].nil? or hash[:host_aliases] == :absent
        hash[:host_aliases].gsub!(/\s+/,' ') # Change delimiter
      end
    },
    :to_line  => proc { |hash|
      [:name, :subnet].each do |n|
        raise ArgumentError, "#{n} is a required attribute for networks" unless hash[n] and hash[n] != :absent
      end
      str = "#{hash[:name]}\t#{hash[:subnet]}"
      if hash.include? :host_aliases and !hash[:host_aliases].nil? and hash[:host_aliases] != :absent
        str += "\t#{hash[:host_aliases]}"
      end
      str
    }
end
