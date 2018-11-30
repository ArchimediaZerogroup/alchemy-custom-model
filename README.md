# Alchemy::Custom::Model [WIP]
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'alchemy-custom-model'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install alchemy-custom-model
```

Then run the installer
```bash
bin/rails  alchemy_custom_model:install
```

## Usage

* Generate your model
** remember to append a column for language:
```ruby
        t.integer :language_id
```
* include the model decorator
```ruby

     include Alchemy::Custom::Model::ModelDecoration

```
* attach yours belongs_to relations to alchemy_elements
```ruby

    # For attachments, the foreign_key is the key defined in the model, can be omitted if it's standard Rails naming
    belongs_to :file, class_name: "Alchemy::Attachment", optional: true, foreign_key: :file_id
    global_id_setter :file

    # For Pictures
    belongs_to :picture, class_name: 'Alchemy::Picture', optional: true, touch: true
    global_id_setter :picture
```
* Generate your controller:
```ruby
    bin/rails g controller Admin::Posts
```
* inherit from Alchemy::Custom::Model::Admin::BaseController
* Create the routes (prepend it to alchemy routes and  alchemy_custom_model routes)
* Build the ability for your recipe:
```ruby
  class PostAbility
    include CanCan::Ability

    def initialize(user)
      if user.present? && (user.is_admin? or user.has_role?("editor"))
        can :manage, Post #model
        can :manage, :admin_posts #routes to the posts withouth _path
      end
    end

  end
```

* build the abilities in ad initializer Es: "menu_and_abilities.rb"
```ruby
    Alchemy::Modules.register_module({
                                         name: 'Posts', # custom name
                                         order: 2,
                                         navigation: {
                                             name: 'modules.posts',
                                             controller: '/admin/posts', #controller path
                                             action: 'index', #action
                                             icon: "question" # custom icon
                                         }
                                     })
    Alchemy.register_ability(PostAbility)
```

* Costruisci la form per il modello
```ruby

<%= base_form_container do %>
  <div class="form_in_page">
    <%= simple_form_for [:admin,@obj] do |f| %>
      <fieldset>

        <%= f.input :name %>
        <%= rich_text_editor(f, :description) %>
        <%= single_image_input(f, :picture) %>
        <%= single_attachment_input(f, :file) %>
...

```

* Per elementi come subobject seguire l'esempio di codice nei test che rivedono le varie opzioni
* Per modelli che si legano direttamente con componenti di alchemy è necessario utilizzare delle relazioni generiche che identificato il record:
```ruby
  belongs_to :picture, class_name: 'Alchemy::Picture', touch: true
  belongs_to :alchemy_file_instance, class_name: 'Alchemy::Picture', foreign_key: :picture_id #relazione generica per i files utilizzata nel volume di elfinder
```

## Development

git clone --recursive git@github.com:ArchimediaZerogroup/alchemy-custom-model.git

docker build -t alchemy_custom_image .

docker run -it -p3000:3000 --rm -v "$(pwd)":/app alchemy_custom_image bin/rails s -b 0.0.0.0

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
