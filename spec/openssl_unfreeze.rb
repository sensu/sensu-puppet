# Workaround: OpenSSL::SSL::SSLContext::DEFAULT_PARAMS is frozen in openssl gem
# 3.3+ (shipped with Ruby 3.4) but puppet's monkey_patches.rb tries to modify it
# in place. Unfreeze the hash before puppet loads so the modification succeeds.
require 'openssl'
if OpenSSL::SSL::SSLContext::DEFAULT_PARAMS.frozen?
  unfrozen = OpenSSL::SSL::SSLContext::DEFAULT_PARAMS.dup
  OpenSSL::SSL::SSLContext.send(:remove_const, :DEFAULT_PARAMS)
  OpenSSL::SSL::SSLContext.const_set(:DEFAULT_PARAMS, unfrozen)
end
