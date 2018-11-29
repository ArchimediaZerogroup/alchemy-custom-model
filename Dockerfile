FROM ruby:2.4.4-slim-jessie as base_image

ENV DEBIAN_FRONTEND noninteractive
ENV TZ 'Europe/Rome'

RUN gem install bundler --no-ri --no-rdoc

# build essential ci serve quando abbiamo gemme con comilazione nativa----sono 100MB in più nell'immagine
RUN apt-get update -qq && apt-get install -y -qq  --no-install-recommends \
    curl build-essential\
    imagemagick openssh-client \
    libmagickwand-dev git libsqlite3-dev \
    #
    #Timezone
    && echo $TZ > /etc/timezone \
    && apt-get install -y tzdata \
    && rm /etc/localtime \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    #
    # Pulizia finale della cache di apt
    && apt-get clean && rm -fr /var/lib/apt/lists/*

## Install node
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && apt-get install -y -qq --no-install-recommends nodejs yarn && rm -fr /var/lib/apt/lists/*

FROM base_image

RUN mkdir /tmp_app

WORKDIR /tmp_app

ADD Gemfile .
ADD Gemfile.lock .
RUN mkdir -p lib/alchemy/custom/model
ADD lib/alchemy/custom/model/version.rb lib/alchemy/custom/model/version.rb
ADD alchemy-custom-model.gemspec .

RUN bundle install


RUN mkdir -p /app/test/dummy

WORKDIR /app/test/dummy
ADD test/dummy/package.json .
ADD test/dummy/yarn.lock .

RUN yarn

RUN gem install annotate

EXPOSE 3000