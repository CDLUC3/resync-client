require 'rspec/expectations'

RSpec::Matchers.define :request_for do |h|
  match do |actual|
    begin
      !h.key?(:uri) || actual.uri == h[:uri] &&
        !h.key?(:method) || actual.method == h[:method] &&
          !h.key?(:headers) || actual.to_hash == h[:headers]
    end
  end
end

RSpec::Matchers.define :be_time do |expected|

  def to_string(time)
    time.is_a?(Time) ? time.utc.round(2).iso8601(2) : time.to_s
  end

  match do |actual|
    return actual.nil? unless expected
    raise "Expected value #{expected} is not a Time" unless expected.is_a?(Time)
    actual.is_a?(Time) && (to_string(expected) == to_string(actual))
  end

  failure_message do |actual|
    expected_str = to_string(expected)
    actual_str = to_string(actual)
    "expected time:\n#{expected_str}\n\nbut was:\n#{actual_str}"
  end
end
