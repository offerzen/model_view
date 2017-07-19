module ModelView
  class Updater

    class << self
      def update(obj, scopes, data, scope=nil)
        scope ||= ModelView::ROOT

        setters = setters_for_scope(scope, scopes)

        data.each do |key, value|
          setter = if !setters[key].nil?
            setter_for_key(setters, key)
          else
            nil
          end

          setter.call(obj, value) if setter
        end
      end

      private
      def setter_for_key(setters, key)
        return nil if setters[key].nil?
        if setters[key][:block]
          setters[key][:block]
        else
          lambda { |obj, value| obj.send("#{key}=", value) }
        end
      end

      def setters_for_scope(scope, scope_data)
        root_scope_setters = extract_setters(ModelView::ROOT, scope_data)
        scope_setters = scope == ModelView::ROOT ? {} : extract_setters(scope, scope_data)

        extended_scopes = scope_data[scope][:extends] || []
        extended_setters = extended_scopes.reduce({}) do |res, scope|
          res.merge(extract_setters(scope, scope_data))
        end

        included_setters = (scope_data[scope][:includes] || []).reduce({}) do |res, scope_name|
          res[scope_name] = setters_for_scope(scope_name, scope_data)
          res
        end

        {}.merge(root_scope_setters)
          .merge(scope_setters)
          .merge(extended_setters)
          .merge(included_setters)
      end

      def extract_setters(scope, scope_data)
        scope_data[scope][:setters]
      end
    end
  end
end