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

The only foolproof way to collect information about the localization strings your app is using is during runtime. This gem, i18n-instrument, is capable of annotating calls to `I18n.t` in Ruby/Rails and Javascript (provided you're using the capable [i18n-js gem](https://github.com/fnando/i18n-js)). Whenever one of these methods is called, i18n-instrument will fire the `on_record` callback and pass you some useful information. From there, the possibilities are endless. You could log the information to the console, write it somewhere useful, save it to a database, you name it.

## Callbacks

* `on_lookup`

## Configuration

i18n-instrument is a piece of Rack middleware. It sits in between the Internet and your Rails app. To configure it, 