require 'google/protobuf/field_mask_pb'

module GrpcRequiredAnnotator
  class Required
    class UnsupportedTypeError < StandardError; end
    class NotExistFieldError < StandardError; end

    attr_reader :fields

    def initialize(fields)
      @fields = fields
    end

    def validate!(request)
      @fields.each do |field|
        unless request.respond_to?(field)
          raise NotExistFieldError.new("#{field} does not exist in #{request.class}")
        end

        value = request.public_send(field)

        case value
        when Integer
          raise GRPC::InvalidArgument.new("`#{field}` is required") if value == 0
        when String
          raise GRPC::InvalidArgument.new("`#{field}` is required") if value == ""
        when Google::Protobuf::FieldMask
          raise GRPC::InvalidArgument.new("`#{field}` is required") if value.paths.empty?
        when Array
          raise GRPC::InvalidArgument.new("`#{field}` is required") if value.empty?
        when Symbol
          raise GRPC::InvalidArgument.new("`#{field}` is required") if value.to_s.include?("UNSPECIFIED") # https://developers.google.com/protocol-buffers/docs/style#enums
        when nil
          raise GRPC::InvalidArgument.new("`#{field}` is required")
        else
          raise UnsupportedTypeError.new("#{value.class} is not supported. value is #{value}")
        end
      end

      true
    end
  end
end
