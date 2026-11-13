default:
    @just --list

# Render the modules and examples, and check sizes, the fit and the snap
test:
    python3 tests/test_snapfit.py

# Render the README pictures into assets/
images:
    @mkdir -p assets
    openscad --render --colorscheme=Tomorrow --imgsize=400,400 --viewall --autocenter --camera=0,0,0,60,0,30,60 -o assets/self_connecting_snap.png examples/self_connecting_snap.scad
    openscad --render --colorscheme=Tomorrow --imgsize=400,400 --viewall --autocenter --camera=0,0,0,60,0,30,60 -o assets/pcb_feet_tpu.png examples/pcb_feet_tpu.scad
    openscad --render --colorscheme=Tomorrow --imgsize=400,400 --viewall --autocenter --camera=0,0,0,75,0,0,80 -o assets/stacked_pair.png examples/stacked_pair.scad
