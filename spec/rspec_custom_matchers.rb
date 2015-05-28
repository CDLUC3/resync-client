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
