# Python PyPI Template

Template for quickly creating a new Python project and publishing it to [PyPI](https://pypi.python.org/pypi).


## Requirements

- [Python](https://www.python.org/)
- [Travis CI command-line tools](https://rubygems.org/gems/travis)
- [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/)
- [Git](http://git-scm.com/) and a [GitHub](https://github.com/) account
- [PyPI](https://pypi.python.org/pypi) account


## Initial Setup

1. Create a new, empty GitHub repo for your Python project. Search PyPI to find a name that doesn't exist!
2. Enable your repo in:
    - [Travis CI](https://travis-ci.org) for building, testing, and publishing to PyPI;
    - [Code Climate](https://codeclimate.com) for code metrics; and
    - [Coveralls](https://coveralls.io) for code coverage.
3. Clone your repo locally.
4. [Make sure you have `user.name` and `user.email` set in git](https://help.github.com/articles/setting-your-username-in-git/).
5. Clone this template repo locally and copy `populate.ini`, `populate.py`, and `template/` into your new repo.
6. Edit `populate.ini` and fill out the appropriate info for your project.
7. Commit.
8. Run `populate.py` to populate all templated files and filenames. This will delete all files useful only for the template, including itself. If something doesn't work out, you can always revert to commit you made in the previous step.
9. Add your encrypted PyPI password to `.travis.yml` by running:

        travis encrypt --add deploy.password

10. Commit.

At this point, your library should be empty, but all set up. Let's test it out!


## Local Tests

Docker, Compose, and [Tox](https://tox.readthedocs.org/en/latest/) are used to approximate the environment that Travis CI, Code Climate, and Coveralls all run when you push. This will allow you to test your code against multiple versions of Python (2.6, 2.7, 3.3, 3.4, 3.5, 3.6, PyPy, and PyPy3) locally before pushing it or even committing it.

To run everything (this will take a while the first time you run it, but subsequent runs will be quick):

```
$ docker-compose build && docker-compose up
```

To run against a single environment (e.g., Python 3.4):

```
$ docker-compose build && docker-compose run tox tox -e py34
```


## PyPI Deployment

Travis CI will deploy a new version of your package to PyPI every time you push a tag of any name to any branch. My typical process for making changes is something like this:

1. Made some code changes, and [update the version number](http://semver.org/) in `setup.py`.
2. Test the changes locally (e.g., `docker-compose build && docker-compose up`). See previous section.
3. Commit.
4. Push your changes; make sure Travis CI succeeds.
5. Tag the successful commit with the newly-updated version (e.g., `git tag 1.0.2`).
6. Push the tag (e.g., `git push origin 1.0.2`).

Then sit back and wait for Travis CI to push your new package version to PyPI!
