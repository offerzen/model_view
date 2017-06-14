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

    describe :include_scope do
      it "adds the scope to the current scope's includes" do
        dummy_class.scope :my_scope { include_scope :foo }
        expect(dummy_class.scopes[:my_scope][:includes]).to eq([:foo])
      end
    end

    describe :extend_scope do
      it "adds the scope to the current scope's extends" do
        dummy_class.scope :my_scope { extend_scope :foo }
        expect(dummy_class.scopes[:my_scope][:extends]).to eq([:foo])
      end
    end
  end
end
