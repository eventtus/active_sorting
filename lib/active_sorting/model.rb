module ActiveSorting
  module Model # :nodoc:
    def self.included(base)
      base.extend ClassMethods
      # Track all sortable arguments
      base.class_attribute :active_sorting_options
    end

    # Patches ActiveRecord models
    module ClassMethods
      # Sets the sortable options
      #
      # +name+ sortable field name
      # Accepts a Hash of options:
      # +order+ sorting direction, defaults to :asc
      # +step+ stepping value, defaults to 500
      # +scope+ scope field name, defaults to []
      def sortable(name, opts = {})
        self.active_sorting_options = active_sorting_default_options.merge(opts)
        active_sorting_options[:name] = name
        active_sorting_check_options
        validates active_sorting_options[:name], presence: true
        before_validation :active_sorting_callback_before_validation
      end

      # Default sorting options
      def active_sorting_default_options
        {
          order: :asc,
          step: 500,
          scope: []
        }
      end

      # Check provided options
      def active_sorting_check_options
        field_type = columns_hash[active_sorting_field.to_s].type
        unless field_type == :integer
          raise ArgumentError, "Sortable field should be of type Integer, #{field_type} given"
        end
        unless active_sorting_step.is_a?(Fixnum)
          raise ArgumentError, 'Sortable step should be of type Fixnum'
        end
      end

      # Calculate the least possible changes required to
      # reorder items in +old_list+ to match +new_list+ order
      # by comparing two proposals from
      # +active_sorting_calculate_changes+
      def active_sorting_changes_required(old_list, new_list)
        changes = []
        if old_list.count != new_list.count
          raise ArgumentError, "Size mismatch between new (#{new_list.count}) and old (#{old_list.count}) array of items"
        end
        proposal1 = active_sorting_calculate_changes(old_list.dup, new_list.dup)
        if proposal1.count >= (new_list.count / 4)
          proposal2 = active_sorting_calculate_changes(old_list.reverse, new_list.reverse)
          changes = proposal1.count < proposal2.count ? proposal1 : proposal2
        else
          changes = proposal1
        end
        changes
      end

      # Calculate the possible changes required to
      # reorder items in +old_list+ to match +new_list+ order
      def active_sorting_calculate_changes(old_list, new_list, changes = [])
        new_list.each_with_index do |id, index|
          next unless old_list[index] != id
          # This item has changed
          changes << id
          # Remove it from both lists, rinse and repeat
          new_list.delete(id)
          old_list.delete(id)
          # Recur...
          active_sorting_calculate_changes(old_list, new_list, changes)
          break
        end
        changes
      end

      # Commit changes to database
      def active_sorting_make_changes(new_list, changes)
        new_list.each_with_index do |id, index|
          next unless changes.include?(id)
          if index == new_list.count.pred
            # We're moving an item to last position,
            # increase the count of last item's position
            # by the step
            n1 = find(index.pred).active_sorting_value
            n2 = n1 + active_sorting_step
          elsif index == 0
            # We're moving an item to first position
            # Calculate the gap between following 2 items
            n1 = find(index.next).active_sorting_value
            n2 = find(index.next.next).active_sorting_value
          else
            # We're moving a non-terminal item
            n1 = find(index.pred).active_sorting_value
            n2 = find(index.next).active_sorting_value
          end
          find(id).active_sorting_center_item(n1, n2)
        end
      end

      def active_sorting_field
        active_sorting_options[:name]
      end

      def active_sorting_step
        active_sorting_options[:step]
      end

      def active_sorting_order
        active_sorting_options[:order]
      end
    end

    def active_sorting_value
      send(self.class.active_sorting_field)
    end

    def active_sorting_value=(new_value)
      send("#{self.class.active_sorting_field}=", new_value)
    end

    # Centers an item between the given two positions
    def active_sorting_center_item(n1, n2)
      delta = (n1 - n2).abs
      smaller = [n1, n2].min
      if delta == 1
        new_position = smaller + delta
      elsif delta > 1
        new_position = smaller + (delta / 2)
      end
      self.active_sorting_value = new_position
      save!
      self
    end

    # Generate the next stepping
    def active_sorting_next_step
      # Get the maximum value for the sortable field name
      # TODO: scopes
      max = self.class.unscoped.maximum(self.class.active_sorting_field)
      # First value will always be 0
      return 0 if max.nil?
      # Increment by the step value configured
      max + self.class.active_sorting_step
    end

    ## Callbacks
    # Generates a new code based on given options
    def active_sorting_callback_before_validation
      field_name = self.class.active_sorting_field
      send("#{field_name}=", active_sorting_next_step) if send(field_name).nil?
    end
  end
end
