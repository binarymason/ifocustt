# Focus

### Dependencies

* If using blink:
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
