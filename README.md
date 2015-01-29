https://ava-wildcard.herokuapp.com

## Context

We have a filtering system on most of our index pages. We provide the user with the ability to dynamically add filter options that
allow them to select a field to filter by (via dropdown) and an area to type in the filter criteria (via autocompleting tokenizer).
The tokenizer also allows for wildcard searches. The supported wildcard character is % which allows for 0 or more of any character.
So you can do “Cor%” to find “Corey”.

Sample Record:
```ruby
record = ApplicationRecord.first

record.name
#=> "Microsoft Word"

record.asset_id
#=> "123456789"
```

This means the below search terms should return the above asset:
* `"Microsoft %"`
* `"%Word%"`
* `"%123456789"`

## Problem

We have a case where two fields should be combined wherever the item is displayed. For instance, an **ApplicationRecord**'s `name`
and its `asset_id`. Users should be able to use the `asset_id` or `name` interchangeably in any tokenizer. The `name` and `asset_id`
should be displayed everywhere the `name` is displayed. This includes the index filter pages. As an added requirement, this
combined output should only be visible for users with certain roles – **AccountOwner** and **BcTeam**.

**NOTE:** We have a method to access a user's permissions:

```ruby
class User
  def see_asset_id?
    # permitted = ['AccountOwner', 'BcTeam']
    (roles & permitted).any?
  end
end
```

## Solution

#### Our first step will be to combine the fields' output if the current_user is authorized to do so.

The best way to combine these fields for viewing would be to use the [decorator pattern](https://en.wikipedia.org/wiki/Decorator_pattern).
This will be very easy to do with a decorator and the [little_decorator](http://hashrocket.com/blog/posts/little-decorator-gem-rails-model-decoration-in-42-lines) gem:

```ruby
class AssetDecorator < LittleDecorator
  def name
    if current_user.see_asset_id?
      "#{model.name} (#{model.asset_id})"
    else
      model.name
    end
  end
end
```

This will allow us to view the combined fields when rendering results, but we also want the JSON for our autocomplete API to return combined
fields as well. We can add the following `as_json` method:

```ruby
class AssetDecorator < LittleDecorator
  def name
    if current_user.see_asset_id?
      "#{model.name} (#{model.asset_id})"
    else
      model.name
    end
  end

  def as_json(options={})
    {id: model.id, name: name}
  end
end
```

Then in our views we can refer to the name property as normal:

```erb
<h1><%= decorate(@record).name %></h1>

to produce

<h1>Mircosoft Word</h1>

or

<h1>Microsoft Word (123456789)</h1>
```

#### Our second step will be to allow authorized users to search by multiple fields.

This one gets a little more complicated. Seeing that the current user can search by different fields depending on his roles, we need a way
to retrieve those authorized fields. That way an authorized user may search by a record's `name` *OR* `asset_id`, while an unauthorized user only
the `name` field.

In our search controller we have an action that responds with JSON for our autocomplete api to use:

```ruby
class SearchController < ApplicationController
  def name_autocomplete
    assets = ApplicationRecord.search_in_fields(allowed_fields, params[:q].downcase)
    render json: decorate(assets)
  end

  private

  def allowed_fields
    fields = [:name]
    fields << :asset_id if current_user.see_asset_id?
    fields
  end
end
```

For the sake of clarity our `allowed_fields` method is directly in the controller, but if want to use this functionality elsewhere, it would
be better to add this logic directly to our User model, given also the logic would be more complex.

As you can see in our `name_autocomplete` action, we've added a method (`search_in_fields`) that takes an array of fields and a search term to use against those
fields.

Then in our class method, we can search each field that was passed in for the occurance of our word:

```ruby
class ApplicationRecord < ActiveRecord::Base
  def self.search_in_fields(fields, word)
    field_filter_sql = fields.map { |f| "LOWER(#{f}) LIKE :word" }
    where(field_filter_sql.join(' OR '), word: word)
  end
end
```

This method will create a LIKE statement for each field allowed, and use the given word as the criteria.

Now if an authorized user types an `asset_id` into the `name` search field, our action will search against both (or multiple) fields.
