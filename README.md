# Hello!

Here are some textbooks created by [openstax.org](http://openstax.org) that have been converted into GitHub repositories so you can **derive your own copy** (aka [Fork](https://help.github.com/articles/fork-a-repo/)), **suggest edits** (aka [Pull Request](https://help.github.com/articles/proposing-changes-to-a-project-with-pull-requests/)), or **errata reporting** in the text (aka Issues) using tools GitHub provides.

# The Books

The "canonical" version of the books are in [openstax.org](http://openstax.org) and these repositories are mirrors of those versions. These books are licensed CC-BY (or CC-BY-SA) so you can customize them for your course!

- [Algebra and Trigonometry](https://github.com/philschatz/algebra-trigonometry-book)
- [Anatomy and Physiology](https://github.com/philschatz/anatomy-book)
- [Astronomy](https://github.com/philschatz/astronomy-book)
- [Biology](https://github.com/philschatz/biology-book)
- [Concepts of Biology](https://github.com/philschatz/biology-concepts-book)
- [Calculus](https://github.com/philschatz/calculus-book) (CC-BY-SA)
- [Chemistry](https://github.com/philschatz/chemistry-book)
- [Economics](https://github.com/philschatz/economics-book)
- [Microbiology](https://github.com/philschatz/microbiology-book)
- [Physics](https://github.com/philschatz/physics-book)
- [Psychology](https://github.com/philschatz/psychology-book)
- [Precalculus](https://github.com/philschatz/precalculus-book)
- [Sociology](https://github.com/philschatz/sociology-book)
- [Statistics](https://github.com/philschatz/statistics-book)
- [US History](https://github.com/philschatz/us-history-book)

Each book repository contains a link at the top to view the book in a book reader.

# What do I need to know?

If you want to customize the books you will need to:

- create a GitHub account
- learn how to [Fork a Repository](https://help.github.com/articles/fork-a-repo/) (it's easy!)
- learn about Markdown, a wiki format (similar to what wikipedia uses)

If you want to view your custom book you will need to:

- do the steps above
- go to `http://${YOUR_GITHUB_USERNAME}.github.io/${THE_REPOSITORY_NAME}`

If you want to suggest edits (like typos or broken images) you will need to:

- learn about Pull Requests

If you want to let other people edit your version of the book you will need to:

- learn about GitHub permissions


# Generating the Books

**Note:** You can probably ignore this part

This repository also contains the code to update the GitHub repositories when Openstax updates the books

1. `./script/bootstrap` (Tested with OSX. Requires homebrew)
2. `./script/start`
  - or `./script/start anatomy-book` to generate just one of the books in `_config.yml`
