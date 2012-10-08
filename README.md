# Slydell

Named after Bob Slydell (the Office Space "efficiency expert". This gem will help you track the time utilization of certain methods

## Installation

Add this line to your application's Gemfile:

    gem 'slydell'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install slydell

## Usage

```ruby
class MyHeavilyUsedClass
  include Slydell

  def run_job
    sleep 10
    run_some_long_code
  end
  track_utilization :run_job
end
```

This should report statistics to Statsd via the `$statsd` global using the github-statsd gem
TODO: Write more about the above

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
