FROM ruby:2.3.0
RUN mkdir /app
WORKDIR /app
ADD Gemfile .
ADD Gemfile.lock .
RUN bundle install --without test
ADD . .
EXPOSE 80
CMD ["rackup", "-o", "0.0.0.0", "-p", "80"]
