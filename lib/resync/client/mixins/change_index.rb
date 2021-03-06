require 'resync'
require 'resync/client/mixins/resource_client_delegate'

module Resync
  class Client
    module Mixins
      # A resource container whose resources are lists of changes.
      module ChangeIndex
        prepend ResourceClientDelegate

        # Downloads and parses each resource list and returns a flattened enumeration
        # of all changes in each contained list, filtering by date/time, change type,
        # or both. (Each contained list is only downloaded as needed, and only downloaded
        # once.) The lists of lists are filtered by +from_time+ and +until_time+, in
        # non-strict mode (only excluding those lists provably not in the range, i.e.,
        # including lists without +from_time+ or +until_time+); the individual changes
        # are filtered by +modified_time+.
        #
        # @param of_type [Resync::Types::Change, nil] the change type
        # @param in_range [Range<Time>, nil] the time range
        # @return [Enumerator::Lazy<Resync::Resource>] the flattened enumeration of changes
        def all_changes(of_type: nil, in_range: nil)
          @change_lists ||= {}
          lists = in_range ? change_lists(in_range: in_range, strict: false) : resources
          lists.lazy.flat_map do |cl|
            @change_lists[cl] ||= cl.get_and_parse
            @change_lists[cl].changes(of_type: of_type, in_range: in_range)
          end
        end
      end
    end
  end

  class BaseChangeIndex
    prepend Client::Mixins::ChangeIndex
  end

  class ChangeList
    # Delegates to {ChangeList#changes} for interoperation with {ChangeList#all_changes}.
    # @param of_type [Types::Change] the change type
    # @param in_range [Range<Time>] the range of modification times
    # @return [Enumerator::Lazy<Resource>] a lazy enumeration of the matching changes, or all
    #   changes if neither +of_type+ nor +in_range+ is specified.
    def all_changes(of_type: nil, in_range: nil)
      changes(of_type: of_type, in_range: in_range).lazy
    end
  end
end
