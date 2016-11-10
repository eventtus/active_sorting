# ActiveSorting

## Status

[![Gem Version](https://img.shields.io/gem/v/activesorting.svg)](http://rubygems.org/gems/activesorting)
[![Build Status](https://travis-ci.org/eventtus/active_sorting.svg?branch=master)](https://travis-ci.org/eventtus/active_sorting)
[![Code Climate](https://codeclimate.com/github/eventtus/active_sorting/badges/gpa.svg)](https://codeclimate.com/github/eventtus/active_sorting)
[![Coverage Status](https://coveralls.io/repos/github/eventtus/active_sorting/badge.svg?branch=master)](https://coveralls.io/github/eventtus/active_sorting?branch=master)
[![Inline docs](http://inch-ci.org/github/eventtus/active_sorting.svg?branch=master)](http://inch-ci.org/github/eventtus/active_sorting)
[![security](https://hakiri.io/github/eventtus/active_sorting/master.svg)](https://hakiri.io/github/owahab/active_sorting/master)
[![GitHub issues](https://img.shields.io/github/issues/eventtus/active_sorting.svg?maxAge=2592000)](https://github.com/eventtus/active_sorting/issues)
[![Downloads](https://img.shields.io/gem/dtv/activesorting.svg)](http://rubygems.org/gems/activesorting)

Allows sorting Rails models using a custom field.

[Code Documentation](http://www.rubydoc.info/github/eventtus/active_sorting)

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

  `:order` sorting direction, can be one of `:asc` or `:desc`, defaults to __:asc__

  `:step` stepping value, only `integers` allowed, defaults to __500__

  `:scope` scopes, defines the `ActiveRecord` `scope` applied before calculating the `position` field value. Defaults to __[]__

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Please see CONTRIBUTING.md for details.

## Credits

[![Eventtus](http://assets.eventtus.com/logos/eventtus/standard.png)](http://eventtus.com)

Project is sponsored by [Eventtus](http://eventtus.com).
