# DEPRECATED [![No Maintenance Intended](http://unmaintained.tech/badge.svg)](http://unmaintained.tech/)

This repository is now deprecated and it will be available until 01.06.2021.

# Easy Flow 

`easy_branch`: A simple tool to create a Jira issue, a branch with the issue id and summary.

### Prerequisites

jq
curl
Jira key (https://id.atlassian.com/manage/api-tokens)

## easy_branch


### Getting Started

Export these variables with their proper values:

```
export JIRA_KEY=[key]
export JIRA_USER=[user]
export JIRA_SERVER=[org].atlassian.net
export JIRA_IN_PROGRESS_ID=get it from jira, default value if absent: 111
export JIRA_BRANCH_SEPARATOR="/" // optional, default is _ 
```

You might want to symlink the script:
```
ln -s ~/easy-flow/easy-flow.sh easy-flow
```

Source it:
```
source easy-flow 
```

use it:
```
easy_branch this is a test summary
```

and add to your `.bashrc` or `.zshrc` and maybe alias for short:

```
export JIRA_KEY=...
export JIRA_USER=[user]
source easy-flow
alias eb=easy_branch
```

Most of the times you'll want to have the squad by default (and maybe a label?)
```
alias eb="easy_branch -l some_label"
```


### Parameters:
```
-t [Bug|Task(Default)|Story]
-d Description (optional)
-nb | --nobranch Does not create a branch
-l [label] (can be used mutiple times: -l label1 -l label_2 ...)
* summary
```
If you want to create a bug you can do (:
```
eb -t Bug this is a summary
```
or if you want descriptions:

```
eb -t Bug -d "this is the description" this is the summary
```

note that descriptions have quotes

## Jira Transition
Move tickets to "In Progress" :
```
to_in_progress [TICKET-ID]
```


