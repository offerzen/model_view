module ModelView
  class Resolver

    class << self
      def resolve(obj, scopes, scope=nil, context={})
        scope ||= ModelView::ROOT

        fields = fields_for_scope(scope, scopes)

        fields.each_with_object({}) do |(field_name, field_data), result|
          result[field_name] = evaluate_field(obj, field_name, field_data[:args], field_data[:block], context)
        end

      end

      def fields_for_scope(scope, scope_data)
        root_scope_fields = extract_fields(ModelView::ROOT, scope_data)
        scope_fields = scope == ModelView::ROOT ? {} : extract_fields(scope, scope_data)

        extended_scopes = scope_data[scope][:extends] || []
        extended_fields = extended_scopes.reduce({}) do |res, scope|
          res.merge(extract_fields(scope, scope_data))
        end

        included_scopes = (scope_data[scope][:includes] || []).reduce({}) do |res, scope_name|
          res[scope_name] = fields_for_scope(scope_name, scope_data)
          res
        end

        {}.merge(root_scope_fields)
          .merge(scope_fields)
          .merge(extended_fields)
          .merge(included_scopes)
      end

      private

      def evaluate_field(object, field_name, options, block, context)
        if block.nil?
          object.send(field_name)
        else
          if block.arity == 1
            block.call(object)
          else
            arguments_for_block = options[:context].map { |key| context[key] }
            block.call(object, *arguments_for_block)
          end
        end
      end

      def extract_fields(scope, scope_data)
        scope_data[scope][:fields]
      end

    end
  end

end
