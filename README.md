[![gem-version](https://badge.fury.io/rb/ifocustt.svg)](https://badge.fury.io/rb/ifocustt)
# ifocustt = "if focused, then that"

![one-does-not-simply-focus](./assets/focus.jpg)

## Installation

```
gem install ifocustt
```

## What is ifocustt? :computer::zap:

`ifocustt` gives you a single command: `focus`.  The beauty is what can happen next.  You can specify any [actions](./lib/focus/actions), arguments and configuration settings you want in a `.focus.yml` file in either your project or home directory and they will be evaluated whenever you need to `focus`.

## Getting the most out of your time

Sometimes we don't realize how many things we would like to have during `focus` time.

Examples of what you might like when you are focusing...

* POST working time to JIRA

* Disable Mac Notification Center

* Update Slack presence to away

* Run arbitrary shell command

* Change a [blink(1)](https://blink1.thingm.com/) to one color when you are focusing and another when you are free.

## Usage

```
Usage: focus [options]
    -d, --daemonize                  Allow focus to be forked to the background
    -h, --help                       Prints this help
    -m, --minutes=MINUTES            How many minutes to focus.
    -t, --target=TARGET              Specify what you are focusing on
        --verbose                    Run focus with more verbose STDOUT
    -v, --version                    Prints version
```

## How does it work?

 Here's an example of a `~/.focus.yml` file:

```
---
actions:
  - OnFocus:
    - ChangeSlackPresence:
        presence: "away"

  - OnBreak:
    - RunShellCommand:
        command:  "say time to take a break"

  - Cleanup:
    - ChangeSlackPresence:
        presence: "auto"
    - PostWorkLogToJira:

config:
  focus_history_file: "~/.focus_history"
  jira_url: "https://jira-instance.atlassian.net/rest/api/latest"
  jira_username: "myusername"
  jira_password: "mypassword"
```
What happens when you run `focus` with the `~/.focus.yml` file above:

- `OnFocus`, it will immediately run the `ChangeSlackPresence` action with the arguments `{ presence: away }`
- It will sleep for the amount of focus time (defaults to 25 minutes)
- `OnBreak`, it will evaluate `RunShellCommand` and tell you to take a break!.
- It will sleep for `20%` of whatever your focus time was.
- `Cleanup` is used for any actions to take place after focus time is complete.  Notice that `PostWorkLogToJira` does not require any arguments.
- Your focus session is complete!

**NOTE:** that environment variables can be used as configuration settings.  If you would prefer not to have `jira_password` in your `~/.focus.yml` file, it can be specified as an environment variable somewhere as `JIRA_PASSWORD`. If you want to source a particular file that contains secret environment variables, you can add that to your config block:

```
...

config:
  env_file: "~/.secrets"
```

## Contributing

Want to create an action? It's super easy.  Just create a class that inherits from `Action` in the [actions](./lib/focus/actions) directory named in a verb form and define a `perform` method. If you want to fail the action, the `fail_action!` is available for you. Here's a quick example:

```
module Focus
  class DoSomethingAwesome < Action
    def perform
      result = do_amazing_stuff
      fail_action!(error: "Something went wrong") unless passed?(result)
    end

    private

    def do_amazing_stuff
      # ...
    end

    def passed?(obj)
      # ...
    end
  end
end
```

Pull Requests welcome!

### Dependencies

See each [action](./lib/focus/actions) for dependencies.
