# ActiveSorting
[![Code Climate](https://codeclimate.com/github/owahab/active_sorting/badges/gpa.svg)](https://codeclimate.com/github/owahab/active_sorting)
[![Build Status](https://travis-ci.org/owahab/active_sorting.svg?branch=master)](https://travis-ci.org/owahab/active_sorting)
[![Coverage Status](https://coveralls.io/repos/github/owahab/active_sorting/badge.svg?branch=master)](https://coveralls.io/github/owahab/active_sorting?branch=master)
[![Inline docs](http://inch-ci.org/github/owahab/active_sorting.svg?branch=master)](http://inch-ci.org/github/owahab/active_sorting)
[![security](https://hakiri.io/github/owahab/active_sorting/master.svg)](https://hakiri.io/github/owahab/active_sorting/master)

Allows sorting Rails models using a custom field.

[Code Documentation](http://www.rubydoc.info/github/owahab/active_sorting)

## Requirements

Minimum requirements are:

1. Rails __4.0.0+__
2. Ruby __2.0.0+__


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activesorting'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activesorting

## Usage

Adds sorting support to Rails models.

To sort by a model field `position`:

    class Example < ActiveRecord::Base
      sortable :position
    end

You can customize the sorting behavior by
passing an options hash. The following keys are supported:

  `order` sorting direction, defaults to :asc
  `step` stepping value, defaults to 500
  `scope` scopes, defaults to []

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Please see CONTRIBUTING.md for details.

## Credits
