#!/usr/bin/bash

FLATPAK_ID=${FLATPAK_ID:-"io.github.vencord.Vesktop"}
socat $SOCAT_ARGS \
    UNIX-LISTEN:$XDG_RUNTIME_DIR/app/${FLATPAK_ID}/discord-ipc-0,forever,fork \
    UNIX-CONNECT:$XDG_RUNTIME_DIR/discord-ipc-0 \
    &
socat_pid=$!

FLAGS='--ignore-gpu-blocklist --enable-gpu-rasterization --enable-zero-copy --enable-gpu-compositing --enable-native-gpu-memory-buffers --enable-oop-rasterization --enable-features=UseSkiaRenderer,WaylandWindowDecorations,VaapiVideoDecoder,VaapiVideoEncoder'

WAYLAND_SOCKET=${WAYLAND_DISPLAY:-"wayland-0"}

if [[ -e "$XDG_RUNTIME_DIR/${WAYLAND_SOCKET}" ]]
then
    FLAGS="$FLAGS --ozone-platform-hint=auto"
fi

if [[ $XDG_SESSION_TYPE == "wayland" ]] && [ -c /dev/nvidia0 ]
then
    FLAGS="$FLAGS --use-vulkan"
fi

exec zypak-wrapper /app/vesktop/vencorddesktop $FLAGS "$@"
kill -SIGTERM $socat_pid