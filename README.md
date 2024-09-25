mini batches 

tune learning rate


```
ubuntu@158-101-17-123:~/bo/micrograd$ cat requirements.txt 
numpy
matplotlib
scikit-learn
ipykernel
torch
tqdm
gymnasium
torchvision
tensorboard
torch-tb-profiler
opencv-python
tqdm
gymnasium[atari]
gymnasium[accept-rom-license]
torchrl==0.3.0
tensordict==0.3.0
```

sudo usermod -aG video $USER
https://app.cachix.org/cache/cuda-maintainers#pull
```
{ pkgs ? import <nixpkgs> { 
  config = {
    allowUnfree = true;
    cudaSupport = true;
  };
} }:

pkgs.mkShell {
  buildInputs = with pkgs; with python3Packages; [
    python3
    numpy
    matplotlib
    scikit-learn
    ipykernel
    torch-bin
    tqdm
    gymnasium
    torchvision
    tensorboard
    torch-tb-profiler
    opencv4
    tqdm
    # tensordict
  ];
  shellHook = ''
  export DYLD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath [ pkgs.python3Packages.torch-bin ]}
  python3 -m venv .venv
  # activate the virtual environment
  source .venv/bin/activate
  pip install 'gymnasium[atari]'
  pip install 'gymnasium[accept-rom-license]'
  pip install gym-super-mario-bros==7.4.0
  pip install torchrl==0.3.0
  pip install tensordict==0.3.0
  '';
}
```
# micrograd

![awww](puppy.jpg)

A tiny Autograd engine (with a bite! :)). Implements backpropagation (reverse-mode autodiff) over a dynamically built DAG and a small neural networks library on top of it with a PyTorch-like API. Both are tiny, with about 100 and 50 lines of code respectively. The DAG only operates over scalar values, so e.g. we chop up each neuron into all of its individual tiny adds and multiplies. However, this is enough to build up entire deep neural nets doing binary classification, as the demo notebook shows. Potentially useful for educational purposes.

### Installation

```bash
pip install micrograd
```

### Example usage

Below is a slightly contrived example showing a number of possible supported operations:

```python
from micrograd.engine import Value

a = Value(-4.0)
b = Value(2.0)
c = a + b
d = a * b + b**3
c += c + 1
c += 1 + c + (-a)
d += d * 2 + (b + a).relu()
d += 3 * d + (b - a).relu()
e = c - d
f = e**2
g = f / 2.0
g += 10.0 / f
print(f'{g.data:.4f}') # prints 24.7041, the outcome of this forward pass
g.backward()
print(f'{a.grad:.4f}') # prints 138.8338, i.e. the numerical value of dg/da
print(f'{b.grad:.4f}') # prints 645.5773, i.e. the numerical value of dg/db
```

### Training a neural net

The notebook `demo.ipynb` provides a full demo of training an 2-layer neural network (MLP) binary classifier. This is achieved by initializing a neural net from `micrograd.nn` module, implementing a simple svm "max-margin" binary classification loss and using SGD for optimization. As shown in the notebook, using a 2-layer neural net with two 16-node hidden layers we achieve the following decision boundary on the moon dataset:

![2d neuron](moon_mlp.png)

### Tracing / visualization

For added convenience, the notebook `trace_graph.ipynb` produces graphviz visualizations. E.g. this one below is of a simple 2D neuron, arrived at by calling `draw_dot` on the code below, and it shows both the data (left number in each node) and the gradient (right number in each node).

```python
from micrograd import nn
n = nn.Neuron(2)
x = [Value(1.0), Value(-2.0)]
y = n(x)
dot = draw_dot(y)
```

![2d neuron](gout.svg)

### Running tests

