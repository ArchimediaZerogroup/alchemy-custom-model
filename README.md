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



## Contributing
Contribution directions go here.

git clone --recursive git@github.com:ArchimediaZerogroup/alchemy-custom-model.git

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
