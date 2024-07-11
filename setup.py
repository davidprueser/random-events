import os
import sysconfig

from setuptools import setup, Extension
from Cython.Build import cythonize

# os.environ["CC"] = "g++"  # Ensure using a C++ compiler
#
# extensions = [
#     Extension(
#         "interval",
#         sources=["src/random_events/interval.pyx",
#                  "src/random_events/sigma_algebra.pyx",
#                  # "src/random_events/simple_interval.h",
#                  ],
#         language="c++",
#         extra_compile_args=["-std=c++11"],
#         include_dirs=["src/random_events"],
#     )
# ]

setup(
    ext_modules=cythonize(["src/random_events/interval.pyx",
                                     "src/random_events/sigma_algebra.pyx",
                                     ],
                          language="c++",
                          language_level="3",
                          include_path=["src/random_events"],),
)