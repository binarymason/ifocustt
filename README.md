# Focus

![example](./assets/example.png)

### Installation

```
gem install focus-cli
```

Or, add this to your Gemfile and run `bundle install`

```
gem "focus-cli"
```

### What is Focus?

Focus gives you a single command: `focus`.  The beauty is what can happen next.

You can specify multiple [actions](./lib/focus/actions) in a `.focus.yml` [file](./config/default.yml) in either your project or home directory and the will be run sequentially whenever you need to `focus`.


This is built with the [pomodoro technique](wikipedia.org/wiki/Pomodoro_Technique) in mind and defaults to 25 minute intervals.
If you want to see a log of your `focus` sessions, they are logged to `~/.focus_history`.

## Getting the most out of your time.

Sometimes we don't realize how many things we would like to have during `focus` time.

Examples of what you might like when you are focusing...

* Disable Mac Notification Center

* Update Slack presence to away

* Run arbitrary shell command

* Log JIRA working time

* Change a blink(1) to one color when you are focusing and another when you are free.

### Dependencies

* If using [blink(1):](https://blink1.thingm.com/)
```
npm install -g node-blink1-server

```


### How do you run focus when the `focus-cli` gem is not in your bundle?

The solution is to run within a Docker environment.
Add this function to your `~/.bashrc`:

```
focus(){
  docker run \
    -it \
    --rm \
    --add-host="localhost:10.0.2.2" \
    -v $(pwd):$(pwd) \
    -w $(pwd) \
    -v $HOME/:/home \
    -v $HOME/.docker:/root/.docker:ro \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -p 8754:8754 \
    -e "DOCKER_HOST_URL=$DOCKER_HOST" \
    binarymason/focus-cli "$*"
}
```
