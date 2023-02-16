FROM ruby:3.2.0-slim-bullseye AS assets
LABEL maintainer="Nick Janetakis <nick.janetakis@gmail.com>"

WORKDIR /app

ARG UID=1000
ARG GID=1000

RUN bash -c "set -o pipefail && apt-get update \
  && apt-get install -y --no-install-recommends build-essential curl git libpq-dev \
  && curl -sSL https://deb.nodesource.com/setup_18.x | bash - \
  && curl -sSL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo 'deb https://dl.yarnpkg.com/debian/ stable main' | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update && apt-get install -y --no-install-recommends nodejs yarn \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean \
  && groupadd -g \"${GID}\" ocean \
  && useradd --create-home --no-log-init -u \"${UID}\" -g \"${GID}\" ocean \
  && mkdir /node_modules && chown ocean:ocean -R /node_modules /app"

USER ocean

COPY --chown=ocean:ocean Gemfile* ./
RUN bundle install

COPY --chown=ocean:ocean package.json *yarn* ./
RUN yarn install

ARG RAILS_ENV="production"
ARG NODE_ENV="production"
ENV RAILS_ENV="${RAILS_ENV}" \
    NODE_ENV="${NODE_ENV}" \
    PATH="${PATH}:/home/ocean/.local/bin:/node_modules/.bin" \
    USER="ocean"

COPY --chown=ocean:ocean . .

RUN if [ "${RAILS_ENV}" != "development" ]; then \
  SECRET_KEY_BASE=dummyvalue rails assets:precompile; fi

CMD ["bash"]

###############################################################################

FROM ruby:3.2.0-slim-bullseye AS app
LABEL maintainer="Nick Janetakis <nick.janetakis@gmail.com>"

WORKDIR /app

ARG UID=1000
ARG GID=1000

RUN apt-get update \
  && apt-get install -y --no-install-recommends build-essential curl libpq-dev vim \
  && rm -rf /var/lib/apt/lists/* /usr/share/doc /usr/share/man \
  && apt-get clean \
  && groupadd -g "${GID}" ocean \
  && useradd --create-home --no-log-init -u "${UID}" -g "${GID}" ocean \
  && chown ocean:ocean -R /app

USER ocean

COPY --chown=ocean:ocean bin/ ./bin
RUN chmod 0755 bin/*

ARG RAILS_ENV="production"
ENV RAILS_ENV="${RAILS_ENV}" \
    PATH="${PATH}:/home/ocean/.local/bin" \
    USER="ocean"

COPY --chown=ocean:ocean --from=assets /usr/local/bundle /usr/local/bundle
COPY --chown=ocean:ocean --from=assets /app/public /public
COPY --chown=ocean:ocean . .

ENTRYPOINT ["/app/bin/docker-entrypoint-web"]

EXPOSE 8000

CMD ["rails", "s"]
