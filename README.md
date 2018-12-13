# Forward Financing CLI

Forward Financing CLI!

## Installation

You can install this package with `homebrew` from https://github.com/ForwardFinancing/homebrew-formulas

`brew install ForwardFinancing/homebrew-formulas/ff`

## Setup
Make sure that your Heroku and Github credentials are stored `~/.netrc`.

If you have Heroku CLI installed, you should see your Heroku creds in this file already.

For Github access, you will have to generate an access token and store it as the `password` value in your `.netrc` file.


```bash
$ cat ~/.netrc
machine api.heroku.com
  login <your_email>@forwardfinancing.com
  password <your_heroku_access_token>
machine git.heroku.com
  login <your_email>@forwardfinancing.com
  password <your_heroku_access_token>
machine github.com
  login <your_github_username>
  password <your_github_access_token>
```
