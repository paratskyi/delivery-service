require 'rspec/expectations'

RSpec::Matchers.define :instances_exact_match_array do |expected|
  match do |actual|
    actual_array = actual.map(&:to_s).sort
    expected_array = expected.map(&:to_s).sort
    actual_array.each_with_index do |instance, index|
      return false if instance != expected_array[index]
    end
  end

  failure_message do |actual|
    "expected that each instance of #{actual} collection\nexact equal to each instance of #{expected} collection"
  end
end
