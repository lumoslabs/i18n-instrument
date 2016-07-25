# i18n-instrument
Instrument calls to I18n.t in Ruby and JavaScript in your Rails app.

## Installation

Add it to your Gemfile:

```ruby
gem 'i18n-instrument', require: 'i18n/instrument'
```

## The Problem

Platforms like iOS and Android make it easy to tell which of your localization strings are currently in use - just do a bit of grepping or run a script and voilà! Once you've identified them, you can remove any unused, crufty strings from your translation files and move on with your life.

Due to Ruby's dynamic nature and the fact that you can never tell what Rails is actually doing, identifying unused strings is much more difficult. The static analysis that worked so well with iOS and Android projects won't work for your Rails app.

Consider this ERB template. It lives in app/views/products/index.html.erb:

```HTML+ERB
<div class="description">
  <%= I18n.t('.description') %>: <%= @product.description %>
</div>
```

Under the hood, the i18n gem (which provides Rails' localization implementation) fully qualifies `.description` into `products.index.description`. Because this qualification is done at runtime, static analysis (i.e. grepping) won't be able to identify all the strings your app is currently using.

The problem is compounded by the fact that the key you pass to `I18n.t` is just a string, and can therefore be generated in any way the Ruby language allows, for example:

```HTML+ERB
<div class="fields">
  <% @product.attributes.each_pair do |attr, value|
    <div class="<%= attr %>">
      <%= I18n.t(".#{attr}") %>: <%= value %>
    </div>
  <% end %>
</div>
```
First of all, I sincerely hope you never write code like this - it's probably bad practice to loop over *all* the attributes in your model and print them out (security blah blah blah). Hopefully my example illustrates the problem however - namely that the `I18n.t` method can accept any string, including string variables, interpolated strings, and the rest. Unless your static analyzer is very clever, it won't be able to tell you which of your localization strings are currently being used.

## Ok, so what should I do about it?

So glad you asked.

The only foolproof way to collect information about the localization strings your app is using is during runtime. This gem, i18n-instrument, is capable of annotating calls to `I18n.t` in Ruby/Rails and Javascript (provided you're using the capable [i18n-js gem](https://github.com/fnando/i18n-js)). Whenever one of these methods is called, i18n-instrument will fire the `on_record` callback and pass you some useful information. From there, the possibilities are endless. You could log the information to the console, write it down somewhere useful, save it to a database, you name it.

## Callbacks

* **`on_lookup(key : String, value : String)`**: Fired whenever `I18n.t` is called. Yields the localization key (i.e. `es.products.index.description`) and the corresponding translation string.

* **`on_record(params : Hash)`**: Similar to `on_lookup` but comes with a bunch of useful information.

  The `params` hash contains the following keys (all values are strings):
  
  * **`controller`**: the controller that served the request.
  * **`action`**: the action that served the request.
  * **`trace`**: the filename and line number from the first application stack frame, i.e. the place in your code `I18n.t` was called.
  * **`key`*: the localization key.
  * **`source`**: either "ruby" or "javascript".
  * **`locale`**: the value of `I18n.locale` in Ruby or Javascript.

* **`on_error(e : Exception)`**: Fired whenever an error occurs. The default behavior is to re-raise the exception. You may want to add your own exception handling callback so your app doesn't crash. See the configuration section below for details.

* **`on_check_enabled() : Boolean`**: Fired on every lookup. The return value must be `true` if the lookup should be recorded and `false` otherwise. The default behavior is to look for the existence of a file named config/enable\_i18n\_instrumentation. If the file exists, `I18n.t` calls are recorded. If not, calls are not recorded.

## Configuration

i18n-instrument is a piece of Rack middleware. It sits in between the Internet and your Rails app. You can configure it any time before your app is finished booting. I'd suggest doing it in a Rails initializer, for example config/initializers/i18n\_instrument.rb:

```ruby
I18n::Instrument.configure do |config|
  # The first stack trace line that begins with this string will be passed to
  # `on_record` as the `trace` value. Defaults to `Rails.root`.
  config.stack_trace_prefix = 'custom/path/to/app'
  
  # The URL you want your app to send js instrumentation requests to. Defaults
  # to '/i18n/instrument.json'.
  config.js_endpoint = '/my_i18n/foo.json'

  # all of the callback methods are available here
  
  config.on_record do |params|
    # print params to the rails log
    Rails.logger.info(params.inspect)
  end
  
  config.on_lookup do |key, value|
    puts "Looked up i18n key #{key} and got value #{value}"
  end
  
  config.on_error do |e|
    # report errors to our error aggregation service
    Rollbar.error(e)
  end
  
  config.on_check_enabled do
    # always enable
    true
  end
end
```
Be careful not to call `I18n::Instrument.configure` more than once - doing so will replace any existing configuration you may have already done. Instead, try this:

```ruby
# replace any existing on_record behavior, but leave all other configuration intact
I18n::Instrument.config.on_record do |params|
  ...
end
```

## Javascript Land

Using i18n-instrument in Javascript is pretty straightforward - just include it in your application.js file:

```javascript
//= require i18n
//= require i18n/instrument
```
Make sure to include i18n/instrument ***after*** i18n. This is critical since i18n-instrument overrides i18n's `t` method.

Also, don't forget to enable Javascript instrumentation by adding this line, probably at the bottom of application.js:

```javascript
I18n.instrumentation_enabled = true
```

## Authors

* Cameron C. Dutro ([@camertron](https://github.com/camertron)) on behalf of Lumos Labs, Inc.

## License

Licensed under the MIT license.