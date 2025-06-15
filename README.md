# f2

#### __f*ck the fascists.__

## Repo Architecture

* [backend-src](./backend-src): Backend Rust & Typescript code used for the backend services.
* [frontend-src](./frontend-src): Frontend React Native & Expo code used for the frontend services.
* [docs](./docs): Documentation for the project.
* [ops](./ops): Operations & Infrastructure code used for the project.

## Bootstrapping Local Development

### Credentials

The only credential you will need is my Github Packages token, and that's to push the backend container images for right now. Later there will be a more sustainable option, but for now I'm trusting you to keep it safe and not abuse it please.

### Installation

You will need:

* [`terraform`](https://www.terraform.io/downloads.html): for managing the infrastructure (opentofu prolly won't work)
* [`overmind`](https://github.com/DarthSim/overmind): to connect to backend services sanely
* [`lima`](https://github.com/lima-vm/lima): for running the backend services
* [`docker`](https://docs.docker.com/get-docker/): for building the backend services
* [`rust`](https://www.rust-lang.org/tools/install): for building the backend services
* [`nvm`](https://github.com/nvm-sh/nvm) (and Node 22): for building the fronend services
* [`Expo`](https://expo.dev/): for compiling and running the frontend services
* [`xcode`](https://developer.apple.com/xcode/): for running the frontend services on iOS (can use a standalone device if you have windows/linux)
* [`yarn`](https://yarnpkg.com/getting-started/install): for building the frontend services

I have a few aliases that I use to save myself a whole lot of typing:

```sh
alias kctl='kubectl'
alias lctl='limactl'
alias tf='terraform'
```

So if you see my shorthand `kctl`, `lctl`, or `tf`, you know what I'm talking about.

### Bootstrapping

Bootstrapping takes place in two separate places: the backend and the frontend. The backend is Supabase + Rust microservices running in a Kubernetes cluster. The frontend is Expo + React Native.

#### Backend

I designed this to be as simple and straightforward as possible. Here are the steps to get started:

```sh
# clone
git clone git@git.sr.ht:~siennathesane/f2.git
cd f2

# boot the VM
cat k3s.yml | lctl create --name k3s -
lctl start k3s
# you might need to modify your KUBECONFIG but it will tell you what you do.
# i use k3s exclusively these days so i just have mine configs hardcoded,
# ymmv

# boot everything
cd ops/k3s
./bootstrap.sh dev
```

That will completely bootstrap the entire backend. If for some reason terraform fails, just run `./bootstrap.sh dev` again. If that doesn't work, just ping me on Discord.

#### Frontend

This is a fairly standard Expo app.

```sh
cd frontend-src

# install the deps
yarn install

# start the dev server
yarn start
```

Then you can choose to run the app on your device, in the Expo Go app on your phone, or the browser.

## Connecting to Everything

The absolute easiest way to connect to the backend is to use `overmind`. It will handle all of the backend service connections for you. In a separate terminal, run `overmind start -r all` to start the port forwarding.

The Supabase dashboard will be available at [http://localhost:3000](http://localhost:3000), and the backend data models will all be available at [http://localhost:8080/rest/v1/](http://localhost:8080/rest/v1/).

Again, if you get stuck, feel free to reach out to me on Discord :)

Happy coding!
