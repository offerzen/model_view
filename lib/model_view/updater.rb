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

        after_update = after_update_for_scope(scope, scopes)
        after_update.call(obj) if after_update
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

      def after_update_for_scope(scope, scopes)
        extended_scopes = scopes[scope][:extends] || []
        first_extended_after_update = extended_scopes.reduce(nil) do |res, s|
          res || extract_after_update(s, scopes)
        end

        extract_after_update(scope, scopes) ||
        first_extended_after_update ||
        extract_after_update(ModelView::ROOT, scopes)

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

      def extract_after_update(scope, scope_data)
        scope_data[scope][:after_update]
      end

    end
  end
end