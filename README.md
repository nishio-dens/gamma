# Gamma

Database Synchronizer. Transfer data from one database to another easily.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'gamma'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install gamma

## Usage

### Dryrun

```
gamma dryrun --settings ./tmp/settings.yml --data ./tmp/data.yml
```

### Apply

```
gamma apply --settings ./tmp/settings.yml --data ./tmp/data.yml
```

### data.yml Example

```
- data:
    table:
      - "*"
    table_without:
      - "users"
      - "schema_migrations"
      - "ar_internal_metadata"
    mode: "replace"
    delta_column: "updated_at"
- data:
    table: "users"
    mode: "replace"
    delta_column: "updated_at"
    hooks:
      - column:
          name:
            - "email"
          scripts:
            - "hooks/mask_email.rb"
      - column:
          name:
            - "name"
          scripts:
            - "hooks/mask_name.rb"
      - row:
          scripts:
            - "hooks/image.rb"
```

### Hook Script Example

```
# $YourDir/hooks/mask_name.rb

class MaskName
  def execute(apply, column, value)
    value = "●●#{value[2..-1]}"
    value
  end
end

# $YourDir/hooks/image.rb

class Image
  def execute(apply, record)
    #
    # Copy image data from one storage to another
    #

    record
  end
end
```

### settings.yml Example

```
in_database_config:
  adapter: mysql2
  encoding: utf8
  database: real_database
  pool: 5
  host: localhost
  username: root
  password:
out_database_config:
  adapter: mysql2
  encoding: utf8
  database: sync_to_database
  pool: 5
  host: localhost
  username: root
  password:
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nishio-dens/gamma. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Gamma project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/nishio-dens/gamma/blob/master/CODE_OF_CONDUCT.md).
