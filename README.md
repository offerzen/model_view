# model_view
## Composable serialisation for models

ModelView let's you define views for your models in one place.

### Why ModelView?

At OfferZen, most of our rails models can be presented in at least two ways. For example, an Interview Request
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

field :is_current_user, {context: current_user} do |person, current_user|
  person == current_user
end

field :type, constant: 'User'

field :person_name, alias_for: :name
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

#### 🐒-patching the model

ModelView can add a convenience method to the model class

Example
```ruby
class PersonModelView
  model Person
  field :id
end

p = Person.find 1

p.as_hash(context: {current_user: current_user})
=> {
  id: 1
}
```

When using ModelView in Rails, remember to add an initializer that requires your model views.

Example initializer:
```ruby
# require.rb
Dir["#{Rails.root}/app/model_views/*.rb"].each do |file|
  require File.basename(file, File.extname(file))
end
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

#### Updating models
`ModelView` can also be used to update models. This is achieved by creating setters.

The easiest way to create a setter is to set the `setter` flag to true when defining a field:
```ruby
field :name, setter: true
```

Setters can also be defined outside of the `field` macro:
```ruby
setter :name
```

Setters defined in this way are naive (`obj.send("#{field}=", value)`) and will not automatically call the `save` method on the model. See below on how to create an `after_update` hook.

Finally, for more complex updaters, a block can be passed:
```ruby
setter(:name) do |obj, name|
  first_name, last_name = name.split(" ")
  obj.first_name = first_name
  obj.last_name = last_name
  obj.save!
end
```

To avoid having to explicitly save the model in every block, one can define an `after_update` block:
```ruby
after_update { |obj| obj.save! }

field :telephone_number, setter: true
setter(:name) do |obj, name|
  first_name, last_name = name.split(" ")
  obj.first_name = first_name
  obj.last_name = last_name
end
```

Models can then be updated using ModelView.update:
```ruby
PersonView.update(person, {phone: "+123 456 7890"}, scope: :contact_details)
```
