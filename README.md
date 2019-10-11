# GrpcRequiredAnnotator [![Gem Version](https://badge.fury.io/rb/grpc_required_annotator.svg)](https://badge.fury.io/rb/grpc_required_annotator) [![Build Status](https://travis-ci.com/euglena1215/grpc_required_annotator.svg?branch=master)](https://travis-ci.com/euglena1215/grpc_required_annotator) [![codecov](https://codecov.io/gh/euglena1215/grpc_required_annotator/branch/master/graph/badge.svg)](https://codecov.io/gh/euglena1215/grpc_required_annotator)

GrpcRequiredAnnotator is a annotator for null validation of gRPC requests using `required`.

### Supported Types

- Integer (int64, int32, etc...)
- String (string)
- Google::Protobuf::FieldMask (field_mask)
- Google::Protobuf::RepeatedField (repeated fields)
- Symbol (enum)

### Unsupported Types

- oneof
- embedded messages

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'grpc_required_annotator'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install grpc_required_annotator

## Usage

```proto
syntax = "proto3";
package sample;

option ruby_package = "SamplePb";

service Sample {
    rpc Foo (FooRequest) returns (FooResponse);
}

message FooRequest {
    int64 a = 1;
    string b = 2;
}

message FooResponse {
    int64 a = 1;
    string b = 2;
}
```

```rb
class SampleService < SamplePb::Sample::Service
  include GrpcRequiredAnnotator

  # If a or b are null, raises GRPC::InvalidArgument
  required :a, :b
  def foo(request, call)
    ## `required :a, :b` is equivalent to the following:
    # raise GRPC::InvalidArgument.new("`a` is required") if req.a == 0
    # raise GRPC::InvalidArgument.new("`b` is required") if req.b == ""
    FooResponse.new(a: req.a, b: req.b)
  end
end
```

### Testing by rspec

```rb
RSpec.describe SampleService do
  describe "#foo" do
    describe "required" do
      it "a and b are required" do
        expect(described_class.required_fields(:foo)).to eq [:a, :b]
      end
    end
  end
end

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/grpc_required_annotator. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Grpc::Required::Annotator project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/grpc_required_annotator/blob/master/CODE_OF_CONDUCT.md).
