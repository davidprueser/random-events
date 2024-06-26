from setuptools import setup
from Cython.Build import cythonize

setup(
    # use 'python setup.py build_ext --inplace' to compile the .pyx files
    ext_modules=cythonize(["src/random_events/interval.pyx", "src/random_events/sigma_algebra.pyx"])
)
