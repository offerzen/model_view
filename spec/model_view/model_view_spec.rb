require 'spec_helper'
require 'pry'

describe ModelView do
  let(:dummy_class) { Class.new { extend ModelView } }
  let(:root_scope) { :__root__ }

  context "root scope" do
    describe :field do
      context "without a block" do
        it "adds the field to the root scope" do
          dummy_class.field :a_field

          scope_fields = dummy_class.scopes[root_scope][:fields]
          expect(scope_fields[:a_field]).to eq({args: {}, block: nil})
        end

        context "with arguments" do
          it "adds the field to the root scope" do
            dummy_class.field :a_field, {foo: 1}

            scope_fields = dummy_class.scopes[root_scope][:fields]
            expect(scope_fields[:a_field]).to eq({args: {foo: 1}, block: nil})
          end
        end

        context "with setter set to true" do
          it "adds the field and setter to the root scope" do
            dummy_class.field :a_field, {setter: true}

            scope_fields = dummy_class.scopes[root_scope][:fields]
            expect(scope_fields[:a_field]).to eq({args: {}, block: nil})

            scope_setters = dummy_class.scopes[root_scope][:setters]
            expect(scope_setters[:a_field]).to eq({args: {}, block: nil})
          end
        end
      end

      context "with a block" do
        it "adds the field to the root scope" do
          dummy_class.field :a_field { 1 + 1 }

          scope_fields = dummy_class.scopes[root_scope][:fields]

          expect(scope_fields[:a_field][:args]).to eq({})
          expect(scope_fields[:a_field][:block].call).to eq(2)
        end
      end
    end

    describe :fields do
      it "adds all the fields to the root scope" do
        dummy_class.fields :field_1, :field_2, :field_3

        scope_fields = dummy_class.scopes[root_scope][:fields]
        expect(scope_fields.keys).to eq([:field_1, :field_2, :field_3])
      end
    end

    describe :include_scope do
      it "raises an error" do
        expect { dummy_class.include_scope :a_field }.to raise_error "Root scope can not include another scope"
      end
    end

    describe :extend_scope do
      it "raises an error" do
        expect { dummy_class.extend_scope :a_field }.to raise_error "Root scope can not extend another scope"
      end
    end

    describe :setter do
      context "without a block" do
        it "adds the setter to the root scope" do
          dummy_class.setter :a_field

          scope_setters = dummy_class.scopes[root_scope][:setters]
          expect(scope_setters[:a_field]).to eq({args: {}, block: nil})
        end
      end

      context "with a block" do
        it "adds the seter to the root scope" do
          dummy_class.setter :a_field { 1 + 1 }

          scope_setters = dummy_class.scopes[root_scope][:setters]

          expect(scope_setters[:a_field][:args]).to eq({})
          expect(scope_setters[:a_field][:block].call).to eq(2)
        end
      end
    end

    describe :after_update do
      it "adds an after_update block" do
        dummy_class.after_update { |obj| obj.save }

        after_update = dummy_class.scopes[root_scope][:after_update]
        expect(after_update).to be_a(Proc)
      end
    end
  end

  context "within a scope" do
    describe :scope do
      it "creates a scope" do
        dummy_class.scope :a_scope {  }

        expect(dummy_class.scopes.keys).to include(:a_scope)
      end
    end

    describe :field do
      it "adds a field inside the scope" do
        dummy_class.scope :a_scope { field :foo }

        scope_fields = dummy_class.scopes[:a_scope][:fields]
        expect(scope_fields.keys).to include(:foo)
      end

      it "changes the current scope back to root" do
        dummy_class.scope :a_scope { field :foo }
        dummy_class.field :bar

        scope_fields = dummy_class.scopes[:a_scope][:fields]
        root_scope_fields = dummy_class.scopes[root_scope][:fields]

        expect(scope_fields.keys).to include(:foo)
        expect(root_scope_fields.keys).to include(:bar)
      end
    end

    describe :fields do
      it "adds all the fields to the current scope" do
        dummy_class.scope :foo_scope { fields :field_1, :field_2, :field_3 }

        scope_fields = dummy_class.scopes[:foo_scope][:fields]
        expect(scope_fields.keys).to eq([:field_1, :field_2, :field_3])
      end
    end

    describe :include_scope do
      context "given a single scope" do
        it "adds the scope to the current scope's includes" do
          dummy_class.scope :my_scope { include_scope :foo }
          expect(dummy_class.scopes[:my_scope][:includes]).to eq([:foo])
        end
      end

      context "given an array" do
        it "adds all the scopes to the current scope's includes" do
          dummy_class.scope :my_scope { include_scope [:foo, :bar] }
          expect(dummy_class.scopes[:my_scope][:includes]).to eq([:foo, :bar])
        end
      end

      context "given more than one scope" do
        it "adds all the scopes to the current scope's includes" do
          dummy_class.scope :my_scope { include_scope :foo, :bar }
          expect(dummy_class.scopes[:my_scope][:includes]).to eq([:foo, :bar])
        end
      end
    end

    describe :extend_scope do
      context "given a single scope" do
        it "adds the scope to the current scope's extends" do
          dummy_class.scope :my_scope { extend_scope :foo }
          expect(dummy_class.scopes[:my_scope][:extends]).to eq([:foo])
        end
      end

      context "given an array" do
        it "adds all the scopes to the current scope's extends" do
          dummy_class.scope :my_scope { extend_scope [:foo, :bar] }
          expect(dummy_class.scopes[:my_scope][:extends]).to eq([:foo, :bar])
        end
      end

      context "given more than one scope" do
        it "adds all the scopes to the current scope's extends" do
          dummy_class.scope :my_scope { extend_scope :foo, :bar }
          expect(dummy_class.scopes[:my_scope][:extends]).to eq([:foo, :bar])
        end
      end
    end

    describe :setter do
      context "without a block" do
        it "adds the setter to the root scope" do
          dummy_class.scope :my_scope { setter :a_field }

          scope_setters = dummy_class.scopes[:my_scope][:setters]
          expect(scope_setters[:a_field]).to eq({args: {}, block: nil})
        end
      end

      context "with a block" do
        it "adds the seter to the root scope" do
          dummy_class.scope :my_scope { setter :a_field { 1 + 1 } }

          scope_setters = dummy_class.scopes[:my_scope][:setters]

          expect(scope_setters[:a_field][:args]).to eq({})
          expect(scope_setters[:a_field][:block].call).to eq(2)
        end
      end
    end

  end

  describe :model do
    before do
      class MyModel

      end
    end

    it "adds an as_hash method to the model" do
      dummy_class.model MyModel

      expect(MyModel.new).to respond_to(:as_hash)
    end

    it "adds an as_hash method to the model that defers to the model view's as_hash method" do
      dummy_class.model MyModel
      instance = MyModel.new

      expect(dummy_class).to receive(:as_hash).with(instance, {})

      instance.as_hash({})
    end

  end

end
