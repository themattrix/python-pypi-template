#!/usr/bin/env python

import fnmatch
import os
from datetime import date
from subprocess import check_output
from os.path import abspath, dirname, join


this_dir = dirname(abspath(__file__))


def find_templated_files():
    for root, dirnames, filenames in os.walk(this_dir):
        for f in fnmatch.filter(filenames, '*.template'):
            yield join(root, f)


def find_templated_directories():
    for root, dirnames, filenames in os.walk(this_dir):
        for d in fnmatch.filter(dirnames, '{{ * }}'):
            yield join(root, d)


def get_author_email():
    return check_output(('git', 'config', 'user.email')).strip()


def get_author_name():
    return check_output(('git', 'config', 'user.name')).strip()


def get_copyright_years():
    return str(date.today().year)


def get_template_values():
    return dict(
        author_email=get_author_email(),
        author_name=get_author_name(),
        copyright_years=get_copyright_years())


if __name__ == '__main__':
    from pprint import pprint
    pprint(tuple(find_templated_files()))
    pprint(tuple(find_templated_directories()))
    pprint(get_template_values())
