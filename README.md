
# Script Bridge

These tools allow developers to edit Limfinity scripts on their local machines using an editor of their choice.

## Getting Started

### Prerequisites

* ruby - https://github.com/rbenv/rbenv
* bundler - http://bundler.io/
* git - https://git-scm.com/book/en/v1/Getting-Started-Installing-Git

### Installing

1. Clone this repo
  `git clone https://andyruro@bitbucket.org/andyruro/script_bridge.git`
2. Enter directory
  `cd script_bridge`
3. Install gems
  `bundle install`

### Configuration

Rename the configuration file in the config directory: `application.yml.org` to `application.yml`

The local output path should be a directory with a git repo.

#### Creating a git repo

```
mkdir lis32dev
cd lis32dev
git init
git remote add origin https://andyruro@bitbucket.org/andyruro/lis32dev.git
printf '%s\n' '# OS' '*/.DS_Store' '*.DS_Store' > .gitignore
git add .gitignore
git commit -m 'init'
git push -u origin master
```

### Usage

#### Pull

Pulls latest changes from LIMS onto your local machine and pushes it to git

`bundle exec ruby pull.rb`

#### Push

Allows you to push a specified branch to LIMS and git

`bundle exec ruby push.rb`

Enter the branch name and press enter


##### Example Workflow

Create new branch and checkout:
`git checkout -b my-new-branch`

Edit files and save

Add files to staging (individually or add all with '.')
`git add Helper\ Script/Script/Analyte.rb` or `git add .`

Check that your files are staged

`git status`

Commit changes

`git commit -m 'added feature x'`

Use script bridge push script

```
bundle exec ruby push.rb
Enter branch name
my-new-branch
```


#### Listen

Uses filewatcher to automatically push changes when a file is modified. (Note: only save one file at a time. Wait for sync to finish before saving again)

`bundle exec ruby listen.rb`

ctrl+c to quit


#### Comparing scripts between instances

Comparing some other instance with lis32dev:
```
git remote add lis32 https://andyruro@bitbucket.org/andyruro/lis32dev.git
git fetch lis32 master:lis32
git checkout lis32
git push --set-upstream origin lis32
```

Compare through bitbucket UI
