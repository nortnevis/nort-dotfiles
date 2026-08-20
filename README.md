Подсказки:
- запуская `xprop` можно понять, какой графический сервер использует приложение. Если крестик, то X11. А если ничего не происходит, то это Wayland

Что я настроил (конфиги):
- sway config
- google-chrome флаги (см. директорию далее)
- настроил /etc/vconsole.conf с помощью localectl (поменял конфиги раскладки)
- изменил дефолтный редактор (для visudo) через .bashrc
- добавил в /etc/sudoers.d/light настройку для light, чтобы управлять яркостью без sudo (изначально там нужен sudo, а это неудобно) (у меня села батарея и vim закешировал настройки, так что я теперь хз, как он себя ведёт)
- изменил отображение строки приглашения к вводу в .bashrc
- настроил статус бар (.config/i3blocks/config). Установил для него acpi (батарея), mpstat (sysstat для просмотра нагрузок на cpu)
- foot.ini размер шрифта 28, scroll сделал и добавил в nort-dotfiles/
- настроил как-то звук (были проблемы с наличием аудиокарты. помогла перезагрузка), изменил дефолтный выход.
- Настроил hyprland клавиши
- hyprlock добавил отображение раскладки (~/.config/hypr/nort_hypr/hyprlock.conf)
- попытка включать hyprlock по настройкам hypridle
- Поставил глобальный флажок на использование wayland в electron-flags.conf и добавил в этот файл флаг `--disable-gpu`
- удалил xf86-video-intel и установил xorg-server, ещё установил vulkan-intel
- включил mutlilib для установки стима
- включил force_zero_scaling для xwayland, чтобы нормальное разрешение было
- установил gamescope
- xdg-desktop-portal-gtk
- dns сервера можно задать в файлах соединений: `/etc/NetworkManager/system-connections/*.nmconnection`
- v4l-utils для управления видеодрайверами (и веб-камерой)
- Чтобы не засыпал при закрытии крышки: создал /etc/systemd/logind.conf.d/logind.conf и добавил туда `HandleLidSwitch=lock`
- в `/etc/bluetooth/main.conf` раскомментировал строчку `NameResolving = true` в надежде, что это поможет с отображением имён устройств в `bluetui`.
- DNS over HTTPS (DoH) через dnscrypt-proxy (пока не работает).
- Добавил привилегии для happ-dekstop: `sudo setcap cap_net_admin,cap_net_raw+eip /opt/happ/bin/Happ` (вряд ли нужно. Это не помогло, так как ломается QT на wayland при использовании sudo). Поэтому обратился по этой инструкции: https://wiki.archlinux.org/title/Privilege_elevation_for_graphical_applications#Wayland.
- Установил xorg-xhost (с ним работает, но я хочу сделать всё через pkexec).
- export QT_QPA_PLATFORM=wayland
- export VISUAL="nvim" в .bashrc
- В /usr/share/applications/Happ.desktop добавил в exec команду polkit для запуска от имени администратора. (ведь мы юзаем rofi)
- настроил связывание суффиксов доменов с dns сервером. Через папку /etc/systemd/network.d/00-override.network (удалено)
- установил cliphist (+wl-clipboard). Добавил в autostart в hyprland конфиге на запуск, прослушивание и отправку в cliphist. Добавил скрипт rofi-clipboard для более тонкой настройки поведения селектора буфера обмена.
- noto-fonts-emoji ttf-nerd-fonts-symbols-common
- emote через yay (+куча зависимостей python). Он создаёт `emote.desktop` в `/etc/xdg/autostart`. Добавил shortcut в hypland
- добавил vim plug и настроил nvim плагины
- Поменял escape и caps-lock местами в /etc/keyd/default.conf
- Изменил HF_HOME на свою директорию для huggingface
- отключил DHCP для DNS Server в `/etc/systemd/networkd.conf` и `/etc/iwd/main.conf`
- лимит на системный журнал командой: `sudo journalctl --vacuum-size=500M`

Настройки sway:
- добавление лаунчера
- изменение клавиш изменения раскладки
- добавление управления приложением ligth и swaylock (хотелось бы поменять последний)
- настройки тачпада (нормальный скроллинг, тапы)
- добавил имя и email в глобальных конфигах гита

Что установил:
- sway
- swaylock
- hyprland
- hypridle
- reflector
- iwd
- okular (pdf reader)
- nvim
- cmake
- ninja
- zip
- vcpkg
- gdb
- lazygit
- rz-cutter (reverse engineering)
- kitty
- ly (это login screen)
- light для управления яркостью
- i3blocks для статус бар
- fuzzel (лаунчер приложений)
- acpi (battary log) in bar
- mpstat (sysstat) for cpu measurements in bar
- iw for wifi measurements in bar
- bind, в котором есть nslookup для zapret
- zapret (/opt/zapret всё там + https://github.com/bol-van/zapret/discussions/200 рекомендации по настройке)
- pipewire (+ wireplumber - менеджер сеансов и как следствие lua)
- pipewire-audio (добавляет аудио-сервер?)
- pipewire-pulse (появились аудио-устройства в wpctl status)
- alsa-utils, pipewire-jack, ttf-font-awesome для i3block
- sof-firmware (возможные обновления для laptop) 
- rtkit для pipewire
- pciutils usbutils установлены
- mako (notifications) + libnotify (notify-send) for testing purposes
- git-credential-manager чтобы хранить креды от гита
- gnome-keyring + libsecret для vs code синхронизации
- openbsd-netcat, net-tools (netstat)
- xorg-xwayland
- openvpn
- bluez, bluez-utils, bluetui
- freerdp
- remmina
- otf-font-awesome
- ttf-arimo-nerd
- noto-fonts
- pavucontrol (audio gui)
- loupe (GNU image viewer)
- steam
- flameshot
- discord
- zerotier-one
- amnezia-bin
- keyd (для ремаппинга клавиш)
- ripgrep
- jq
- yq
- ocl-icd и clinfo
- ccache для ускорения сборки (hiredis as dependency)

Python:
- pyenv
- tk

Пользовательские приложухи
- google-chrome
- telegram-desktop
- vscode
- inkscape
- gimp
- obsidian
- emacs
- gedit (простой текстовый редактор GNU)
- sublime merge

AI:
- llama-cpp
- gglm (tensor library) + OpenBLAS
- python-huggingface-hub

Файлы конфигурации:
- ~/.vimrc
- ~/.config/nvim/init.lua
- ~/vh.sh
- ~/hypr_conf.sh

На компе:
Была проблема с использованием cpu для видосов на ютубе в google-chrome.
Для решения проблемы:
- sudo pacman -S libva-nvidia-driver libva-utils vdpauinfo
По итогу я наверное не так понял проблему. Лагал курсор беспроводной мыши (проводная мышь работала идеально).
Нагрузка на CPU была сопряжена с загрузкой данных с ютуба. Всё правильно.
