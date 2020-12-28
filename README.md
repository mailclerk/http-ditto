# HTTP Ditto

Simple HTTP service to store and serve back web requests

### Running locally

Can run in docker with:

```
docker build --tag http-ditto .
docker run -e MAX_STORE_COUNT=10 -p 4567:4567 http-ditto
```

Can run without docker with:

```
cd app
bundle # Might have issues with bundler version
MAX_STORE_COUNT=10 bundle exec ruby app.rb # Port 4567
```

### Deploying

That this is not meant for any kind of production use and does not use a
robust webserver. With that provision:

### Sending requests

HTTP Ditto accepts GET, POST, PUT, PATCH, and DELETE requests at /store. Will
store any query parameters, any JSON in the body, or the body itself if
not parsable into JSON.

### Fetching requests

```
curl -vX POST http://localhost:4567/store -d '{"message":{"foo": 3, "bar": 3}}' --header "Content-Type: application/json"

curl -vX POST http://localhost:4567/store -d '{"event":{"foo": 3, "bar": 3}}' --header "Content-Type: application/json"

curl -vX POST http://localhost:4567/store -d '{"message":{"foo": 2, "bar": 3}}' --header "Content-Type: application/json"
```

- http://localhost:4567/fetch Will return all three (array)
- http://localhost:4567/fetch/latest Will return only the last one (object)
- http://localhost:4567/fetch/search?path=message.foo&target=3 Will return the 1st one (array)

If paths don't have a "." in them, they can also be used to match query parameters.