require 'spec_helper'
require 'pry'

describe ModelView::Updater do
  let(:scopes) do
    {
      __root__: {
        fields: {
          field1: {},
          field2: {},
          field3: {}
        },
        setters: {
          field1: {},
          field3: {block: Proc.new { |obj, data| obj.field3 = data + 2 }}
        },
        after_update: Proc.new { |obj| obj.save }
      },
      scope1: {
        fields: {
          field4: {block: Proc.new { |obj| obj.field4 + obj.field1 }},
          field5: {},
          field6: {}
        },
        setters: {
          field4: {block: Proc.new { |obj, data| obj.field4 = data }},
          field5: {},
          field6: {}
        }
      },
      scope2: {
        extends: [:scope1],
        fields: {
          field7: {},
          field8: {},
          field9: {}
        },
        setters: {
          field7: {}
        }
      },
      scope3: {
        includes: [:scope1],
        fields: {
          field10: {},
          field11: {},
          field12: {}
        },
        setters: {
          field10: {}
        }
      }
    }
  end

  describe :update do
    before do
      class Dummy
        attr_accessor *(1..12).map { |n| "field#{n}".to_sym }

        def save

        end
      end
    end

    let(:instance) { Dummy.new }

    context "for the root scope" do
      let(:data) { {field1: 1, field2: 2, field3: 2} }
      context "for a setter without a block" do
        it "sets the values with setters" do
          ModelView::Updater.update(instance, scopes, data)
          expect(instance.field1).to eq(1)
        end

        it "does not set the values without setters" do
          ModelView::Updater.update(instance, scopes, data)
          expect(instance.field2).to be_nil
        end

        it "uses a block to set the value, if available" do
          ModelView::Updater.update(instance, scopes, data)
          expect(instance.field3).to eq(4)
        end

        it "runs the after_update block, if provided" do
          expect(instance).to receive(:save)
          ModelView::Updater.update(instance, scopes, data)
        end
      end
    end

    context "on a scope" do
      it "includes the root level setters" do
        data = {field1: 1, field4: 4}
        ModelView::Updater.update(instance, scopes, data, :scope1)

        expect(instance.field1).to eq(1)
        expect(instance.field4).to eq(4)
      end
    end

    context "on a scope extending another scope" do
      it "also includes the extended scope's setters" do
        data = {field7: 7, field4: 4}
        ModelView::Updater.update(instance, scopes, data, :scope2)

        expect(instance.field7).to eq(7)
        expect(instance.field4).to eq(4)
      end
    end

    context "on a scope including another scope" do
      it "also includes the included scope's setters"
    end

  end
end