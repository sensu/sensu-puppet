module SensuctlHashpass
  def self.which_sensuctl
    value = system('which sensuctl')
    return nil unless $?.success?
    value
  end

  def self.get_hashpass(password)
    hash = system("sensuctl hashpass '#{password}' 2>&1")
    return nil unless $?.success?
    hash
  end

  def self.bcrypt?
    begin
      require 'bcrypt'
    rescue LoadError
      return false
    end
    true
  end
end

# Generate a bcrypt password hash
Puppet::Functions.create_function(:'sensu::password_hash') do
  # @param password The password to use when generating the hash
  # @return [String] The bcrypt password hash
  # @example Generate a password hash
  #   sensu::password_hash('P@ssw0rd!')
  dispatch :create_hash do
    param 'String', :password
  end

  def create_hash(password)
    sensuctl = ::SensuctlHashpass.which_sensuctl
    if sensuctl
      hash = ::SensuctlHashpass.get_hashpass(password)
      fail "Unable to generate password hash" if hash.nil?
      return hash
    else
      if ! ::SensuctlHashpass.bcrypt?
        fail "sensuctl not found and bcrypt not present"
      end
      hash = BCrypt::Password.create(password)
      return hash.to_s
    end
  end
end

