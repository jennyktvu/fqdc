<p>
    <a href="https://docs.calicolabs.com/python-template"><img alt="docs: Calico Docs" src="https://img.shields.io/badge/docs-Calico%20Docs-28A049.svg"></a>
    <a href="https://github.com/psf/black"><img alt="Code style: black" src="https://img.shields.io/badge/code%20style-black-000000.svg"></a>
</p>

# MyProject

![](https://github.com/calico/myproject)

## Overview

This is a template README file.  You can use 
[Markdown](https://guides.github.com/features/mastering-markdown/) to style
your text when viewed on GitHub.com.  You should edit this file to describe
your project and its code.  Don't forget to rename it from "MyProject"!

## Installation

* Clone the repo and `cd your_project`
* Create and activate a virtual environment

```bash
$ python3 -m venv venv
$ source venv/bin/activate
```

### Install core + development dependencies

Uses [`pip` editable mode (`-e`)](https://pip.pypa.io/en/stable/reference/pip_install/#editable-installs)

```bash
$ pip install -e .
```

## Usage 

Following are instructions for running the code:

```
python src/myproject.py
```

## Testing

Following are instructions for testing the code:

```
pytest test/
```

## License

See LICENSE

## Maintainers

See .github/CODEOWNERS