To run the unit tests you will have to install [PyTorch](https://pytorch.org/), which the tests use as a reference for verifying the correctness of the calculated gradients. Then simply:

```bash
python -m pytest
```

### License

MIT



```
ubuntu@158-101-17-123:~/bo/micrograd$ pip freeze
absl-py==0.15.0
aiosqlite==0.19.0
annotated-types==0.6.0
anyio==4.1.0
appdirs==1.4.4
argon2-cffi==21.1.0
arrow==1.3.0
astunparse==1.6.3
async-lru==2.0.4
attrs==23.1.0
Automat==20.2.0
Babel==2.13.1
backcall==0.2.0
bcrypt==3.2.0
beautifulsoup4==4.10.0
beniget==0.4.1
bleach==4.1.0
blinker==1.4
bottle==0.12.19
Bottleneck==1.3.2
Brotli==1.0.9
cachetools==5.0.0
certifi==2020.6.20
cffi==1.15.0
chardet==4.0.0
charset-normalizer==3.3.2
click==8.0.3
cloud-init==23.3.3
colorama==0.4.4
comm==0.2.0
command-not-found==0.3
configobj==5.0.6
constantly==15.1.0
cryptography==3.4.8
ctop==1.0.0
cycler==0.11.0
dacite==1.8.1
dbus-python==1.2.18
debugpy==1.8.0
decorator==4.4.2
defusedxml==0.7.1
distlib==0.3.4
distro==1.7.0
distro-info==1.1+ubuntu0.1
docker==5.0.3
entrypoints==0.4
et-xmlfile==1.0.1
exceptiongroup==1.2.0
fastjsonschema==2.19.0
filelock==3.6.0
flake8==4.0.1
flatbuffers===1.12.1-git20200711.33e2d80-dfsg1-0.6
fonttools==4.29.1
fqdn==1.5.1
fs==2.4.12
future==0.18.2
gast==0.5.2
Glances==3.2.4.2
google-auth==1.5.1
google-auth-oauthlib==0.4.2
google-pasta==0.2.0
grpcio==1.30.2
h5py==3.6.0
h5py.-debian-h5py-serial==3.6.0
html5lib==1.1
htmlmin==0.1.12
httplib2==0.20.2
hyperlink==21.0.0
icdiff==2.0.4
idna==3.3
ImageHash==4.3.1
importlib-metadata==4.6.4
incremental==21.3.0
influxdb==5.3.1
iniconfig==1.1.1
iotop==0.6
ipykernel==6.7.0
ipython==7.31.1
ipython_genutils==0.2.0
ipywidgets==8.1.1
isoduration==20.11.0
jax==0.4.14
jaxlib==0.4.14
jdcal==1.0
jedi==0.18.0
jeepney==0.7.1
Jinja2==3.0.3
joblib==0.17.0
json5==0.9.14
jsonpatch==1.32
jsonpointer==2.0
jsonschema==4.20.0
jsonschema-specifications==2023.11.2
jupyter-console==6.4.0
jupyter-events==0.9.0
jupyter-lsp==2.2.1
jupyter-ydoc==1.1.1
jupyter_client==8.6.0
jupyter_collaboration==1.2.0
jupyter_core==5.5.0
jupyter_server==2.12.0
jupyter_server_fileid==0.9.0
jupyter_server_terminals==0.4.4
jupyterlab==4.0.9
jupyterlab-pygments==0.1.2
jupyterlab-widgets==3.0.9
jupyterlab_server==2.25.2
kaptan==0.5.12
keras==2.13.1
keyring==23.5.0
kiwisolver==1.3.2
launchpadlib==1.10.16
lazr.restfulclient==0.14.4
lazr.uri==1.0.6
libtmux==0.10.1
llvmlite==0.41.1
lxml==4.8.0
lz4==3.1.3+dfsg
Markdown==3.3.6
MarkupSafe==2.0.1
matplotlib==3.5.1
matplotlib-inline==0.1.3
mccabe==0.6.1
mistune==3.0.2
ml-dtypes==0.2.0
more-itertools==8.10.0
mpmath==0.0.0
msgpack==1.0.3
multimethod==1.10
nbclient==0.5.6
nbconvert==7.12.0
nbformat==5.9.2
nest-asyncio==1.5.4
netifaces==0.11.0
networkx==2.4
nose==1.3.7
notebook==6.4.8
notebook_shim==0.2.3
numba==0.58.1
numexpr==2.8.1
numpy==1.25.2
nvidia-ml-py3==7.352.0
oauthlib==3.2.0
odfpy==1.4.2
olefile==0.46
openpyxl==3.0.9
opt-einsum==3.3.0
overrides==7.4.0
packaging==21.3
pandas==1.3.5
pandas-profiling==3.6.6
pandocfilters==1.5.0
parso==0.8.1
patsy==0.5.4
pexpect==4.8.0
phik==0.12.3
pickleshare==0.7.5
Pillow==9.0.1
platformdirs==2.5.1
pluggy==0.13.0
ply==3.11
prometheus-client==0.9.0
prompt-toolkit==3.0.28
protobuf==4.21.12
psutil==5.9.0
ptyprocess==0.7.0
py==1.10.0
pyasn1==0.4.8
pyasn1-modules==0.2.1
pycodestyle==2.8.0
pycparser==2.21
pycryptodomex==3.11.0
pydantic==2.5.2
pydantic_core==2.14.5
pyflakes==2.4.0
Pygments==2.11.2
PyGObject==3.42.1
PyHamcrest==2.0.2
pyinotify==0.9.6
PyJWT==2.3.0
pyOpenSSL==21.0.0
pyparsing==2.4.7
pyrsistent==0.18.1
pyserial==3.5
pysmi==0.3.2
pysnmp==4.4.12
pystache==0.6.0
pytest==6.2.5
python-apt==2.4.0+ubuntu2
python-dateutil==2.8.2
python-debian==0.1.43+ubuntu1.1
python-json-logger==2.0.7
python-magic==0.4.24
pythran==0.10.0
pytz==2022.1
PyWavelets==1.5.0
PyYAML==5.4.1
pyzmq==25.1.2
referencing==0.31.1
requests==2.31.0
requests-oauthlib==1.3.0
rfc3339-validator==0.1.4
rfc3986-validator==0.1.1
rpds-py==0.13.2
rsa==4.8
scikit-learn==0.23.2
scipy==1.8.0
seaborn==0.12.2
SecretStorage==3.3.1
Send2Trash==1.8.2
service-identity==18.1.0
simplejson==3.17.6
six==1.16.0
sniffio==1.3.0
sos==4.5.6
soupsieve==2.3.1
ssh-import-id==5.11
statsmodels==0.14.0
sympy==1.9
systemd-python==234
tables==3.7.0
tangled-up-in-unicode==0.2.0
tensorboard==2.13.0
tensorflow==2.13.1
tensorflow-estimator==2.13.0
termcolor==1.1.0
terminado==0.13.1
testpath==0.5.0
threadpoolctl==3.1.0
tinycss2==1.2.1
tmuxp==1.9.2
toml==0.10.2
tomli==2.0.1
torch==2.0.1
torchvision==0.15.2
tornado==6.4
tqdm==4.66.1
traitlets==5.14.0
triton==2.0.0
Twisted==22.1.0
typeguard==4.1.5
types-python-dateutil==2.8.19.14
typing_extensions==4.8.0
ubuntu-advantage-tools==8001
ufoLib2==0.13.1
ufw==0.36.1
unattended-upgrades==0.1
unicodedata2==14.0.0
uri-template==1.3.0
urllib3==1.26.5
virtualenv==20.13.0+ds
visions==0.7.5
wadllib==1.3.6
wcwidth==0.2.5
webcolors==1.13
webencodings==0.5.1
websocket-client==1.2.3
Werkzeug==2.0.2
widgetsnbextension==4.0.9
wordcloud==1.9.2
wrapt==1.13.3
xlwt==1.3.0
y-py==0.6.2
ydata-profiling==4.6.3
ypy-websocket==0.12.4
zipp==1.0.0
zope.interface==5.4.0
ubuntu@158-101-17-123:~/bo/micrograd$ 
```