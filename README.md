https://ava-wildcard.herokuapp.com

## Context

We have a filtering system on most of our index pages. We provide the user with the ability to dynamically add filter options that
allow them to select a field to filter by (via dropdown) and an area to type in the filter criteria (via autocompleting tokenizer).
The tokenizer also allows for wildcard searches. The supported wildcard character is % which allows for 0 or more of any character.
So you can do “Cor%” to find “Corey”.

Sample Record:
```ruby
record = Asset.first

record.name
#=> "Microsoft word"

record.asset_id
#=> "123456789"
```

This means the below search terms should return the above asset:
`"Microsoft %"`
`"%Word%"`
`"%123456789"`

## Problem

We have a case where two fields should be combined wherever the item is displayed. For instance, an Application’s name
and its AssetID. Users should be able to use the AssetID or name interchangeably in any tokenizer. The Name and AssetID
should be displayed everywhere the name is displayed. This includes the index filter pages. As an added requirement,
this combined output to be visible for users with certain roles – AccountOwner and BcTeam.

## Solution



## Action
