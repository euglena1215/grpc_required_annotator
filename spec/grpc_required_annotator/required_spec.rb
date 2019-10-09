require 'spec_helper'
require 'grpc'

RSpec.describe GrpcRequiredAnnotator::Required do
  describe "#validate!" do
    let(:request) { double("TestRequest") }

    subject { required.validate!(request) }

    describe "single field" do
      let(:required) { described_class.new([:a]) }

      context "when field does not exist in request" do
        it "raises NotExistFieldError" do
          expect { subject }.to raise_error(GrpcRequiredAnnotator::Required::NotExistFieldError)
        end
      end

      context "when field is integer" do
        context "when field is 0" do
          before {
            allow(request).to receive(:a).and_return(0)
          }

          it "raises GRPC::InvalidArgument" do
            expect { subject }.to raise_error(GRPC::InvalidArgument)
          end
        end

        context "when field is not 0" do
          before {
            allow(request).to receive(:a).and_return(1)
          }

          it "passes" do
            is_expected.to be true
          end
        end
      end

      context "when field is string" do
        context "when field is blank" do
          before {
            allow(request).to receive(:a).and_return("")
          }

          it "raises GRPC::InvalidArgument" do
            expect { subject }.to raise_error(GRPC::InvalidArgument)
          end
        end

        context "when field is present" do
          before {
            allow(request).to receive(:a).and_return("foo")
          }

          it "passes" do
            is_expected.to be true
          end
        end
      end

      context "when field is field mask" do
        context "when field is empty" do
          before {
            allow(request).to receive(:a).and_return(Google::Protobuf::FieldMask.new)
          }

          it "raises GRPC::InvalidArgument" do
            expect { subject }.to raise_error(GRPC::InvalidArgument)
          end
        end

        context "when field is present" do
          before {
            allow(request).to receive(:a).and_return(Google::Protobuf::FieldMask.new(paths: ["foo"]))
          }

          it "passes" do
            is_expected.to be true
          end
        end
      end

      context "when field is array" do
        context "when field is empty" do
          before {
            allow(request).to receive(:a).and_return([])
          }

          it "raises GRPC::InvalidArgument" do
            expect { subject }.to raise_error(GRPC::InvalidArgument)
          end
        end

        context "when field is present" do
          before {
            allow(request).to receive(:a).and_return(['value'])
          }

          it "passes" do
            is_expected.to be true
          end
        end
      end

      context "when field is symbol" do
        context "when field contains 'UNSPECIFIED'" do
          before {
            allow(request).to receive(:a).and_return(:FOO_UNSPECIFIED)
          }

          it "raises GRPC::InvalidArgument" do
            expect { subject }.to raise_error(GRPC::InvalidArgument)
          end
        end

        context "when field does not contain 'UNSPECIFIED'" do
          before {
            allow(request).to receive(:a).and_return(:FOO_BAR)
          }

          it "passes" do
            is_expected.to be true
          end
        end
      end

      context "when field is null" do
        before {
          allow(request).to receive(:a).and_return(nil)
        }

        it "raises GRPC::InvalidArgument" do
          expect { subject }.to raise_error(GRPC::InvalidArgument)
        end
      end

      context "when field is unsuported" do
        let(:unsupported_klass) { Struct.new(:foo) }

        before {
          allow(request).to receive(:a).and_return(unsupported_klass.new)
        }

        it "raises UnsupportedTypeError" do
          expect { subject }.to raise_error(GrpcRequiredAnnotator::Required::UnsupportedTypeError)
        end
      end
    end

    describe "multiple fields" do
      let(:required) { described_class.new([:a, :b]) }

      context "when one of fields is invalid" do
        before {
          allow(request).to receive(:a).and_return(1)
          allow(request).to receive(:b).and_return(0)
        }

        it "raises GRPC::InvalidArgument" do
          expect { subject }.to raise_error(GRPC::InvalidArgument)
        end
      end

      context "when one of fields is unsupported" do
        let(:unsupported_klass) { Struct.new(:foo) }

        before {
          allow(request).to receive(:a).and_return(unsupported_klass.new)
          allow(request).to receive(:b).and_return(1)
        }

        it "raises UnsupportedTypeError" do
          expect { subject }.to raise_error(GrpcRequiredAnnotator::Required::UnsupportedTypeError)
        end
      end

      context "when all fields are valid" do
        before {
          allow(request).to receive(:a).and_return(1)
          allow(request).to receive(:b).and_return(1)
        }

        it "passes" do
          is_expected.to be true
        end
      end
    end
  end
end
