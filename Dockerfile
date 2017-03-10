FROM ruby:2.3.3
RUN gem install focus-cli
ENV HOME=/home
ENTRYPOINT ["focus"]
