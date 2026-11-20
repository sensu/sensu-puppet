# Workaround: openssl gem 3.3+ (Ruby 3.4) freezes OpenSSL::SSL::SSLContext::DEFAULT_PARAMS
# but puppet 8's monkey_patches.rb mutates it in place, causing FrozenError.
#
# When loaded via RUBYOPT before bundler has activated gems we must NOT call
# require 'openssl' ourselves -- that would activate the wrong default-gem version
# and then bundler's setup.rb would raise Gem::LoadError (already activated X, need Y).
# Instead, if openssl is already loaded apply the fix now; otherwise hook Kernel#require
# so the fix is applied the moment openssl is loaded (by bundler, puppet, or anyone else).
if defined?(OpenSSL::SSL::SSLContext::DEFAULT_PARAMS)
  if OpenSSL::SSL::SSLContext::DEFAULT_PARAMS.frozen?
    unfrozen = OpenSSL::SSL::SSLContext::DEFAULT_PARAMS.dup
    OpenSSL::SSL::SSLContext.send(:remove_const, :DEFAULT_PARAMS)
    OpenSSL::SSL::SSLContext.const_set(:DEFAULT_PARAMS, unfrozen)
  end
else
  module OpenSSLUnfreezeOnRequire
    def require(name)
      result = super
      if defined?(OpenSSL::SSL::SSLContext::DEFAULT_PARAMS) &&
         OpenSSL::SSL::SSLContext::DEFAULT_PARAMS.frozen?
        unfrozen = OpenSSL::SSL::SSLContext::DEFAULT_PARAMS.dup
        OpenSSL::SSL::SSLContext.send(:remove_const, :DEFAULT_PARAMS)
        OpenSSL::SSL::SSLContext.const_set(:DEFAULT_PARAMS, unfrozen)
      end
      result
    end
  end
  Kernel.prepend(OpenSSLUnfreezeOnRequire)
end
