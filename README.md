![Tests](https://github.com/jefawks3/activerecord_cursor_pagination/actions/workflows/test.yml/badge.svg)

# ActiverecordCursorPagination

ActiveRecord plugin for cursor based pagination using a serialized representation of the pages to paginate your content.

The main advantage to cursor based pagination over the traditional (`limit` & `offset`) is that the cursors are not
impacted by changes to the query (i.e. new records or records that no longer fit the query conditions).

The advantage of `ActiverecordCursorPagination` over other gems is their is no requirement to define a row key (usually `id`) to sort
the records. This allows for more complex queries to include joins or subqueries, and for ordering to also include
table aliases or complex operations.

## Motivation

I needed a cursor pagination method that was key agnostic and where I can order the records in any method I wish;
including using complex queries or table aliases. This was especially important when building out user feeds.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord_cursor_pagination'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install activerecord_cursor_pagination

## The `cursor` Basics

By default, `ActiverecordCursorPagination` defaults to 15 results per page.

```ruby
# Imagine there are 60 *total* posts (at 10 results/page, that is 6 pages)
cursor = Posts.where(published: true)
  .order(published_at: :desc)
  .cursor(nil)

cursor.per_page         # => 10

# scoped to the whole query
cursor.scope_size       # => 60
cursor.scope_empty?     # => false
cursor.scope_any?       # => true
cursor.scope_one?       # => false
cursor.scope_many?      # => true

# scoped to the current page
cursor.size             # => 10
cursor.empty?           # => false
cursor.any?             # => true
cursor.one?             # => false
cursor.many?            # => true

# pagination
cursor.current_page     # => "serialized cursor..."
cursor.first_page?      # => true
cursor.last_page?       # => false
cursor.next_page?       # => true
cursor.next_page        # => "serialized cursor..."
cursor.previous_page?   # => false
cursor.previous_cursor  # => ""
```

To retrieve the next page of results, pass the next page cursor.

```ruby
cursor = Posts.where(published: true)
  .order(published_at: :desc)
  .cursor("next page serialized cursor...")

cursor.per_page         # => 10

# scoped to the whole query
cursor.scope_size       # => 60
cursor.scope_empty?     # => false
cursor.scope_any?       # => true
cursor.scope_one?       # => false
cursor.scope_many?      # => true

# scoped to the current page
cursor.size             # => 10
cursor.empty?           # => false
cursor.any?             # => true
cursor.one?             # => false
cursor.many?            # => true

# pagination
cursor.current_page     # => "serialized cursor..."
cursor.first_page?      # => false
cursor.last_page?       # => false
cursor.next_page?       # => true
cursor.next_page        # => "serialized cursor..."
cursor.previous_page?   # => true
cursor.previous_cursor  # => "serialized cursor..."
```

You can iterate through the current page of results.

```ruby
cursor.each { |record| /* do something */ }
cursor.each_with_index { |record, index| /* do something */ }
mapped = cursor.map { |record| /* do something */ }
mapped = cursor.map_with_index { |record, index| /* do something */ }
```

A custom number of results per page can be specified by passing the `per` option.

```ruby
cursor = Posts.where(published: true)
  .order(published_at: :desc)
  .cursor(nil, per: 50)
```

## PagerView Helpers

Lets image you have a pager view that displays one `Post` at a time and you have left and right errors to go to
the next or previous record.

```ruby
post = Post.find(10)

cursor = Posts.where(published: true)
  .order(published_at: :desc)
  .cursor(post, per: 1)

cursor.next_cursor_record       # => [Post] Next published post
cursor.previous_cursor_record   # => [Post] Previous published post
```

**Make sure to set `per` to `1` or you will get a `NotSingleRecordError`**

If no record can be found, `next_cursor_record` and `previous_cursor_record` will return `nil`.

## Configuration

Configure `ActiverecordCursorPagination` using the `setup` method.

```ruby
ActiverecordCursorPagination.setup do |config|
  config.secret_key = 'your super secret key'
  config.serializer = YourCustomSerializer
end
```

## Custom Cursor Serializer

To create a custom cursor serializer, you need to override `ActiverecordCursorPagination::Serializer`.
Call `secret_key` in your custom class to get the configured cursor key.

**If you secure your database with external ids, make sure to encrypt the tokens so you don't 
expose the internal database ids.**

For instance, to create a `JWT` serializer:

```ruby
class JwtCursorSerializer < ActiverecordCursorPagination::Serializer
  def deserialize(str)
    data = JWT.decode str,
                      secret_key,
                      true,
                      { algorithm: 'HS256' }

    data.first.symbolize_keys
  end

  def serialize(hash)
    JWT.encode hash, secret_key,'HS256'
  end
end
```

Make sure to configure `ActiverecordCursorPagination` by setting the `serializer` 
configuration option with your new serializer.

## Known Issues/Limitations

- There is no known public method to call to get the order values. Currently calls `order_values` to get a list of all order values in the current query scope.
- When using a sub query or `CASE` statement as an order value, you have to use single quote strings.

## Development

After checking out the repo, run `bin/setup` to install dependencies. 
Then, run `rake spec` to run the tests. 
You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Testing

Run `rake rspec` to run all the tests or you can run:
- `rake rspec [path]` to run all the tests in a given directory,
- or `rake rspec [file]` to run a specific file.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jefawks3/activerecord_cursor_pagination.

I hope that you will consider contributing to ActiverecordCursorPagination. 
You can contribute in many ways. For example, you might:
- add documentation and “how-to” articles to the README or Wiki.
- hack on ActiverecordCursorPagination itself by fixing bugs you've found in the GitHub Issue tracker or adding new features to ActiverecordCursorPagination.

When contributing to ActiverecordCursorPagination, we ask that you:
- let me know what you plan in the GitHub Issue tracker so I can provide feedback.
- provide tests and documentation whenever possible. It is very unlikely that I will accept new features or functionality into ActiverecordCursorPagination without the proper testing and documentation. When fixing a bug, provide a failing test case that your patch solves.
- open a GitHub Pull Request with your patches and I will review your contribution and respond as quickly as possible. 

Keep in mind that this is an open source project, and it may take me some time to get back to you. 
Your patience is very much appreciated.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
