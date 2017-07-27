module PuppetX
  module Sensu
    module SortHash
      # Given a hash, sort it recursively by the key.  This is intended to
      # produce stable JSON output.  Only hash maps and nested values which are
      # a hash map are affected.  Other sequences remain unmodified.  No effort
      # is made to duplicated nested hashes.  This method is fairly inefficient
      # because large amounts of data aren't expected as input.
      #
      # @param [Hash] hsh the input hash map to sort by key.
      #
      # @return [Hash] A new, sorted hash map by key.
      def sort_hash(hsh)
        ary = hsh.sort.map do |k,v|
          Hash === v ? [k, sort_hash(v)] : [k,v]
        end
        Hash[ary]
      end
    end
  end
end
