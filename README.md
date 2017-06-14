# model_view
## Composable serialisation for models

ModelView let's you define views for your models in one place.

### Why ModelView?

At OfferZen, most of our rails models can be presented in al least two ways. For example, an Interview Request
is presented differently to a candidate than to a company. But, there are also a lot of fields that get presented
the same to both candidates and companies. We found ourselves duplicating a lot of our serialisation code in our
controllers and the code started to get out of hand.

ModelView works with Rails, but Rails is definitely not a requirement

### How to use ModelView

1) Include the gem in your gemfile
```ruby
gem "model_view", '~> 0.1'
```
2) Create a view class (we put these in `app/model_views`)

```ruby
class PersonView
  extend ModelView

end
```
3) Define fields

```ruby
field :name

field(:first_name) { |person| person.name.split(' ').first }

field :is_current_user, context[:current_user] do |person, current_user|
  person == current_user
end
```
4) Let ModelView serialise an instance

```ruby
person = Person.find(1)
PersonView.as_hash(person, context: {current_user: current_user})
=> {
  name: "Billy Bob",
  first_name: "Billy",
  is_current_user: false
}
```

#### Scopes

Scopes allows you to create serialisation snippets that can be composed

Example:
```ruby
field :id

scope :demographics do
  field :name
  field(:first_name) { |person| person.name.split(' ').first }
  field(:last_name) { |person| person.name.split(' ').last }
end

scope :status do
  field :is_current_user, context[:current_user] do |person, current_user|
    person == current_user
  end
end

scope :all do
  extend_scope :demographics
  extend_scope :status
end
```

```ruby
person = Person.find(1)

PersonView.as_hash(person, {context: {current_user: current_user}})
=> {
  id: 1
}


PersonView.as_hash(person, {context: {current_user: current_user}, scope: :demographics})
=> {
  id:   1,
  name: "Billy Bob",
  first_name: "Billy",
  last_name: "Bob",
}

PersonView.as_hash(person, {context: {current_user: current_user}, scope: :all})
=> {
  id:   1,
  name: "Billy Bob",
  first_name: "Billy",
  last_name: "Bob",
  is_current_user: true
}
```
