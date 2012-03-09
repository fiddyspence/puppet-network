require 'puppet/property/ordered_list'

module Puppet
  newtype(:network) do
    ensurable

    newproperty(:subnet) do
      desc "The host's IP address, IPv4 or IPv6."

      def valid_v4?(addr)
        if /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.0$/ =~ addr
          return $~.captures.all? {|i| i = i.to_i; i >= 0 and i <= 255 }
        end
        return false
      end

      validate do |value|
        return true if valid_v4?(value) 
        raise Puppet::Error, "Invalid Class A, B or C network address #{value.inspect}"
      end
    end
    
    # for now we use OrderedList to indicate that the order does matter.
    newproperty(:host_aliases, :parent => Puppet::Property::OrderedList) do
      desc "Any aliases the network might have.  Multiple values must be
        specified as an array."

      def delimiter
        " "
      end

      def inclusive?
        true
      end

      validate do |value|
        raise Puppet::Error, "network aliases cannot include whitespace or comment characters" if value =~ /[\s#]/
        raise Puppet::Error, "Host alias cannot be an empty string. Use an empty array to delete all host_aliases " if value =~ /^\s*$/
      end

    end

    newproperty(:target) do
      desc "The file in which to store service information.  Only used by
        those providers that write to disk. On most systems this defaults to `/etc/networks`."

      defaultto { if @resource.class.defaultprovider.ancestors.include?(Puppet::Provider::ParsedFile)
        @resource.class.defaultprovider.default_target
        else
          nil
        end
      }
    end

    newparam(:name) do
      desc "The network name."

      isnamevar

      validate do |value|
        if value =~ /[#\s]/
          raise Puppet::Error, "Invalid network name #{value.inspect}"
        end
      end
    end

    @doc = "Installs and manages network entries.  For most systems, these
      entries will just be in `/etc/networks`, but some systems (notably OS X)
      will have different solutions."
  end
end
