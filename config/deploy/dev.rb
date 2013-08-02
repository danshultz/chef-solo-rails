ssh_options[:paranoid] = false

# Deploy the repository via copy to support local development
set(:deploy_via, :copy)


role(:rails_server) {
  ["192.168.24.100", :chef_attributes => chef_attributes_data]
}
role(:app, "192.168.24.100")
role(:web, "192.168.24.100")
role(:db, "192.168.24.100", :primary => true)


# Chef attribute data
set(:chef_attributes_data) {
  {
    "run_list" => [
      "recipe[baseline]",
      "recipe[rails_app::web]",
      "recipe[rails_app::database]",
      "recipe[rails_app::app]"
    ],

    "postgresql" => {
      "password" => {
        "postgres" => "thepassword"
      },
      "pg_hba" => [
        {
          "type" => "host",
          "db" => "all",
          "user" => "all",
          "addr" => "192.168.24.100/32",
          "method" => "md5"
        },
        {
          "type" => "host",
          "db" => "all",
          "user" => "all",
          "addr" => "127.0.0.1/32",
          "method" => "md5"
        }
      ]
    },

    # Rails app specific configuration
    "rails_app" => {
      "name" => "blog",
      "database" => {
        "user" => "blog",
        "password" => "secretepassword"
      }
    }
  }
}
