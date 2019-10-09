require 'grpc_required_annotator/version'
require 'grpc_required_annotator/required'

module GrpcRequiredAnnotator
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    attr_reader :_required_hash

    def required(*fields)
      raise TypeError.new("cannot annotate `required` without GRPC::GenericService module") unless self < GRPC::GenericService

      @_last_required = Required.new(fields)
    end

    def required_fields(method_name)
      return nil unless @_required_hash[method_name]

      @_required_hash[method_name].fields
    end

    def method_added(name)
      @_required_hash ||= {}

      if @_last_required
        @_required_hash[name] = @_last_required
        @_last_required = nil
        define_required_validate(name)
      end

      super
    end

    private

    def define_required_validate(name)
      old_name = "#{name}_".to_sym

      class_eval {
        alias_method old_name, name
        private old_name

        define_method(name) do |request, call|
          self.class._required_hash[name].validate!(request)
          send(old_name, request, call)
        end
      }
    end
  end
end
