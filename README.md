# Intial Setup

    docker-compose build
    docker-compose run short-app rails db:setup && rails db:migrate

# To run the specs

    docker-compose -f docker-compose-test.yml run short-app-rspec

# To run migrations

    docker-compose run short-app rails db:migrate
    docker-compose -f docker-compose-test.yml run short-app-rspec rails db:test:prepare

# Run the web server

    docker-compose up

# Adding a URL

    curl -X POST -d "full_url=https://google.com" http://localhost:3000/short_urls.json

# Getting the top 100

    curl localhost:3000

# Checking your short URL redirect

    curl -I localhost:3000/abc

# Algorithm Used

1. Iterating over last short code in reverse order
2. If current character is not the last one then replacing it with next character from characters array and keeping the remaining characters as it is
3. If current character is last character from the characters array then replacing it with first character of characters array and checking the previous character
4. If first character of the last short code is last character of the characters array that means combination limit has reached and thus increasing the length by one
