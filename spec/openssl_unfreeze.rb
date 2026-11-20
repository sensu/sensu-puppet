# Workaround: openssl gem 3.3+ (Ruby 3.4) freezes OpenSSL::SSL::SSLContext::DEFAULT_PARAMS
# but puppet 8's monkey_patches.rb mutates it in place, causing FrozenError.
#
# When loaded via RUBYOPT before bundler has activated gems we must NOT call
# require 'openssl' ourselves -- that would activate the wrong default-gem version
# and then bundler's setup.rb would raise Gem::LoadError (already activated X, need Y).
#
# Don't hook Kernel#require either: other code redefines it in ways that break
# or bypass a hook. rspec-puppet 6 aliases it (breaks a prepended hook's super)
# and Ruby's bundled_gems.rb replaces it (skips an alias-chain hook). Instead, a
# TracePoint on :class unfreezes DEFAULT_PARAMS when puppet reopens
# `class OpenSSL::SSL::SSLContext`, before the class body runs.
unless defined?(SensuOpenSSLUnfreeze)
  module SensuOpenSSLUnfreeze
    def self.unfreeze!
      return unless defined?(OpenSSL::SSL::SSLContext::DEFAULT_PARAMS)
      return unless OpenSSL::SSL::SSLContext::DEFAULT_PARAMS.frozen?

      unfrozen = OpenSSL::SSL::SSLContext::DEFAULT_PARAMS.dup
      OpenSSL::SSL::SSLContext.send(:remove_const, :DEFAULT_PARAMS)
      OpenSSL::SSL::SSLContext.const_set(:DEFAULT_PARAMS, unfrozen)
    end

    TRACE = TracePoint.new(:class) do |tp|
      if defined?(OpenSSL::SSL::SSLContext) && tp.self.equal?(OpenSSL::SSL::SSLContext)
        SensuOpenSSLUnfreeze.unfreeze!
      end
    end
    TRACE.enable
  end
end

SensuOpenSSLUnfreeze.unfreeze!
