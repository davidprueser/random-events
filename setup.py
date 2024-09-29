import os
import sysconfig

from setuptools import setup, Extension
from Cython.Build import cythonize


# Define the source directory
src_dir = os.path.join('src', 'random_events')

root_dir = os.getcwd()

# List of source files for the extensions
sigma_algebra_sources = [
    os.path.join(src_dir, 'sigma_algebra.pyx'),      # Cython file
    os.path.join(src_dir, 'sigma_algebra_cpp.cpp'),  # C++ source file
]

interval_sources = [
    os.path.join(src_dir, 'interval.pyx'),           # Cython file
    os.path.join(src_dir, 'interval_cpp.cpp'),       # C++ source file
]

# Define the extensions with their dependencies
extensions = [
    Extension(
        name="random_events.sigma_algebra",
        sources=sigma_algebra_sources,
        language='c++',  # Tell it to use C++ compiler
        include_dirs=[src_dir],  # Include directory where your .h files are
    ),
    Extension(
        name="random_events.interval",
        sources=interval_sources,
        language='c++',
        include_dirs=[src_dir],  # Same here for headers
        extra_objects=[os.path.join(root_dir, 'build', 'lib.linux-x86_64-cpython-39', 'random_events',
                                    'sigma_algebra.cpython-39-x86_64-linux-gnu.so')],  # Ensure sigma_algebra is built first
    )
]

# Build the extensions
setup(
    name="random_events",
    ext_modules=cythonize(extensions),
    package_dir={'': 'src'},  # Tells setup to find packages in 'src'
)