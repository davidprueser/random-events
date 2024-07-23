import os
import sysconfig

from setuptools import setup, Extension
from Cython.Build import cythonize

setup(
    ext_modules=cythonize(["src/random_events/interval.pyx",
                           "src/random_events/sigma_algebra.pyx",
                           ],
                          language="c++",
                          language_level="3",
                          include_path=["src/random_events"], ),
)
