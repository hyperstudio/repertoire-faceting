module DataMapper
  module Types
    class Array < DataMapper::Type
      
      extend DataObjects::Quoting
      
      def self.new(item_primitive)
        ary = Class.new(Array)
        ary.instance_variable_set("@primitive", String)
        ary.instance_variable_set("@item_primitive", item_primitive)
        ary
      end

      def self.[](item_primitive)
        new(item_primitive)
      end

      def self.load(value, property)
        # TODO.  pretty rough and ready here...  make more robust by using DataObjects directly
        return nil if value.nil?
        if value =~ /^\{(.*)\}$/
          value = $1.split(',')       # note: misinterprets commas embedded in strings
          value.map { |v| item_typecast(v) }
        else
          raise ArgumentError.new("Bad syntax for SQL array: #{value}")
        end
      end

      def self.dump(value, property)
        return nil if value.nil?
        items = value.map { |v| quote_value(v) }
        "{" + items.join(', ') + "}"
      end
      
      def self.typecast(value, property)
        value
      end

      private
      # adapted from property.rb why isn't this available in DataMapper::Types?
      def self.item_typecast(value)
        return value if value.kind_of?(@item_primitive) || value.nil?
        begin
          if    @item_primitive == TrueClass  then %w[ true 1 t ].include?(value.to_s.downcase)
          elsif @item_primitive == String     then value.to_s
          elsif @item_primitive == Float      then value.to_f
          elsif @item_primitive == Integer
            value_to_i = value.to_i
            if value_to_i == 0 && value != '0'
              value_to_s = value.to_s
              begin
                Integer(value_to_s =~ /^(\d+)/ ? $1 : value_to_s)
              rescue ArgumentError
                nil
              end
            else
              value_to_i
            end
          elsif @item_primitive == BigDecimal then BigDecimal(value.to_s)
          # TODO.  don't see time when we'll use arrays of dates/times
          #elsif @item_primitive == DateTime   then typecast_to_datetime(value)
          #elsif @item_primitive == Date       then typecast_to_date(value)
          #elsif @item_primitive == Time       then typecast_to_time(value)
          elsif @item_primitive == Class      then self.class.find_const(value)
          else
            value
          end
        rescue
          value
        end
      end

    end
  end # module Types
end # module DataMapper
    