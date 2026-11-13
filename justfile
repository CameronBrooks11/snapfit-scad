default:
    @just --list

# Render the modules and examples, and check sizes, the fit and the snap
test:
    python3 tests/test_snapfit.py
