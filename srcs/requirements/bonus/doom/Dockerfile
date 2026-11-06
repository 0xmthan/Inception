# --- build stage: compile Chocolate Doom to WebAssembly ---------------------
FROM alpine:3.23 AS build

# Emscripten 4.0.11 is the release that expects exactly the LLVM (21) and
# binaryen (123) shipped by Alpine 3.23, so no prebuilt (glibc) emsdk is needed.
ARG EMSCRIPTEN_VERSION=4.0.11
ARG DOOM_WASM_COMMIT=65e0d3ae2ffa604155eebd96ed40da6567bd08f4

RUN apk add --no-cache \
        clang21 \
        lld21 \
        llvm21 \
        binaryen \
        nodejs \
        npm \
        python3 \
        git \
        make \
        autoconf \
        automake \
        libtool \
        pkgconf \
        bash \
        freedoom

# wasm-ld lives in /usr/bin, emscripten looks for it next to clang.
RUN ln -s /usr/bin/wasm-ld /usr/lib/llvm21/bin/wasm-ld \
    && git clone --depth 1 --branch "${EMSCRIPTEN_VERSION}" \
        https://github.com/emscripten-core/emscripten.git /opt/emscripten \
    && cd /opt/emscripten \
    && ./bootstrap \
    && printf "%s\n" \
        "LLVM_ROOT = '/usr/lib/llvm21/bin'" \
        "BINARYEN_ROOT = '/usr'" \
        "NODE_JS = '/usr/bin/node'" \
        > /opt/emscripten/.emscripten

ENV PATH="/opt/emscripten:${PATH}" \
    EM_CONFIG=/opt/emscripten/.emscripten \
    EM_CACHE=/opt/emcache

# cloudflare/doom-wasm: Chocolate Doom ported to the browser.
RUN git clone https://github.com/cloudflare/doom-wasm.git /src \
    && cd /src \
    && git checkout "${DOOM_WASM_COMMIT}"

WORKDIR /src

# Fixes for building the port with a modern toolchain:
#  boolean.patch   the same 4-byte boolean in every file. emscripten 4's
#                  websocket.h pulls in <stdbool.h>, which made boolean a
#                  1-byte bool in some files only and corrupted the game state.
#  visplane.patch  real room for the top[-1]/top[SCREENWIDTH] accesses that
#                  vanilla Doom makes past the end of its arrays.
COPY tools/boolean.patch tools/visplane.patch /tmp/
RUN git apply /tmp/boolean.patch /tmp/visplane.patch

# The port predates emscripten 4: rename the removed settings, drop the
# debug-only ones (SAFE_HEAP, source maps) and let the heap grow.
RUN sed -i \
        -e 's/EXTRA_EXPORTED_RUNTIME_METHODS=\[\[.FS.,.ccall.\]\]/EXPORTED_RUNTIME_METHODS=FS,ccall,callMain/' \
        -e 's/ -s USE_PTHREADS=0//; s/ -s PROXY_TO_PTHREAD=0//' \
        -e 's/ -s SAFE_HEAP=1//; s/ -s STACK_OVERFLOW_CHECK=1//' \
        -e 's/-gsource-map //; s/ --source-map-base \///' \
        -e 's/ALLOW_MEMORY_GROWTH=0/ALLOW_MEMORY_GROWTH=1/' \
        -e 's/-O$OPT_LEVEL -g /-O$OPT_LEVEL /' \
        configure.ac \
    && emconfigure autoreconf -fi \
    && ac_cv_exeext=".html" emconfigure ./configure --host=none-none-none \
    && emmake make -j"$(nproc)"

# Turn with the arrow keys (scancodes 75/77) instead of O/P, and capture the
# mouse (pointer lock) so it can turn without hitting the edge of the screen.
RUN sed -i \
        -e 's/^key_right .*/key_right                     77/' \
        -e 's/^key_left .*/key_left                      75/' \
        -e 's/^grabmouse .*/grabmouse                     1/' \
        src/default.cfg

# --- runtime stage: nginx serving the game ----------------------------------
FROM alpine:3.23

RUN apk add --no-cache nginx

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY --chown=nginx:nginx site/ /var/www/doom/

# The engine (GPL, Chocolate Doom) and the game data (BSD, Freedoom Phase 1).
COPY --from=build --chown=nginx:nginx /src/src/websockets-doom.js \
                  /src/src/websockets-doom.wasm \
                  /src/src/default.cfg \
                  /var/www/doom/
COPY --from=build --chown=nginx:nginx /usr/share/games/doom/freedoom1.wad /var/www/doom/freedoom1.wad

RUN rm -f /etc/nginx/http.d/default.conf

EXPOSE 8082

CMD ["nginx", "-g", "daemon off;"]
