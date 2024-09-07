
# DB connection
System.put_env("DB_USERNAME", "postgres")
System.put_env("DB_PASSWORD", "postgres")
System.put_env("DB_HOSTNAME", "localhost")
System.put_env("DB_DATABASE_DEV", "argument_dev")
System.put_env("DB_DATABASE_TEST", "argument_test")

# Secret Key Base
System.put_env("SECRET_KEY_BASE", "y9O3lJtghMXMH8BXdLubYuVhkxEbT4LZ6tslg4WAGJNmNzf+cZRa5g/7ykDuHaCX")

# Phoenix Settings
#System.put_env("PHX_HOST", "hexcells.com")
#System.put_env("PORT", "4000")
