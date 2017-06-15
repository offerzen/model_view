require 'model_view/resolver'

module ModelView

  ROOT = :__root__

  def field(field_name, arg={}, &block)
    scope_name = @current_scope || ROOT
    add_field scope_name, field_name, arg, block
  end

  def fields(*fields)
    fields.flatten.each { |f| field f }
  end

  def scope(scope_name, &block)
    sym_scope_name = scope_name.to_sym
    add_scope(sym_scope_name)

    @current_scope = sym_scope_name
    instance_eval &block
    @current_scope = nil
  end

  def include_scope(*scope)
    raise Exception.new("Root scope can not include another scope") if @current_scope.nil? || @current_scope == ROOT
    scope.flatten.each { |s| @scopes[@current_scope][:includes] << s }
  end

  def extend_scope(*scope)
    raise Exception.new("Root scope can not extend another scope") if @current_scope.nil? || @current_scope == ROOT
    scope.flatten.each { |s| @scopes[@current_scope][:extends] << s }
  end

  def scopes
    @scopes
  end

  def as_hash(object, opts={})
    scope = opts[:scope] || ROOT
    context = opts[:context] || {}
    ModelView::Resolver.resolve(object, @scopes, scope , context)
  end

  def model(model_class)
    model_view_class = self
    model_class.class_eval do
      define_method(:as_hash) do |opts|
        model_view_class.as_hash(self, opts)
      end
    end
  end

  private

  def add_scope(scope_name)
    @scopes ||= {ROOT =>  {fields: {}, extends: [], includes: []}}
    @scopes[scope_name] = {fields: {}, extends: [], includes: []}
  end

  def add_field(scope, field_name, args, block)
    @scopes ||= {ROOT =>  {fields: {}, extends: [], includes: []}}
    @scopes[scope] ||= {fields: {}, extends: [], includes: []}
    @scopes[scope][:fields][field_name] = {args: args, block: block}
  end

end
