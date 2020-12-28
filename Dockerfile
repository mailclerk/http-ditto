FROM ruby:2.6.3

COPY app/Gemfile* /tmp/
WORKDIR /tmp
RUN bundle install

COPY app /app
WORKDIR /app
EXPOSE 4567

CMD ["bundle", "exec", "ruby", "app.rb", "-o", "0.0.0.0", "-p", "4567"]