Puppet::Type.newtype(:network) do

  @doc = "Manage the contents of /etc/networks"

  ensurable

  newparam(:name) do
    desc "The name of the network"
    isnamevar
    newvalues(/\w+/)
  end

  newparam(:ipsubnet) do
    desc "The IP subnet of the nework"
  end

  newparam(:aliases) do
    desc "Aliases for networks"
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
end

