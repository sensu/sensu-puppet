# The MIT License (MIT)
#
# Copyright (c) 2015 aj-jester
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# From: https://gist.github.com/aj-jester/e0078c38db9eb7c1ef45

require 'json'

module JSON
  class << self
    @@loop = 0

    def validate_keys(obj)
      Puppet.debug("hello")
      obj.keys.each do |k|
        case k
          when String
            Puppet.debug("Found a valid key: " << k)
          else
            raise(Puppet::ParseError, "Unable to use key of type <%s>" % k.class.to_s)
        end
      end
    end

    def sorted_generate(obj)
      case obj
        when Fixnum, Float, TrueClass, FalseClass, NilClass
          return obj.to_json
        when String
          # Convert quoted integers (string) to int
          return (obj.match(/\A[-]?[0-9]+\z/) ? obj.to_i : obj).to_json
        when Array
          arrayRet = []
          obj.each do |a|
            arrayRet.push(sorted_generate(a))
          end
          return "[" << arrayRet.join(',') << "]";
        when Hash
          ret = []
          validate_keys(obj)
          obj.keys.sort.each do |k|
            ret.push(k.to_s.to_json << ":" << sorted_generate(obj[k]))
          end
          return "{" << ret.join(",") << "}";
        else
          raise(Puppet::ParseError, "Unable to handle object of type <%s>" % obj.class.to_s)
      end
    end

    def sorted_pretty_generate(obj, indent_len=4)
      # Indent length
      indent = " " * indent_len

      case obj

        when Fixnum, Float, TrueClass, FalseClass, NilClass
          return obj.to_json

        when String
          # Convert quoted integers (string) to int
          return (obj.match(/\A[-]?[0-9]+\z/) ? obj.to_i : obj).to_json

        when Array
          arrayRet = []

          # We need to increase the loop count before #each so the objects inside are indented twice.
          # When we come out of #each we decrease the loop count so the closing brace lines up properly.
          #
          # If you start with @@loop = 1, the count will be as follows
          #
          # "start_join": [     <-- @@loop == 1
          #   "192.168.50.20",  <-- @@loop == 2
          #   "192.168.50.21",  <-- @@loop == 2
          #   "192.168.50.22"   <-- @@loop == 2
          # ] <-- closing brace <-- @@loop == 1
          #
          @@loop += 1
          obj.each do |a|
            arrayRet.push(sorted_pretty_generate(a, indent_len))
          end
          @@loop -= 1

          return "[\n#{indent * (@@loop + 1)}" << arrayRet.join(",\n#{indent * (@@loop + 1)}") << "\n#{indent * @@loop}]";

        when Hash
          ret = []
          validate_keys(obj)

          # This loop works in a similar way to the above
          @@loop += 1
          obj.keys.sort.each do |k|
            ret.push("#{indent * @@loop}" << k.to_json << ": " << sorted_pretty_generate(obj[k], indent_len))
          end
          @@loop -= 1

          return "{\n" << ret.join(",\n") << "\n#{indent * @@loop}}";
        else
          raise(Puppet::ParseError, "Unable to handle object of type <%s>" % obj.class.to_s)
      end
    end # end def
  end # end class
end # end module

module Puppet::Parser::Functions
  newfunction(:sensu_sorted_json, :type => :rvalue, :doc => <<-EOS
This function takes unsorted hash and outputs JSON object making sure the keys are sorted.
Optionally you can pass a boolean as the second parameter, which controls if
the output is pretty formatted.

*Examples:*

    -------------------
    -- UNSORTED HASH --
    -------------------
    unsorted_hash = {
      'client_addr' => '127.0.0.1',
      'bind_addr'   => '192.168.34.56',
      'start_join'  => [
        '192.168.34.60',
        '192.168.34.61',
        '192.168.34.62',
      ],
      'ports'       => {
        'rpc'   => 8567,
        'https' => 8500,
        'http'  => -1,
      },
    }

    -----------------
    -- SORTED JSON --
    -----------------

    sorted_json(unsorted_hash)

    {"bind_addr":"192.168.34.56","client_addr":"127.0.0.1",
    "ports":{"http":-1,"https":8500,"rpc":8567},
    "start_join":["192.168.34.60","192.168.34.61","192.168.34.62"]}

    ------------------------
    -- PRETTY SORTED JSON --
    ------------------------
    Params: data <hash>, pretty <true|false>.

    sorted_json(unsorted_hash, true)

    {
        "bind_addr": "192.168.34.56",
        "client_addr": "127.0.0.1",
        "ports": {
            "http": -1,
            "https": 8500,
            "rpc": 8567
        },
        "start_join": [
            "192.168.34.60",
            "192.168.34.61",
            "192.168.34.62"
        ]
    }

    EOS
  ) do |args|

    raise(Puppet::ParseError, "sensu_sorted_json(): Wrong number of arguments " +
      "given (#{args.size} for 1 or 2)") unless args.size.between?(1,2)

    unsorted_hash = args[0]      || {}
    pretty        = args[1]      || false
    indent_len    = 4

    unsorted_hash.reject! {|key, value| value == :undef }

    if pretty
      return JSON.sorted_pretty_generate(unsorted_hash, indent_len) << "\n"
    else
      return JSON.sorted_generate(unsorted_hash)
    end
  end
end
