# Compatibility shim: puppet 8's module_tool/tar/mini.rb uses Archive::Tar::Minitar
# but minitar 1.x dropped the archive/tar/minitar require path. This shim restores
# it by aliasing the new Minitar module under the old namespace.
# NOTE: const_defined?(:Minitar, false) — the false arg checks only the immediate
# scope, not ancestors. Without it, ::Minitar in the lookup chain would return truthy
# and the assignment would be skipped.
require 'minitar'
module Archive
  module Tar
    const_set(:Minitar, ::Minitar) unless const_defined?(:Minitar, false)
  end
end
