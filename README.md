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
#=> "Microsoft word"

record.asset_id
#=> "123456789"
```

This means the below search terms should return the above asset:
* `"Microsoft %"`
* `"%Word%"`
* `"%123456789"`

## Problem

We have a case where two fields should be combined wherever the item is displayed. For instance, an ApplicationRecord's name
and its asset_id. Users should be able to use the asset_id or name interchangeably in any tokenizer. The name and asset_id should be displayed everywhere the name is displayed. This includes the index filter
pages. As an added requirement, this combined output to be visible for users with certain roles – AccountOwner and BcTeam.

**NOTE:** We have a method to access a user's permissions:

```ruby
class User
  def see_asset_id?
    # permitted = ['AccountOwner', 'BcTeam']
    (roles & permitted).any?
  end
end
```

### Our first step will be to combine the fields' output if the current_user is authorized to do so.

The best way to combine these fields for viewing would be to use the [decorator pattern](https://en.wikipedia.org/wiki/Decorator_pattern).
This will be a very easy to do with a decorator and the `little_decorator` gem:

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
fields as well. We can add the following method as well:

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

### Our second step will be to allow authorized users to search by multiple fields.

## Solution
