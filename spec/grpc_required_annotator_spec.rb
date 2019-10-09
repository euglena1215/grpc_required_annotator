require 'spec_helper'

RSpec.describe GrpcRequiredAnnotator do
  it "has a version number" do
    expect(GrpcRequiredAnnotator::VERSION).not_to be nil
  end

  before {
    class SampleService
      include GRPC::GenericService
      include GrpcRequiredAnnotator

      required :field1
      def test(request, call)
        "ok"
      end
    end
  }

  describe ".required" do
    describe "GRPC::GenericService is not included" do
      it "raises TypeError" do
        expect {
          class SampleServiceWithoutGRPCGenericService
            include GrpcRequiredAnnotator

            required :field1
            def test(request, call)
              "ok"
            end
          end
        }.to raise_error(TypeError)
      end
    end

    describe "request is valid" do
      let(:request) {
        request = double("TestRequest")
        allow(request).to receive(:field1).and_return(1)
        request
      }

      it "passes" do
        expect(SampleService.new.test(request, nil)).to eq "ok"
      end
    end

    describe "request is invalid" do
      let(:request) {
        request = double("TestRequest")
        allow(request).to receive(:field1).and_return(0)
        request
      }

      it "raises GRPC::InvalidArgument" do
        expect { SampleService.new.test(request, nil) }.to raise_error(GRPC::InvalidArgument)
      end
    end
  end

  describe ".required_fields" do
    context "method does not exist" do
      it "returns nil" do
        expect(SampleService.required_fields(:test2)).to be nil
      end
    end

    context "method exists" do
      it "returns required fields" do
        expect(SampleService.required_fields(:test)).to eq [:field1]
      end
    end
  end

  it "does not change ancestors" do
    expect(SampleService.ancestors.first(3)).to eq [
      SampleService,
      GrpcRequiredAnnotator,
      GRPC::GenericService
    ]
  end
end
