rm -f images/*

MIX_ENV=prod mix escript.build

./fractals \
  ../../inputs/data/burningship/burningship-line-blue.yml,../../inputs/engines/stage_100.yml,../../inputs/outputs/ppm.yml \
  ../../inputs/data/burningship/burningship-line-red.yml,../../inputs/engines/stage_100.yml,../../inputs/outputs/ppm.yml \
  ../../inputs/data/julia/julia-pruim2-random.yml,../../inputs/engines/stage_100.yml,../../inputs/outputs/ppm.yml \
  ../../inputs/data/burningship/burningship-line-blue.yml,../../inputs/engines/stage_100.yml,../../inputs/outputs/png.yml \
  ../../inputs/data/burningship/burningship-line-red.yml,../../inputs/engines/stage_100.yml,../../inputs/outputs/png.yml \
  ../../inputs/data/julia/julia-pruim2-random.yml,../../inputs/engines/stage_100.yml,../../inputs/outputs/png.yml
