from setuptools import setup
from Cython.Build import cythonize

setup(
    ext_modules=cythonize(["src/random_events/sigma_algebra.pyx"])
)
