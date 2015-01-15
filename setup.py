from setuptools import setup

setup(
    name='{{ package_name }}',
    version='{{ package_version }}',
    packages=('{{ package_name }}',),
    url='https://github.com/{{ github_user }}/{{ repo_name }}',
    license='MIT',
    author='{{ author_name }}',
    author_email='{{ author_email }}',
    install_requires=[
        {{ install_requires }}
    ],
    tests_require=[
        {{ tests_require }}
    ],
    description=(
        {{ short_description }}),
    classifiers=(
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.6',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.2',
        'Programming Language :: Python :: 3.3',
        'Programming Language :: Python :: 3.4',
        'Programming Language :: Python :: Implementation :: CPython',
        'Programming Language :: Python :: Implementation :: PyPy'))
