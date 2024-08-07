# Contributing to Sage Swift Kit

We welcome contributions from the community! Whether you're fixing a bug, adding new features, or improving documentation, your help is greatly appreciated.

## Testing
If you're adding new features or fixing bugs, please write tests to cover your changes. Minimum coverage for new changes will be from 65%

## Versioning

We use [Semantic Versioning](https://semver.org/) for versioning. For the versions.

## Branching and Rebasing Strategy

To maintain a clean and readable project history, we use a rebasing strategy. Here are the steps to follow:

1. **Create a Feature Branch**
   - Always create a new branch for your work, based off the latest `main` branch.

2. **Keep Your Branch Updated**
   - Regularly rebase your branch with the latest `main` branch to keep it up to date.

3. **Interactive Rebase to Squash Commits**
   - Before submitting your pull request, use interactive rebase to squash your commits into a single commit.
   - This will open an editor with a list of your commits. Change `pick` to `squash` (or `s`) for all but the first commit. This combines the changes into a single commit.
   - Save and close the editor to complete the rebase.

4. **Force Push Your Branch**
   - After squashing your commits, force push your branch to your forked repository.

5. **Submit a Pull Request**
   - Go to the original repository and create a pull request. Provide a clear and detailed description of your changes.

Please avoid merging `main` into your feature branch. Instead, rebase your feature branch onto `main`.

## Naming branches

| Type        | Description                                                                                                 
| ----------- | ----------------------------------------------------------------------------------------------------------- |
| `feature:`  | Introduce a new feature                                                                                     |
| `fix:`      | A bug fix                                                                                                   | 
| `tests:`    | Writting tests                                                                                              |  

## Reporting Issues

If you find a bug or have a feature request, please open an issue on GitHub. When reporting an issue, please include:
- A clear and descriptive title.
- A detailed description of the problem or request.
- Steps to reproduce the issue, if applicable.
- Any relevant logs, screenshots, or other information.

## Coding Standards

To ensure a consistent codebase, we use [SwiftLint](https://github.com/realm/SwiftLint) to enforce coding standards and style guidelines. Please make sure your code complies with SwiftLint rules before submitting a pull request.

## Contributor License Agreement (CLA)

For contributors external to Sage, we require a CLA to be signed before we can accept your pull request. Please find links to the relevent documents below:

- [Individual CLA](cla/SAGE-CLA.docx)
- [Corporate CLA](cla/SAGE-CCLA.docx)
