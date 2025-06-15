# f2

#### __f*ck the fascists.__

## Ethics

For a complete guide on how to ethically and morally approach this problem space, see the [ethics.md](docs/ethics.md) file. In general, we must remember that this system is a weapon. Like any weapon, it can be used for moral good or ethical evil, and it is up to us to decide how we will use it.

We are going to ask people to voluntarily surrender their sensitive data to us. We will use it to identify people at places & times, use it to build better models for facial recognition, use it to run search engine queries, and all kinds of other correlary tasks. Is this ethical?

Is it ethical that governments like the United States, China, Russia, and others use technologies like this to track and control their citizens?

Is it ethical that corporations like Facebook, Google, and Amazon use technologies like this to track and control their customers?

I don't believe it is. I believe it is imperative that we give the people the power to fight back. However we must not fall into the trap of capitalism and surveillance. We are not here to watch the people, but to empower them to watch out for each other.

This system is a weapon and we must approach and treat it with the respect it deserves.

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
* [`supabase-cli`](https://supabase.com/docs/guides/cli/installation): for pushing any necessary functions

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

There are also code generators that are needed for the backend services as well. For example, to generate any necessary protocol buffers, you will need `protoc`, the various `protoc-gen-*` plugins, and `buf`. You can find more details in the backend readme.

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
