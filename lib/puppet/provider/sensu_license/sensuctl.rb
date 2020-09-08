require File.expand_path(File.join(File.dirname(__FILE__), '..', 'sensuctl'))

Puppet::Type.type(:sensu_license).provide(:sensuctl, :parent => Puppet::Provider::Sensuctl) do
  desc "Provider sensu_license using sensuctl"

  def exists?
    ret = execute(['sensuctl', 'license', 'info'], failonfail: false)
    exitstatus = ret.exitstatus
    exitstatus == 0
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def create
    begin
      output = sensuctl(['create','-f',resource[:file]])
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "sensuctl create failed\nOutput: #{output}\nError message: #{e.message}"
    end
  end

  def destroy
    begin
      output = sensuctl(['delete','-f',resource[:file]])
    rescue Puppet::ExecutionFailure => e
      raise Puppet::Error, "sensuctl create failed\nOutput: #{output}\nError message: #{e.message}"
    end
  end
end

