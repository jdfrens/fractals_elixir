FROM elixir:1.7.4-alpine as build

RUN mix local.hex --force

WORKDIR /app
