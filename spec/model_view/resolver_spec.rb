require 'spec_helper'
require 'pry'

describe ModelView::Resolver do
  let(:scopes) do
    {
      __root__: {
        fields: {
          field1: {},
          field2: {},
          field3: {}
        },
      },
      scope1: {
        fields: {
          field4: {block: Proc.new { |obj| obj.field4 + obj.field1 }},
          field5: {},
          field6: {}
        },
      },
      scope2: {
        extends: [:scope1],
        fields: {
          field7: {block: Proc.new { |obj, counter| obj.field7 + counter}, args: {context: [:my_counter]}},
          field8: {},
          field9: {}
        },
      },
      scope3: {
        includes: [:scope1],
        fields: {
          field10: {},
          field11: {},
          field12: {}
        },
      }
    }
  end

  describe :fields_for_scope do

    context "on the root scope" do
      it "returns the root-level fields" do
        result = ModelView::Resolver.fields_for_scope(ModelView::ROOT, scopes)

        expect(result.keys).to include(*[:field1, :field2, :field3])
      end
    end

    context "on a scope" do
      it "returns the root-level fields and the scope fields" do
        result = ModelView::Resolver.fields_for_scope(:scope1, scopes)

        expect(result.keys).to include(*[:field1, :field2, :field3, :field4, :field5, :field6])
      end
    end

    context "on a scope extending another scope" do
      it "also includes the extended scope's fields" do
        result = ModelView::Resolver.fields_for_scope(:scope2, scopes)

        expect(result.keys).to include(*[:field1, :field2, :field3, :field4, :field5, :field6, :field7, :field8, :field9])
      end
    end

    context "on a scope including another scope" do
      it "includes the includes scope's fields under a namespace" do
        result = ModelView::Resolver.fields_for_scope(:scope3, scopes)

        expect(result.keys).to include(*[:field1, :field2, :field3, :field10, :field11, :field12, :scope1])
        expect(result[:scope1].keys).to include(*[:field1, :field2, :field3, :field4, :field5, :field6])
      end
    end

  end

  describe :resolve do
    before do
      class Dummy
        def field1() 1 end
        def field2() 2 end
        def field3() 3 end
        def field4() 4 end
        def field5() 5 end
        def field6() 6 end
        def field7() 7 end
        def field8() 8 end
        def field9() 9 end
        def field10() 10 end
        def field11() 11 end
        def field12() 12 end
      end
    end

    let(:instance) { Dummy.new }

    context "for the root scope" do
      it "returns the resolved root-scope fields" do
        res = ModelView::Resolver.resolve(instance, scopes)
        expect(res).to eq({field1: 1, field2: 2, field3: 3})
      end
    end

    context "fields with a block" do
      context "with an arity of one" do
        it "evaluates the block" do
          res = ModelView::Resolver.resolve(instance, scopes, :scope1)
          expect(res[:field4]).to eq(5)
        end
      end

      context "with an arity greater than one" do
        context "no context specified in the field arguments" do
          it "foo"

        end

        context "no a context specified in the field arguments" do
          let(:dummy_context) { {foo: 1, bar: 2, my_counter: 100} }
          it "injects the context into the proc" do
            res = ModelView::Resolver.resolve(instance, scopes, :scope2, dummy_context)
            expect(res[:field7]).to eq(107)
          end
        end

        it "evaluates the block" do
          res = ModelView::Resolver.resolve(instance, scopes, :scope1)
          expect(res[:field4]).to eq(5)
        end
      end
    end


  end
end