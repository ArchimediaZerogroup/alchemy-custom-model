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
Alchemy.register_ability(CommentAbility)
