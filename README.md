# Fractals

Generates escape-time fractals.

[![CircleCI](https://circleci.com/gh/jdfrens/fractals_elixir.svg?style=svg)](https://circleci.com/gh/jdfrens/fractals_elixir)

I'm blogging about this project at [Programming During Recess](http://www.programming-during-recess.net/).


## Blog Articles

* [I reboot my Elixir app](http://www.programming-during-recess.net/2016/05/29/fractals-in-elixir-rebooted/)
* [I process my output](http://www.programming-during-recess.net/2016/06/05/output-process-for-elixir-fractals/), tag: [`blog_2016_05_04`](https://github.com/jdfrens/mandelbrot/tree/blog_2016_05_04/elixir)
* [I plan for my processes](http://www.programming-during-recess.net/2016/06/12/processes-for-elixir-fractals/), tag: [`blog_2016_06_12`](https://github.com/jdfrens/mandelbrot/tree/blog_2016_06_12/elixir)
* [I produce a minimal viable Mandelbrot](http://www.programming-during-recess.net/2016/06/19/minimal-viable-mandelbrot/), tag: [`blog_2016_06_19`](https://github.com/jdfrens/mandelbrot/tree/blog_2016_06_19/elixir)
* [I implement color schemes](http://www.programming-during-recess.net/2016/06/26/color-schemes-for-mandelbrot-sets/), tag: [`blog_2016_06_26`](https://github.com/jdfrens/mandelbrot/tree/blog_2016_06_26/elixir)
* [I generate Julia set and burning ships](http://www.programming-during-recess.net/2016/07/03/mandelbrots-julias-and-burning-ships/), tag: [`blog_2016_07_03`](https://github.com/jdfrens/mandelbrot/tree/blog_2016_07_03/elixir)
* [I parse my params better](http://www.programming-during-recess.net/2016/07/17/better-params-parsing/), tag: [`blog_2016_07_17`](https://github.com/jdfrens/mandelbrot/tree/blog_2016_07_17/elixir)

## Installation

Clone, get deps, compile CLI, run QA tests, look at the pretty pictures.

```
$ git clone --recurse-submodules https://github.com/jdfrens/fractals_elixir.git
$ cd fractals_elixir
$ mix deps.get
$ cd apps/cli
$ MIX_ENV=prod mix escript.build
$ ./scripts/qa.sh
$ open images/*.ppm images/*.png
```

Checkout a tag to along with my blog post for that week:

```
$ git checkout tags/blog_2016_06_12 -b whatever_you_want
```

You can run the tests:

```elixir
# from the root of the project
$ mix deps.get
$ mix test
$ mix credo --strict
$ mix dialyzer
```

Older branches might have a `spec` task instead of `test`; they may also fail on the `credo` or `dialyzer` tasks,

## Generating Fractals

The `fractals` executable takes a list of fractal jobs separated by a space.  Each fractal job is a YAML file or a list
of YAML files separated by commas.  Within a job, each YAML file overrides the previous one; overriding only happens at
the top level (if two files override the `:output` setting, the second one wins).

See the example YAML files in `inputs`.

* `inputs/data` handles the fractal itself and how to color it.  (This is a submodule, pulling in https://github.com/jdfrens/fractals_data.)
* `inputs/engine` sets up the engine that will generate the fractal (e.g., a single-process pipeline, a `GenStage`
  pipeline, etc,).
* `inputs/output` provides the image (e.g., size) and output (e.g., PPM or PNG) settings.

```
$ cd apps/cli
$ ./fractals ../../inputs/data/burningship/burningship-line-blue.yml,../../inputs/engines/stage_100.yml,../../inputs/outputs/ppm.yml
# bunch of output, then:
finished images/burningship-line-blue.png
ALL DONE!
Have a nice day.
$ open images/burningship-line-blue.png
```
