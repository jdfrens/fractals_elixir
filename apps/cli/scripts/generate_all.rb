#!/bin/env/ruby

args =
  Dir
    .glob("../../inputs/data/**/*.yml")
    .map { |f| "#{f},../../inputs/engines/stage_100.yml"}

exec("./fractals", *args)
